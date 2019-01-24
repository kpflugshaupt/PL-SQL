--------------------------------------------------------------------------------
-- PACKAGE SPECIFICATION
--------------------------------------------------------------------------------
create or replace package apg_diff as

   -----------------------------------------------------------------------------
   -- PUBLIC TYPES
   -----------------------------------------------------------------------------
   subtype t_lnr_key is varchar2(70);
   subtype t_lnr     is varchar2(30);
   type    t_lnr_map is table of t_lnr_key index by t_lnr;


   -----------------------------------------------------------------------------
   -- PUBLIC ROUTINES
   -----------------------------------------------------------------------------
   /**
      Defines a named set of tables to work with
      Set tables need to be passed separated by commas
   */
   procedure def_table_set(PI_table_set_name varchar2, PI_table_set varchar2);

   /**
      Initialises a previously defined named set of tables to work with
   */
   procedure init_table_set(PI_table_set_name varchar2);

   /**
      Define index column(s) to be used for a table in a table set
   */
   procedure set_idx_cols(PI_table_set_name varchar2, PI_table_name varchar2, PI_idx_cols varchar2);

   /**
      Take a snapshot (physical copy) of all tables in table set, register in sbapshot table
      If no table set is specified, the previously used one is taken
   */
   procedure snapshot(
      PI_tag       varchar2 := to_char(sysdate, 'yyyymmdd_hh24miss')
     ,PI_table_set varchar2 := null
   );

   /**
      Delete a snapshot 
   */
   procedure del_snapshot(PI_tag varchar2);

   /**
      Restore a backup snapshot
   */
   procedure restore_snapshot(PI_tag varchar2);

   /**
      Truncate all tables in current table set
   */
   procedure truncate_tables;

   /**
      Disable all triggers on tables in current table set
   */
   procedure disable_triggers;

   /**
      Enable all triggers on tables in current table set
   */
   procedure enable_triggers;

   /**
      Calculate differences between two snapshots (by tags), store in diff table
   */
   procedure calc_diff(PI_tag1 varchar2, PI_tag2 varchar2);

   /**
      Calculate differences between two snapshots (by nr), store in diff table
   */
   procedure calc_diff(PI_nr1 pls_integer, PI_nr2 pls_integer);

   /**
      Drop snapshot and diff tables
   */
   procedure cleanup;

   /**
      Logging with timestamp
   */
   procedure time_log(PI_title varchar2, PI_ctx clob := null);


end apg_diff;
/


--------------------------------------------------------------------------------
-- PACKAGE BODY
--------------------------------------------------------------------------------

create or replace package body apg_diff as

   --------------------------------------------------------------------------------
   -- TYPES
   --------------------------------------------------------------------------------
   subtype t_table_name      is varchar2(4000);
   type    t_table_list      is table of t_table_name;
   type    t_table_excp_list is table of boolean index by t_table_name;
   subtype t_column_name     is varchar2(4000);

   type    t_table_key_tab is table of varchar2(4000) index by t_table_name;


   --------------------------------------------------------------------------------
   -- GLOBAL DATA
   --------------------------------------------------------------------------------
   g_table_list        t_table_list := t_table_list();
   g_table_excp_list   t_table_excp_list;
   g_current_table_set varchar2(100);
   g_table_key_tab     t_table_key_tab;


   --------------------------------------------------------------------------------
   -- PROCEDURES
   --------------------------------------------------------------------------------
   function table_exists(PI_table_name t_table_name)
   return boolean
   is
      l_found boolean := false;
   begin
      for c in (select 1 from user_tables where table_name = upper(PI_table_name)) loop
         l_found := true;
         exit;
      end loop;
      return l_found;
   exception
      when others then
         time_log('Exception in "table_exists": ', sqlerrm); raise;
   end table_exists;


   --------------------------------------------------------------------------------
   function str_trim(pi_str varchar2, pi_trim_pattern varchar2 := '\s')
   return varchar2
   is
   begin
      return regexp_replace(pi_str, '^'||pi_trim_pattern||'*(.*?)'||pi_trim_pattern||'*$', '\1');
   end str_trim;


   --------------------------------------------------------------------------------
   function str_split(pi_str varchar2, pi_delim varchar2 := ',')
   return SRCVARCHAR2_TABLE_SQL
   is
      l_str_list SRCVARCHAR2_TABLE_SQL  := SRCVARCHAR2_TABLE_SQL();
      l_pos      pls_integer := 1;
      l_found    pls_integer := 0;
      l_new_idx  pls_integer;
      l_str_part varchar2(4000);
   begin
      loop
         l_found   := instr(pi_str, pi_delim, l_pos);
         l_str_list.extend;
         l_new_idx := l_str_list.last;
         if l_found > 0 then
            l_str_list(l_new_idx) := str_trim(substr(pi_str, l_pos, l_found - l_pos));
            l_pos                 := l_found + length(pi_delim);
         else
            l_str_part := str_trim(substr(pi_str, l_pos));
            if l_str_part is not null then
               l_str_list(l_new_idx) :=l_str_part;
            else
               l_str_list.delete(l_new_idx);
            end if;
            exit;
         end if;
      end loop;
      return l_str_list;
   end str_split;


   --------------------------------------------------------------------------------
   function str_join(pi_str_list SRCVARCHAR2_TABLE_SQL, pi_delim varchar2 := ',')
      return varchar2
   is
      l_str varchar2(4000);
   begin
      for i in 1 .. pi_str_list.count loop
         l_str := l_str || pi_str_list(i) || pi_delim;
      end loop;
      l_str := substr(l_str, length(l_str) - length(pi_delim));
      return l_str;
   end str_join;


   --------------------------------------------------------------------------------
   procedure def_table_set(PI_table_set_name varchar2, PI_table_set varchar2)
   is
      l_table_tab    SRCVARCHAR2_TABLE_SQL;
   begin
      execute immediate '
         delete from diff_table_set where set_name = :tset
      ' using PI_table_set_name;
      --
      l_table_tab := str_split(PI_table_set, ',');
      for idx in 1 .. l_table_tab.count loop
         execute immediate '
            insert into diff_table_set (set_name, table_name, seq_nr) values(:tset, upper(:tab), :nr)
         '  using PI_table_set_name, l_table_tab(idx), idx;
      end loop;
      commit;
   exception
     when others then
       time_log('Execute immediate error');
   end def_table_set;


   --------------------------------------------------------------------------------
   procedure set_idx_cols(PI_table_set_name varchar2, PI_table_name varchar2, PI_idx_cols varchar2)
   is
   begin
      execute immediate '
         update diff_table_set
            set idx_cols =   :cols
          where set_name =   :tset
            and table_name = upper(:tab)
      '  using PI_idx_cols, PI_table_set_name, PI_table_name;
      commit;
   exception
     when others then
       time_log('Execute immediate error');
   end set_idx_cols;


   --------------------------------------------------------------------------------
   procedure set_do_skip(PI_table_set_name varchar2, PI_table_name varchar2, PI_do_skip boolean := true)
   is
   begin
      execute immediate '
         update diff_table_set
            set do_skip    = ' || case PI_do_skip when true then '''Y''' else 'null' end || '
          where set_name   = :tset
            and table_name = upper(:tab)
      '  using PI_table_set_name, PI_table_name;
      commit;
   exception
     when others then
       time_log('Execute immediate error');
   end set_do_skip;


   --------------------------------------------------------------------------------
   procedure init
   is
      l_key_columns varchar2(4000);
      --
      procedure create_table(PI_table_name t_table_name, PI_columns varchar2)
      is
      begin
         -- return if table exists
         if table_exists(PI_table_name) then
            return;
         end if;
         execute immediate 'create table '||PI_table_name||' ('||PI_columns||')';
      end create_table;
   begin
      time_log('Initialising tables');
      -- create working tables
      create_table('diff_snapshot',
                   'timestp date, set_name varchar2(1000), tag varchar2(100), nr number');
      create_table('diff_table_set',
                   'set_name varchar2(1000), table_name varchar2(4000), seq_nr number, do_skip varchar2(1), idx_cols varchar(1000)');
      create_table('diff_diff',
                   'status varchar2(7), set_name varchar2(1000), diff varchar2(2000), table_name varchar2(4000), key_flds varchar2(4000), key varchar2(4000), field varchar2(1000), old_val varchar2(4000), new_val varchar2(4000)');
      create_table('diff_diff_log',
                   'timestp timestamp, title varchar2(4000), ctx clob, stack clob');

      -- create aggregating result view
      execute immediate q'{
         create or replace force view diff_diff_ov as
         select
            diff
           ,set_name
           ,table_name
           ,status
           ,nrows
           ,nfields
           ,fields
         from (
            with flds as (
               select diff, set_name, table_name, listagg(field, ', ') within group (order by field) fields
               from (
                  select diff, set_name, table_name, field
                  from diff_diff
                  where status = 'MDF'
                  group by diff, set_name, table_name, field)
               group by diff, set_name, table_name)
            select diff
                  ,set_name
                  ,table_name
                  ,status
                  ,count(distinct key) nrows
                  ,case when status = 'MDF' then count(distinct field) else null end nfields
                  ,case when status = 'MDF' then (select fields from flds where flds.diff = vvd.diff and flds.table_name = vvd.table_name) else null end fields
            from diff_diff vvd
            group by diff, set_name, table_name, status
         )
      }';

   exception
      when others then
        time_log('Exception in "init": ', sqlerrm); raise;
   end init;


  --------------------------------------------------------------------------------
   procedure init_table_set(PI_table_set_name varchar2)
   is
      type t_ts_rec is record (
         table_name t_table_name
        ,do_skip    varchar2(1)
        ,idx_cols   varchar2(1000)
      );
      type t_ts_tab is table of t_ts_rec index by pls_integer;
      --
      l_ts_tab    t_ts_tab;
   begin
      if PI_table_set_name is null then
         time_log('Exit: No table set defined!!');
         return;
      end if;
      time_log('Initialise table set '||PI_table_set_name);
      if not table_exists('diff_snapshot') then
         init;
      end if;
      g_table_list.delete;
      g_table_excp_list.delete;
      g_current_table_set := PI_table_set_name;
      begin
         execute immediate '
            select table_name, do_skip, idx_cols
              from diff_table_set
             where set_name = :tset
            order by seq_nr
         '
         bulk collect into l_ts_tab
         using PI_table_set_name;
      exception
        when others then
          time_log('Execute immediate error');
      end;
      for i in 1 .. l_ts_tab.count loop
         g_table_list.extend;
         g_table_list(i) := l_ts_tab(i).table_name;

         -- if table has do_skip flag, put it on exception list
         if l_ts_tab(i).do_skip = 'Y' then
            g_table_excp_list(l_ts_tab(i).table_name) := true;
         end if;

         -- specified idx_cols are used
         if l_ts_tab(i).idx_cols is not null then
            g_table_key_tab(l_ts_tab(i).table_name) := l_ts_tab(i).idx_cols;
         end if;
      end loop;
   end init_table_set;


   --------------------------------------------------------------------------------
   procedure time_log(PI_title varchar2, PI_ctx clob)
   is
      pragma autonomous_transaction;
   begin
      execute immediate '
         insert into diff_diff_log (timestp, title, ctx, stack) values (
            systimestamp
           ,:title
           ,:ctx
           ,dbms_utility.format_error_stack || chr(10) ||
            dbms_utility.format_error_backtrace || chr(10) ||
            dbms_utility.format_call_stack
         )' using PI_title, PI_ctx;
      commit;
      dbms_output.put_line(to_char(sysdate, 'hh24:mi:ss ')||substr(PI_title, 1, 4000));
   exception
      when others then
         if table_exists('diff_diff_log') then
            time_log(PI_title, PI_ctx);
         end if;
   end time_log;


   --------------------------------------------------------------------------------
   function snapshot_exists(PI_tag varchar2)
   return boolean
   is
      l_cnt pls_integer;
   begin
      execute immediate '
         select count(*)
         from diff_snapshot
         where tag = :tag'
      into l_cnt
      using PI_tag;
      --
      return (nvl(l_cnt, 0) > 0);
   exception
      when others then
         time_log('Exception in "snapshot_exists": ', sqlerrm); raise;
   end snapshot_exists;


   --------------------------------------------------------------------------------
   procedure del_snapshot(PI_tag varchar2)
   is
      l_deleted boolean := true;
   begin
      time_log('delete snapshot '||PI_tag);
      if g_table_list.count > 0 then
         for idx in g_table_list.first .. g_table_list.last loop
            begin
               if not g_table_excp_list.exists(g_table_list(idx)) then
                  execute immediate 'drop table ' || g_table_list(idx) || '__' || PI_tag;
               else
                  time_log('Table '||g_table_list(idx)||' is on exception list');
               end if;
            exception
               when others then
                  l_deleted := false;
                  time_log('Couldn''t drop table '||g_table_list(idx) || '__' || PI_tag);
            end;
         end loop;
      end if;
      if l_deleted then
         begin
            execute immediate 'delete from diff_snapshot where tag = :tag' using PI_tag;
         exception
            when no_data_found then time_log('No snapshot registration found to delete');
            when others        then time_log('Unexpected exception: '||sqlerrm);
         end;
      end if;
   exception
      when others then
         time_log('Exception in "del_snapshot": ', sqlerrm); raise;
   end del_snapshot;


   --------------------------------------------------------------------------------
   procedure table_disable_triggers(PI_table_name t_table_name)
   is
   begin
      for c in (select trigger_name from user_triggers where table_name = upper(PI_table_name)) loop
         execute immediate 'alter trigger '||c.trigger_name||' disable';
      end loop;
   exception
      when others then
         time_log('Exception in "table_disable_triggers": ', sqlerrm); raise;
   end table_disable_triggers;


   --------------------------------------------------------------------------------
   procedure table_enable_triggers(PI_table_name t_table_name)
   is
   begin
      for c in (select trigger_name from user_triggers where table_name = upper(PI_table_name)) loop
         execute immediate 'alter trigger '||c.trigger_name||' enable';
      end loop;
   exception
      when others then
         time_log('Exception in "table_enable_triggers": ', sqlerrm); raise;
   end table_enable_triggers;


   --------------------------------------------------------------------------------
   procedure restore_snapshot(PI_tag varchar2)
   is
      l_table_name      t_table_name;
      l_bkup_table_name t_table_name;
      l_stmt            clob;
      l_table_set       varchar2(1000);
   begin
      time_log('---- START RESTORE SNAPSHOT '||PI_tag||'----');
      l_table_set := g_current_table_set;
      if g_current_table_set is null or l_table_set != g_current_table_set then
         init_table_set(l_table_set);
      end if;
      l_table_name := g_table_key_tab.first;
      while l_table_name is not null loop
         if g_table_excp_list.exists(l_table_name) then
            time_log('Table '||l_table_name||' on exception list, not restoring');
            l_table_name := g_table_key_tab.next(l_table_name);
            continue;
         end if;
         l_bkup_table_name := l_table_name || '__' || PI_tag;
         table_disable_triggers(l_table_name);
         time_log('truncate table '||l_table_name);
         execute immediate 'truncate table '||l_table_name;
         --
         l_stmt := 'insert /*+ append parallel */ into '||l_table_name||' select /*+ parallel */ * from '||l_bkup_table_name;
         time_log(l_stmt);
         begin
            execute immediate l_stmt;
         exception
            when others then
               time_log('Could not restore table '||l_table_name||' from snapshot '||PI_tag);
         end;
         commit;
         table_enable_triggers(l_table_name);
         --
         l_table_name := g_table_key_tab.next(l_table_name);
      end loop;
      time_log('---- END RESTORE SNAPSHOT '||PI_tag||'----');
   exception
      when others then
         time_log('Exception in "restore_snapshot": ', sqlerrm); raise;
   end restore_snapshot;


   --------------------------------------------------------------------------------
   procedure truncate_tables
   is
      l_table_name      t_table_name;
   begin
      time_log('---- START TRUNCATING TABLES ----');
      l_table_name := g_table_key_tab.first;
      while l_table_name is not null loop
         if g_table_excp_list.exists(l_table_name) then
            time_log('Table '||l_table_name||' on exception list, not truncated');
            l_table_name := g_table_key_tab.next(l_table_name);
            continue;
         end if;
         time_log('truncate table '||l_table_name);
         execute immediate 'truncate table '||l_table_name;
         --
         l_table_name := g_table_key_tab.next(l_table_name);
      end loop;
      time_log('---- END TRUNCATING TABLES ----');
   exception
      when others then
         time_log('Exception in "truncate_tables": ', sqlerrm); raise;
   end truncate_tables;


   --------------------------------------------------------------------------------
   procedure disable_triggers
   is
      l_table_name      t_table_name;
   begin
      time_log('---- START DISABLING TRIGGERS ----');
      l_table_name := g_table_key_tab.first;
      while l_table_name is not null loop
         time_log('disable triggers on table '||l_table_name);
         table_disable_triggers(l_table_name);
         --
         l_table_name := g_table_key_tab.next(l_table_name);
      end loop;
      table_disable_triggers('diff_TEXT');
      time_log('---- END DISABLING TRIGGERS ----');
   end disable_triggers;


   --------------------------------------------------------------------------------
   procedure enable_triggers
   is
      l_table_name      t_table_name;
   begin
      time_log('---- START ENABLING TRIGGERS ----');
      l_table_name := g_table_key_tab.first;
      while l_table_name is not null loop
         time_log('enable triggers on table '||l_table_name);
         table_enable_triggers(l_table_name);
         --
         l_table_name := g_table_key_tab.next(l_table_name);
      end loop;
      table_enable_triggers('diff_TEXT');
      time_log('---- END ENABLING TRIGGERS ----');
   end enable_triggers;


   --------------------------------------------------------------------------------
   procedure ora_drop(PI_obj_type varchar2, PI_obj_name varchar2)
   is
   begin
      execute immediate 'drop '||PI_obj_type||' '||PI_obj_name;
   exception
      when others then
         time_log('Couldn''t drop '||PI_obj_type||' '||PI_obj_name);
   end ora_drop;

   --------------------------------------------------------------------------------
   procedure cleanup
   is
      c      sys_refcursor;
      l_stmt varchar2(4000);
      l_tag  varchar2(100);
   begin
      time_log('---- START CLEANUP ----');

      -- remove all snaphot backup tables
      l_stmt := 'select distinct tag from diff_snapshot';
      begin
         open c for l_stmt;
         loop
            fetch c into l_tag;
            exit when c%notfound;
            --
            del_snapshot(l_tag);
         end loop;
      exception
         when others then
            time_log('Couldn''t delete snapshot');
      end;

      -- remove snapshot and diff tables
      ora_drop('table', 'diff_snapshot');
      ora_drop('view',  'diff_diff_ov');
      ora_drop('table', 'diff_diff');
      ora_drop('table', 'diff_table_set');
      ora_drop('table', 'diff_diff_log');

      -- clean up memory state
      g_current_table_set := null;

      time_log('---- END CLEANUP ----');
   exception
      when others then
         time_log('Exception in "cleanup": ', sqlerrm); raise;
   end cleanup;


   --------------------------------------------------------------------------------
   procedure snapshot(PI_tag varchar2, PI_table_set varchar2)
   is
      l_table_name      t_table_name;
      l_table_set       varchar2(100);
      l_stmt            varchar2(4000);
      l_bkup_table_name t_table_name;
      l_timestp         date;
      l_nr              pls_integer;
   begin
      l_table_set := coalesce(PI_table_set, g_current_table_set, 'VDF');
      if g_current_table_set is null or l_table_set != g_current_table_set then
         init_table_set(l_table_set);
      end if;
      --
      time_log('---- START SNAPSHOT '||PI_tag||' of table set '||l_table_set||' ----');
      if snapshot_exists(PI_tag) then
         del_snapshot(PI_tag);
      end if;
      --
      l_timestp := sysdate;
      execute immediate '
         select nvl(max(nr), 0) + 1
         from   diff_snapshot'
         into l_nr;
      --
      l_table_name := g_table_key_tab.first;
      while l_table_name is not null loop
         -- skip tables in exception list
         if g_table_excp_list.exists(l_table_name) then
            time_log('Table '||l_table_name||' on exception list, not backed up');
            l_table_name := g_table_key_tab.next(l_table_name);
            continue;
         end if;
         l_bkup_table_name := l_table_name || '__' || PI_tag;
         l_stmt := 'create table '||l_bkup_table_name||' as select /*+ parallel(8) */ * from '||l_table_name;
         if table_exists(l_bkup_table_name) then
            ora_drop('table', l_bkup_table_name);
         end if;
         time_log(l_stmt);
         begin
            execute immediate l_stmt;
         exception
            when others then
               time_log('Could not create table '||l_bkup_table_name, 'Generated statement: '||l_stmt);
         end;
         --
         l_table_name := g_table_key_tab.next(l_table_name);
      end loop;
      --
      execute immediate '
         insert into diff_snapshot(timestp, tag, nr, set_name)
         values(:timestp, :tag, :nr, :tset)'
         using l_timestp, PI_tag, l_nr, l_table_set
      ;
      commit;
      time_log('---- END SNAPSHOT '||PI_tag||' of table set '||l_table_set||' ----');
   exception
      when others then
         time_log('Error creating snapshot', 'Generated statement: '||l_stmt);
         time_log('Exception in "snapshot": ', sqlerrm); raise;
   end snapshot;


   --------------------------------------------------------------------------------
   function table_columns(
      PI_table_name  t_table_name
     ,PI_quote       boolean := false
     ,PI_map         boolean := true
   )
   return clob
   is
      l_columns      clob;
      l_expr         varchar2(1000);
      l_quote        varchar2(2) := case when PI_quote then q'{'}' else null end;
      l_is_vdf       boolean := case when g_current_table_set = 'VDF' then true else false end;
      l_idx_cols     varchar2(4000);
      l_idx_col_list SRCVARCHAR2_TABLE_SQL;
   begin
      -- Get index column override, if set
      execute immediate '
         select idx_cols
           from diff_table_set
          where set_name   = :tset
            and table_name = upper(:tab)
      '
      into l_idx_cols
      using g_current_table_set, PI_table_name;
      l_idx_col_list := str_split(l_idx_cols, ',');

      -- return table columns without custom key field(s)
      l_columns := l_quote;
      for c in (
         select utc.column_name
         into   l_columns
         from   user_tab_columns utc
         where  utc.table_name = upper(PI_table_name)
            and utc.column_name not in (
               select nvl(column_value, '[NULL]') from table(l_idx_col_list)
            )
         order by column_id
      ) loop
         -- skip custom index columns
         continue when instr(l_idx_cols, c.column_name) > 0;
         --
         l_expr := c.column_name;
         l_columns := l_columns || l_expr || l_quote||', '||l_quote;
      end loop;
      l_columns := substr(l_columns, 1, (length(l_columns) - 2 - 2 * nvl(length(l_quote), 0))) || l_quote;
      --
      return l_columns;
   exception
      when others then
         time_log('Exception in "table_columns": ', sqlerrm); raise;
   end table_columns;

   --------------------------------------------------------------------------------
   function table_pkey(PI_table_name t_table_name)
   return varchar2
   is
      l_pkey         varchar2(4000);
      l_column_name  t_column_name;
      l_expr         varchar2(1000);
      c              sys_refcursor;
      l_idx_cols     varchar2(4000);
      l_idx_col_list SRCVARCHAR2_TABLE_SQL := SRCVARCHAR2_TABLE_SQL();
   begin
      -- Get index column override, if set
      execute immediate '
         select idx_cols
           from diff_table_set
          where set_name   = :tset
            and table_name = upper(:tab)'
      into l_idx_cols
      using g_current_table_set, PI_table_name;
      l_idx_col_list := str_split(l_idx_cols, ',');

      -- return custom index fields or business primary key fields (C2 index), concatenated for use in generated query
      l_pkey := 'to_char(';
      if l_idx_col_list.count > 0 then
          open c for '
            select column_value
            from   table(:tab)'
            using l_idx_col_list
         ;
      end if;

      loop
         fetch c into l_column_name;
         exit when c%notfound;
         --
         l_expr := l_column_name;
         l_pkey := l_pkey || l_expr || q'{) || ' | ' || to_char(}';
      end loop;
      l_pkey := substr(l_pkey, 1, length(l_pkey) - 22) || ')';
      --
      return l_pkey;
   exception
      when others then
         time_log('Exception in "table_pkey": ', sqlerrm); raise;
   end table_pkey;


   --------------------------------------------------------------------------------
   procedure calc_diff(PI_tag1 varchar2, PI_tag2 varchar2)
   is
      l_tag_cnt          pls_integer;
      l_set_cnt          pls_integer;
      l_set_name         varchar2(4000);
      l_rpt              clob;
      l_stmt             clob;
      l_table_base_name  t_table_name;
      l_tab1_name        t_table_name;
      l_tab2_name        t_table_name;
      l_table_columns    clob;
      l_table_q_columns  clob;
      l_table_nomap_cols clob;
      l_field            varchar2(200);
      l_table_pkey       varchar2(1000);
      --
      pragma autonomous_transaction;
   begin
      time_log('---- START DIFF '||PI_tag1||' vs. '||PI_tag2||' ----');
      -- check if snapshots exist and were created on the same table set
      execute immediate '
         select count(*), count(distinct set_name)
         from diff_snapshot
         where tag in (:tag1, :tag2)'
         into l_tag_cnt, l_set_cnt
         using PI_tag1, PI_tag2;
      if l_tag_cnt != 2 then
         time_log('==> ERROR: Snapshots not found: '||PI_tag1||', '||PI_tag2);
         return;
      end if;
      if l_set_cnt != 1 then
         time_log('==> ERROR: Snapshots not from the same table set');
         return;
      end if;

      -- find table set, initialise if necessary
      execute immediate '
         select set_name
         from diff_snapshot
         where tag = :tag1'
         into l_set_name
         using PI_tag1;
      if g_current_table_set is null or l_set_name != g_current_table_set then
         init_table_set(l_set_name);
      end if;

      -- delete older results, if any
      execute immediate q'{
         delete from diff_diff
         where diff = :tag1||'/'||:tag2}'
         using PI_tag1, PI_tag2;
      commit;

      -- loop over all tables
      for idx in g_table_list.first .. g_table_list.last loop
         -- skip tables in exception list
         continue when g_table_excp_list.exists(g_table_list(idx));
         l_table_base_name  := g_table_list(idx);
         l_tab1_name        := l_table_base_name || '__' || PI_tag1;
         l_tab2_name        := l_table_base_name || '__' || PI_tag2;

         l_table_columns    := table_columns(l_table_base_name);
         l_table_q_columns  := table_columns(l_table_base_name, PI_quote => true);
         l_table_nomap_cols := table_columns(l_table_base_name, PI_map => false);
         l_table_pkey       := table_pkey(l_table_base_name);
         if l_table_pkey is null then
            time_log('Skipping table '||l_table_base_name||': No custom key columns defined');
            continue;
         end if;
         time_log('Comparing tables '||l_tab1_name||' and '||l_tab2_name||', key = '||l_table_pkey);

         -- generate diff code for one table pair
         l_stmt := q'{
            declare
               subtype t_field     is varchar2(1000);
               subtype t_fld_val   is varchar2(4000);
               type t_column_list  is table of user_tab_columns.column_name%type;
               type t_fld_diff_rec is record (old_val t_fld_val, new_val t_fld_val);
               type t_fld_diff_tab is table of t_fld_diff_rec index by t_field;
               --
               l_query           clob;
               l_column_list     t_column_list := t_column_list(}'||l_table_q_columns||q'{);
               l_fld_diff_tab    t_fld_diff_tab;
               c_empty_diff_tab  t_fld_diff_tab;
               l_idx             t_field;
               l_tag1            varchar2(1000) := '}'||PI_tag1||q'{';
               l_tag2            varchar2(1000) := '}'||PI_tag2||q'{';
               l_diff            varchar2(2000) := l_tag1 || '/' || l_tag2;
               l_table_base_name varchar2(4000) := '}'||l_table_base_name||q'{';
               l_set_name        varchar2(4000) := '}'||l_set_name||q'{';
            begin
               for c in (
                  with t_old as (select /*+ inline */ }'||l_table_pkey||q'{ pkey, }'||l_table_columns||q'{ from }'||l_tab1_name||q'{)
                      ,t_new as (select /*+ inline */ }'||l_table_pkey||q'{ pkey, }'||l_table_columns||q'{ from }'||l_tab2_name||q'{)
                  select
                     (case count(*) over (partition by td.pkey)
                        when 1 then
                           case td.version
                              when 'new' then '++'
                              when 'old' then '--'
                           end
                        when 2 then 'M'
                        else null
                      end) status,
                     td.*
                  from (
                     select 'old' version, t1.* from (
                        select * from t_old
                        minus
                        select * from t_new
                     ) t1
                     union all
                     select 'new' version, t2.* from (
                        select * from t_new
                        minus
                        select * from t_old
                     ) t2
                  ) td
                  order by td.pkey, (case td.version when 'old' then 1 when 'new' then 2 else 0 end) -- always sort new records after old
               )
               loop
                  case c.status
                     when '++' then
                        insert into diff_diff(status, diff, set_name, table_name, key_flds, key, field, old_val, new_val)
                        values ('NEW', l_diff, l_set_name, l_table_base_name, '}'||g_table_key_tab(l_table_base_name)||q'{', c.pkey, '(ALL)', null, null);
                     when '--' then
                        insert into diff_diff(status, diff, set_name, table_name, key_flds, key, field, old_val, new_val)
                        values ('DEL', l_diff, l_set_name, l_table_base_name, '}'||g_table_key_tab(l_table_base_name)||q'{', c.pkey, '(ALL)', null, null);
                     when 'M' then
                        case c.version
                           when 'old' then}'||chr(13);
         for i in l_table_columns.first .. l_table_columns.last loop
            l_field := l_table_columns(i);
            l_stmt  := l_stmt || q'{                              l_fld_diff_tab('}'||l_field||q'{').old_val := to_char(c.}'||l_field||q'{);}'||chr(13);
         end loop;
         l_stmt := l_stmt || q'{                           when 'new' then}'||chr(13);
         for i in l_table_columns.first .. l_table_columns.last loop
            l_field := l_table_columns(i);
            l_stmt  := l_stmt || q'{                              l_fld_diff_tab('}'||l_field||q'{').new_val := to_char(c.}'||l_field||q'{);}'||chr(13);
         end loop;
         l_stmt := l_stmt || q'{                              --
                              -- new comes after old, so now we can compare
                              l_idx := l_fld_diff_tab.first;
                              while l_idx is not null loop
                                 if nvl(l_fld_diff_tab(l_idx).old_val, '(NULL)') != nvl(l_fld_diff_tab(l_idx).new_val, '(NULL)') then
                                    insert into diff_diff(status, diff, set_name, table_name, key_flds, key, field, old_val, new_val)
                                    values ('MDF', l_diff, l_set_name, l_table_base_name, '}'||g_table_key_tab(l_table_base_name)||q'{', c.pkey, l_idx, l_fld_diff_tab(l_idx).old_val, l_fld_diff_tab(l_idx).new_val);
                                 end if;
                                 --
                                 l_idx := l_fld_diff_tab.next(l_idx);
                              end loop;
                              l_fld_diff_tab := c_empty_diff_tab;
                           else null;
                        end case;  -- c.version
                     else null;
                  end case;  -- c.status
               end loop;
               commit;
            end;
         }';
         -- run generated code for one table pair
         execute immediate l_stmt;
      end loop;
      time_log('---- END DIFF '||PI_tag1||' vs. '||PI_tag2||' ----');
   exception
      when others then
         time_log('Error in Diff calc, last generated code in CTX', l_stmt);
         time_log('Exception in "calc_diff"(1): ', sqlerrm); raise;
   end calc_diff;


   --------------------------------------------------------------------------------
   procedure calc_diff(PI_nr1 pls_integer, PI_nr2 pls_integer)
   is
      l_rpt clob;
      --
      function nr_to_tag(PI_nr pls_integer)
      return varchar2
      is
         l_tag varchar2(100);
      begin
         execute immediate '
            select tag
            from   diff_snapshot
            where  nr = :PI_nr'
            into   l_tag
            using  PI_nr;
         return l_tag;
      exception
         when no_data_found then
            return '[NULL]';
      end nr_to_tag;
   begin
      calc_diff(nr_to_tag(PI_nr1), nr_to_tag(PI_nr2));
   exception
      when others then
         time_log('Exception in "calc_diff"(2): ', sqlerrm); raise;
   end calc_diff;


begin
   init;
end apg_diff;
/
