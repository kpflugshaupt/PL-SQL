CREATE OR REPLACE package V0LDATI2.VLQDIFF0 as

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
      Store map to identify changed VL_LNR values
   */
   procedure set_vl_lnr_map(PI_lnr_map t_lnr_map);

   /**
      Store map to identify changed VL_REF_LNR values
   */
   procedure set_vl_ref_lnr_map(PI_lnr_map t_lnr_map);

   /**
      Store map to identify changed VL_BO_PLATZ_LNR values
   */
   procedure set_vl_bo_pl_lnr_map(PI_lnr_map t_lnr_map);

   /**
      Store map to identify changed VL_STAMM_GSCH_LNR values
   */
   procedure set_vl_st_gs_lnr_map(PI_lnr_map t_lnr_map);

   /**
      Store map to identify changed VL_CLEAR_SYS_LNR values
   */
   procedure set_vl_cl_sy_lnr_map(PI_lnr_map t_lnr_map);

   /**
      Store map to identify changed VL_SYM_LNR values
   */
   procedure set_vl_sym_lnr_map(PI_lnr_map t_lnr_map);

   /**
      Store map to identify changed VL_TRADE_PERP_LNR values
   */
   procedure set_vl_tr_pe_lnr_map(PI_lnr_map t_lnr_map);

   /**
      Store map to identify changed VL_STAMM_LAND_LNR values
   */
   procedure set_vl_st_la_lnr_map(PI_lnr_map t_lnr_map);

   /**
      Store map to identify changed VL_STAMM_KLA_LNR values
   */
   procedure set_vl_st_kl_lnr_map(PI_lnr_map t_lnr_map);

   /**
      Store map to identify changed KURS_REF_LNR values
   */
   procedure set_kurs_ref_lnr_map(PI_lnr_map t_lnr_map);

   /**
      Access map to identify changed VL_LNR values
      Return combined VL_LNR, if there is one
   */
   function vl_lnr_key(PI_vl_lnr varchar2)
   return varchar2;

   /**
      Access map to identify changed VL_REF_LNR values
      Return combined VL_REF_LNR, if there is one
   */
   function vl_ref_lnr_key(PI_vl_ref_lnr varchar2)
   return varchar2;

   /**
      Access map to identify changed VL_BO_PLATZ_LNR values
      Return combined VL_BO_PLATZ_LNR, if there is one
   */
   function vl_bo_pl_lnr_key(PI_vl_bo_pl_lnr varchar2)
   return varchar2;

   /**
      Access map to identify changed VL_STAMM_GSCH_LNR values
      Return combined VL_STAMM_GSCH_LNR, if there is one
   */
   function vl_st_gs_lnr_key(PI_vl_st_gs_lnr varchar2)
   return varchar2;

   /**
      Access map to identify changed VL_CLEAR_SYS_LNR values
      Return combined VL_CLEAR_SYS_LNR, if there is one
   */
   function vl_cl_sy_lnr_key(PI_vl_cl_sy_lnr varchar2)
   return varchar2;

   /**
      Access map to identify changed VL_SYM_LNR values
      Return combined VL_SYM_LNR, if there is one
   */
   function vl_sym_lnr_key(PI_vl_sym_lnr varchar2)
   return varchar2;

   /**
      Access map to identify changed VL_TRADE_PERP_LNR values
      Return combined VL_TRADE_PERP_LNR, if there is one
   */
   function vl_tr_pe_lnr_key(PI_vl_tr_pe_lnr varchar2)
   return varchar2;

   /**
      Access map to identify changed VL_STAMM_LAND_LNR values
      Return combined VL_STAMM_LAND_LNR, if there is one
   */
   function vl_st_la_lnr_key(PI_vl_st_la_lnr varchar2)
   return varchar2;

   /**
      Access map to identify changed VL_STAMM_KLA_LNR values
      Return combined VL_STAMM_KLA_LNR, if there is one
   */
   function vl_st_kl_lnr_key(PI_vl_st_kl_lnr varchar2)
   return varchar2;

   /**
      Access map to identify changed KURS_REF_LNR values
      Return combined KURS_REF_LNR, if there is one
   */
   function kurs_ref_lnr_key(PI_kurs_ref_lnr varchar2)
   return varchar2;

   /**
      Defines a named set of tables to work with
      Set needs to be passed separated by commas
   */
   procedure def_table_set(PI_table_set_name varchar2, PI_table_set varchar2);

   /**
      Define index column(s) to be used for a table in a table set
      If not set, the diff code will try to use the columns from a %C2 index, if present
   */
   procedure set_idx_cols(PI_table_set_name varchar2, PI_table_name varchar2, PI_idx_cols varchar2);

   /**
      Take a snapshot (physical copy) of all VDF related VL_* tables, register in sbapshot table
      If no table set is specified, the previously used one is taken, or the default 'VDF' one if none was previously used
   */
   procedure snapshot(
      PI_tag       varchar2 := to_char(sysdate, 'yyyymmdd_hh24miss')
     ,PI_table_set varchar2 := null
   );

   /**
      Delete a snapshot (physical copy) of all VDF related VL_* tables
   */
   procedure del_snapshot(PI_tag varchar2);

   /**
      Restore a backup snapshot (physical copy) of all VDF related VL_* tables back into original tables
   */
   procedure restore_snapshot(PI_tag varchar2);

   /**
      Truncate all VDF related VL_* tables
   */
   procedure truncate_tables;

   /**
      Disable all triggers on all VDF related VL_* tables
   */
   procedure disable_triggers;

   /**
      Enable all triggers on all VDF related VL_* tables
   */
   procedure enable_triggers;

   /**
      Disable text generation (set all PRG_PAR)
   */
   procedure disable_text_gen;

   /**
      Enable text generation (set all PRG_PAR)
   */
   procedure enable_text_gen;

   /**
      Disable CA import (set PRG_PAR)
   */
   procedure disable_ca_imp;

   /**
      Enable CA import (set PRG_PAR)
   */
   procedure enable_ca_imp;

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

   /**
      return => the revision of the package.
   */
   function F_Revision
   return char;

end vlqdiff0;
/


CREATE OR REPLACE package body V0LDATI2.vlqdiff0 as

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
   --
   g_vl_lnr_map       t_lnr_map;
   g_vl_ref_lnr_map   t_lnr_map;
   g_vl_bo_pl_lnr_map t_lnr_map;
   g_vl_st_gs_lnr_map t_lnr_map;
   g_vl_cl_sy_lnr_map t_lnr_map;
   g_vl_sym_lnr_map   t_lnr_map;
   g_vl_tr_pe_lnr_map t_lnr_map;
   g_vl_st_la_lnr_map t_lnr_map;
   g_vl_st_kl_lnr_map t_lnr_map;
   g_kurs_ref_lnr_map t_lnr_map;


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
         ALQMSG00.Msg_Error('table_exists', sqlerrm, $$PLSQL_UNIT); raise;
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
         delete from vl_table_set where set_name = :tset
      ' using PI_table_set_name;
      --
      l_table_tab := str_split(PI_table_set, ',');
      for idx in 1 .. l_table_tab.count loop
         execute immediate '
            insert into vl_table_set (set_name, table_name, seq_nr) values(:tset, upper(:tab), :nr)
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
         update vl_table_set
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
         update vl_table_set
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
      create_table('vl_snapshot',
                   'timestp date, set_name varchar2(1000), tag varchar2(100), nr number');
      create_table('vl_table_set',
                   'set_name varchar2(1000), table_name varchar2(4000), seq_nr number, do_skip varchar2(1), idx_cols varchar(1000)');
      create_table('vl_diff',
                   'status varchar2(7), set_name varchar2(1000), diff varchar2(2000), table_name varchar2(4000), key_flds varchar2(4000), key varchar2(4000), field varchar2(1000), old_val varchar2(4000), new_val varchar2(4000)');
      create_table('vl_diff_log',
                   'timestp timestamp, title varchar2(4000), ctx clob, stack clob');

      -- create aggregating result view
      execute immediate q'{
         create or replace force view vl_diff_ov as
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
                  from vl_diff
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
            from vl_diff vvd
            group by diff, set_name, table_name, status
         )
      }';

      -- initialise default VDF table set
      def_table_set('VDF',
         'vl_bo_platz
         ,vl_clear_sys
         ,vl_eust
         ,vl_eust_betrag
         ,vl_eust_land
         ,vl_fonds_kom
         ,vl_fonds_mkm
         ,vl_fonds_subsc
         ,vl_gsch
         ,vl_gsch_rating
         ,vl_kurs_akt
         ,vl_ref
         ,vl_regu_kla
         ,vl_regu_kla_det
         ,vl_stamm
         ,vl_stamm_fonds
         ,vl_stamm_gsch
         ,vl_stamm_kla
         ,vl_stamm_land
         ,vl_stamm_rating
         ,vl_stamm_strkt
         ,vl_sym
         ,vl_text
         ,vl_trade_perp'
      );
      set_do_skip('VDF', 'vl_text'); -- Tabelle wird sehr gross bei Kunden
      set_idx_cols('VDF', 'vl_kurs_akt', 'kurs_ref_lnr,kurs_anw_cd,bo_platz_lnr,wrg_lnr,userbk_nr');

   exception
      when others then
         ALQMSG00.Msg_Error('init', sqlerrm, $$PLSQL_UNIT); raise;
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
      time_log('Initialise table set '||PI_table_set_name);
      if not table_exists('vl_snapshot') then
         init;
      end if;
      g_table_list.delete;
      g_table_excp_list.delete;
      g_current_table_set := PI_table_set_name;
      begin
         execute immediate '
            select table_name, do_skip, idx_cols
              from vl_table_set
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
         -- if none, and we have a real table, use columns from C2 index
         if l_ts_tab(i).idx_cols is not null then
            g_table_key_tab(l_ts_tab(i).table_name) := l_ts_tab(i).idx_cols;
         else
            if table_exists(l_ts_tab(i).table_name) then
               select listagg(column_name, ',') within group (order by column_position)
                 into g_table_key_tab(l_ts_tab(i).table_name)
                 from user_ind_columns
                where table_name = upper(l_ts_tab(i).table_name)
                  and index_name like '%C2'
               group by table_name;
            end if;
         end if;
      end loop;
   end init_table_set;


    --------------------------------------------------------------------------------
   procedure set_vl_lnr_map(PI_lnr_map t_lnr_map)
   is
   begin
      g_vl_lnr_map := PI_lnr_map;
   end set_vl_lnr_map;


   --------------------------------------------------------------------------------
   procedure set_vl_ref_lnr_map(PI_lnr_map t_lnr_map)
   is
   begin
      g_vl_ref_lnr_map := PI_lnr_map;
   end set_vl_ref_lnr_map;


   --------------------------------------------------------------------------------
   procedure set_vl_bo_pl_lnr_map(PI_lnr_map t_lnr_map)
   is
   begin
      g_vl_bo_pl_lnr_map := PI_lnr_map;
   end set_vl_bo_pl_lnr_map;


   --------------------------------------------------------------------------------
   procedure set_vl_st_gs_lnr_map(PI_lnr_map t_lnr_map)
   is
   begin
      g_vl_st_gs_lnr_map := PI_lnr_map;
   end set_vl_st_gs_lnr_map;


   --------------------------------------------------------------------------------
   procedure set_vl_cl_sy_lnr_map(PI_lnr_map t_lnr_map)
   is
   begin
      g_vl_cl_sy_lnr_map := PI_lnr_map;
   end set_vl_cl_sy_lnr_map;


   --------------------------------------------------------------------------------
   procedure set_vl_sym_lnr_map(PI_lnr_map t_lnr_map)
   is
   begin
      g_vl_sym_lnr_map := PI_lnr_map;
   end set_vl_sym_lnr_map;


   --------------------------------------------------------------------------------
   procedure set_vl_tr_pe_lnr_map(PI_lnr_map t_lnr_map)
   is
   begin
      g_vl_tr_pe_lnr_map := PI_lnr_map;
   end set_vl_tr_pe_lnr_map;


   --------------------------------------------------------------------------------
   procedure set_vl_st_la_lnr_map(PI_lnr_map t_lnr_map)
   is
   begin
      g_vl_st_la_lnr_map := PI_lnr_map;
   end set_vl_st_la_lnr_map;


   --------------------------------------------------------------------------------
   procedure set_vl_st_kl_lnr_map(PI_lnr_map t_lnr_map)
   is
   begin
      g_vl_st_kl_lnr_map := PI_lnr_map;
   end set_vl_st_kl_lnr_map;


   --------------------------------------------------------------------------------
   procedure set_kurs_ref_lnr_map(PI_lnr_map t_lnr_map)
   is
   begin
      g_kurs_ref_lnr_map := PI_lnr_map;
   end set_kurs_ref_lnr_map;


   --------------------------------------------------------------------------------
   function vl_lnr_key(PI_vl_lnr varchar2)
   return varchar2
   is
   begin
      if g_vl_lnr_map.exists(PI_vl_lnr) then
         return g_vl_lnr_map(PI_vl_lnr);
      else
         return PI_vl_lnr;
      end if;
   end vl_lnr_key;


   --------------------------------------------------------------------------------
   function vl_ref_lnr_key(PI_vl_ref_lnr varchar2)
   return varchar2
   is
   begin
      if g_vl_ref_lnr_map.exists(PI_vl_ref_lnr) then
         return g_vl_ref_lnr_map(PI_vl_ref_lnr);
      else
         return PI_vl_ref_lnr;
      end if;
   end vl_ref_lnr_key;


   --------------------------------------------------------------------------------
   function vl_bo_pl_lnr_key(PI_vl_bo_pl_lnr varchar2)
   return varchar2
   is
   begin
      if g_vl_bo_pl_lnr_map.exists(PI_vl_bo_pl_lnr) then
         return g_vl_bo_pl_lnr_map(PI_vl_bo_pl_lnr);
      else
         return PI_vl_bo_pl_lnr;
      end if;
   end vl_bo_pl_lnr_key;


   --------------------------------------------------------------------------------
   function vl_st_gs_lnr_key(PI_vl_st_gs_lnr varchar2)
   return varchar2
   is
   begin
      if g_vl_st_gs_lnr_map.exists(PI_vl_st_gs_lnr) then
         return g_vl_st_gs_lnr_map(PI_vl_st_gs_lnr);
      else
         return PI_vl_st_gs_lnr;
      end if;
   end vl_st_gs_lnr_key;


   --------------------------------------------------------------------------------
   function vl_cl_sy_lnr_key(PI_vl_cl_sy_lnr varchar2)
   return varchar2
   is
   begin
      if g_vl_cl_sy_lnr_map.exists(PI_vl_cl_sy_lnr) then
         return g_vl_st_gs_lnr_map(PI_vl_cl_sy_lnr);
      else
         return PI_vl_cl_sy_lnr;
      end if;
   end vl_cl_sy_lnr_key;


   --------------------------------------------------------------------------------
   function vl_sym_lnr_key(PI_vl_sym_lnr varchar2)
   return varchar2
   is
   begin
      if g_vl_sym_lnr_map.exists(PI_vl_sym_lnr) then
         return g_vl_sym_lnr_map(PI_vl_sym_lnr);
      else
         return PI_vl_sym_lnr;
      end if;
   end vl_sym_lnr_key;


   --------------------------------------------------------------------------------
   function vl_tr_pe_lnr_key(PI_vl_tr_pe_lnr varchar2)
   return varchar2
   is
   begin
      if g_vl_tr_pe_lnr_map.exists(PI_vl_tr_pe_lnr) then
         return g_vl_tr_pe_lnr_map(PI_vl_tr_pe_lnr);
      else
         return PI_vl_tr_pe_lnr;
      end if;
   end vl_tr_pe_lnr_key;


   --------------------------------------------------------------------------------
   function vl_st_la_lnr_key(PI_vl_st_la_lnr varchar2)
   return varchar2
   is
   begin
      if g_vl_st_la_lnr_map.exists(PI_vl_st_la_lnr) then
         return g_vl_st_la_lnr_map(PI_vl_st_la_lnr);
      else
         return PI_vl_st_la_lnr;
      end if;
   end vl_st_la_lnr_key;


   --------------------------------------------------------------------------------
   function vl_st_kl_lnr_key(PI_vl_st_kl_lnr varchar2)
   return varchar2
   is
   begin
      if g_vl_st_kl_lnr_map.exists(PI_vl_st_kl_lnr) then
         return g_vl_st_kl_lnr_map(PI_vl_st_kl_lnr);
      else
         return PI_vl_st_kl_lnr;
      end if;
   end vl_st_kl_lnr_key;


   --------------------------------------------------------------------------------
   function kurs_ref_lnr_key(PI_kurs_ref_lnr varchar2)
   return varchar2
   is
   begin
      if g_kurs_ref_lnr_map.exists(PI_kurs_ref_lnr) then
         return g_kurs_ref_lnr_map(PI_kurs_ref_lnr);
      else
         return PI_kurs_ref_lnr;
      end if;
   end kurs_ref_lnr_key;


   --------------------------------------------------------------------------------
   procedure time_log(PI_title varchar2, PI_ctx clob)
   is
      pragma autonomous_transaction;
   begin
      execute immediate '
         insert into vl_diff_log (timestp, title, ctx, stack) values (
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
         if table_exists('vl_diff_log') then
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
         from vl_snapshot
         where tag = :tag'
      into l_cnt
      using PI_tag;
      --
      return (nvl(l_cnt, 0) > 0);
   exception
      when others then
         ALQMSG00.Msg_Error('snapshot_exists', sqlerrm, $$PLSQL_UNIT); raise;
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
            execute immediate 'delete from vl_snapshot where tag = :tag' using PI_tag;
         exception
            when no_data_found then time_log('No snapshot registration found to delete');
            when others        then time_log('Unexpected exception: '||sqlerrm);
         end;
      end if;
   exception
      when others then
         ALQMSG00.Msg_Error('del_snapshot', sqlerrm, $$PLSQL_UNIT); raise;
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
         ALQMSG00.Msg_Error('table_disable_triggers', sqlerrm, $$PLSQL_UNIT); raise;
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
         ALQMSG00.Msg_Error('table_enable_triggers', sqlerrm, $$PLSQL_UNIT); raise;
   end table_enable_triggers;


   --------------------------------------------------------------------------------
   procedure restore_snapshot(PI_tag varchar2)
   is
      l_table_name      t_table_name;
      l_bkup_table_name t_table_name;
      l_stmt            clob;
   begin
      time_log('---- START RESTORE SNAPSHOT '||PI_tag||'----');
      l_table_name := g_table_key_tab.first;
      while l_table_name is not null loop
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
         ALQMSG00.Msg_Error('restore_snapshot', sqlerrm, $$PLSQL_UNIT); raise;
   end restore_snapshot;


   --------------------------------------------------------------------------------
   procedure truncate_tables
   is
      l_table_name      t_table_name;
   begin
      time_log('---- START TRUNCATING TABLES ----');
      l_table_name := g_table_key_tab.first;
      while l_table_name is not null loop
         time_log('truncate table '||l_table_name);
         execute immediate 'truncate table '||l_table_name;
         --
         l_table_name := g_table_key_tab.next(l_table_name);
      end loop;
      time_log('---- END TRUNCATING TABLES ----');
   exception
      when others then
         ALQMSG00.Msg_Error('truncate_tables', sqlerrm, $$PLSQL_UNIT); raise;
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
      table_disable_triggers('VL_TEXT');
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
      table_enable_triggers('VL_TEXT');
      time_log('---- END ENABLING TRIGGERS ----');
   end enable_triggers;


   --------------------------------------------------------------------------------
   procedure disable_text_gen
   is
   begin
      -- back up par_wert into feld_bez (unused)
      update sr1prg_par
      set feld_bez = par_wert
      where prg_id = 'WV'
      and par_id in ('AUTOTEXTGEN', 'GENVLKURZTEXT', 'GENVLABRETEXT', 'GENVLAUSZTEXT')
      and userbk_nr = userbk_nr;

      -- set PRG PAR
      update sr1prg_par
      set par_wert = 'N'
      where prg_id = 'WV'
      and par_id in ('AUTOTEXTGEN', 'GENVLKURZTEXT', 'GENVLABRETEXT', 'GENVLAUSZTEXT')
      and userbk_nr = userbk_nr;

      commit;
   exception
      when others then
         ALQMSG00.Msg_Error('disable_text_gen', sqlerrm, $$PLSQL_UNIT); raise;
   end disable_text_gen;


   --------------------------------------------------------------------------------
   procedure enable_text_gen
   is
   begin
      -- restore par_wert from feld_bez (or leave alone)
      update sr1prg_par
      set par_wert = nvl(feld_bez, par_wert)
      where prg_id = 'WV'
      and par_id in ('AUTOTEXTGEN', 'GENVLKURZTEXT', 'GENVLABRETEXT', 'GENVLAUSZTEXT')
      and userbk_nr = userbk_nr;

      -- delete feld_bez
      update sr1prg_par
      set feld_bez = null
      where prg_id = 'WV'
      and par_id in ('AUTOTEXTGEN', 'GENVLKURZTEXT', 'GENVLABRETEXT', 'GENVLAUSZTEXT')
      and userbk_nr = userbk_nr;

      commit;
   exception
      when others then
         ALQMSG00.Msg_Error('enable_text_gen', sqlerrm, $$PLSQL_UNIT); raise;
   end enable_text_gen;


   --------------------------------------------------------------------------------
   procedure disable_ca_imp
   is
   begin
      -- back up par_wert into feld_bez (unused)
      update sr1prg_par
      set feld_bez = par_wert
      where prg_id = 'WV'
      and par_id = 'VDFIMPCA'
      and userbk_nr = userbk_nr;

      -- set PRG PAR
      update sr1prg_par
      set par_wert = 'N'
      where prg_id = 'WV'
      and par_id = 'VDFIMPCA'
      and userbk_nr = userbk_nr;

      commit;
   exception
      when others then
         ALQMSG00.Msg_Error('disable_ca_imp', sqlerrm, $$PLSQL_UNIT); raise;
   end disable_ca_imp;


   --------------------------------------------------------------------------------
   procedure enable_ca_imp
   is
   begin
      -- restore par_wert from feld_bez (or leave alone)
      update sr1prg_par
      set par_wert = nvl(feld_bez, par_wert)
      where prg_id = 'WV'
      and par_id = 'VDFIMPCA'
      and userbk_nr = userbk_nr;

      -- delete feld_bez
      update sr1prg_par
      set feld_bez = null
      where prg_id = 'WV'
      and par_id = 'VDFIMPCA'
      and userbk_nr = userbk_nr;

      commit;
   exception
      when others then
         ALQMSG00.Msg_Error('enable_ca_imp', sqlerrm, $$PLSQL_UNIT); raise;
   end enable_ca_imp;


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
      l_stmt := 'select distinct tag from vl_snapshot';
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
      ora_drop('table', 'vl_snapshot');
      ora_drop('view',  'vl_diff_ov');
      ora_drop('table', 'vl_diff');
      ora_drop('table', 'vl_table_set');

      -- clean up memory state
      g_current_table_set := null;

      time_log('---- END CLEANUP ----');
   exception
      when others then
         ALQMSG00.Msg_Error('cleanup', sqlerrm, $$PLSQL_UNIT); raise;
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
         from   vl_snapshot'
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
               time_log('Could not create table '||l_bkup_table_name||' using statement: '||l_stmt);
         end;
         --
         l_table_name := g_table_key_tab.next(l_table_name);
      end loop;
      --
      execute immediate '
         insert into vl_snapshot(timestp, tag, nr, set_name)
         values(:timestp, :tag, :nr, :tset)'
         using l_timestp, PI_tag, l_nr, l_table_set
      ;
      commit;
      time_log('---- END SNAPSHOT '||PI_tag||' of table set '||l_table_set||' ----');
   exception
      when others then
         ALQMSG00.Msg_Error('snapshot', sqlerrm, $$PLSQL_UNIT); raise;
   end snapshot;


   --------------------------------------------------------------------------------
   function map_column(PI_col_name varchar2)
   return varchar2
   is
      l_result       varchar2(1000);
   begin
      if substr(PI_col_name, 1, 6) = 'VL_LNR' then
         l_result := 'vlqdiff0.vl_lnr_key(' || PI_col_name || ') '       || PI_col_name;
      elsif substr(PI_col_name, 1, 10) = 'VL_REF_LNR' then
         l_result := 'vlqdiff0.vl_ref_lnr_key(' || PI_col_name || ') ' || PI_col_name;
      elsif substr(PI_col_name, 1, 15) = 'VL_BO_PLATZ_LNR' then
         l_result := 'vlqdiff0.vl_bo_pl_lnr_key(' || PI_col_name || ') ' || PI_col_name;
      elsif substr(PI_col_name, 1, 17) = 'VL_STAMM_GSCH_LNR' then
         l_result := 'vlqdiff0.vl_st_gs_lnr_key(' || PI_col_name || ') ' || PI_col_name;
      elsif substr(PI_col_name, 1, 16) = 'VL_CLEAR_SYS_LNR' then
         l_result := 'vlqdiff0.vl_cl_sy_lnr_key(' || PI_col_name || ') ' || PI_col_name;
      elsif substr(PI_col_name, 1, 10) = 'VL_SYM_LNR' then
         l_result := 'vlqdiff0.vl_sym_lnr_key(' || PI_col_name || ') '   || PI_col_name;
      elsif substr(PI_col_name, 1, 17) = 'VL_TRADE_PERP_LNR' then
         l_result := 'vlqdiff0.vl_tr_pe_lnr_key(' || PI_col_name || ') ' || PI_col_name;
      elsif substr(PI_col_name, 1, 17) = 'VL_STAMM_LAND_LNR' then
         l_result := 'vlqdiff0.vl_st_la_lnr_key(' || PI_col_name || ') ' || PI_col_name;
      elsif substr(PI_col_name, 1, 16) = 'VL_STAMM_KLA_LNR' then
         l_result := 'vlqdiff0.vl_st_kl_lnr_key(' || PI_col_name || ') ' || PI_col_name;
      elsif substr(PI_col_name, 1, 16) = 'KURS_REF_LNR' then
         l_result := 'vlqdiff0.kurs_ref_lnr_key(' || PI_col_name || ') ' || PI_col_name;
      else
         l_result := PI_col_name;
      end if;
      return l_result;
   end map_column;


   --------------------------------------------------------------------------------
   function table_columns(PI_table_name t_table_name, PI_quote boolean := false, PI_map boolean := true)
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
           from vl_table_set
          where set_name   = :tset
            and table_name = upper(:tab)
      '
      into l_idx_cols
      using g_current_table_set, PI_table_name;
      l_idx_col_list := str_split(l_idx_cols, ',');

      -- return table columns without A1 record and business primary key fields (C2 index) or custom key field(s)
      l_columns := l_quote;
      for c in (
         select utc.column_name
         into   l_columns
         from   user_tab_columns utc
         where  utc.table_name = upper(PI_table_name)
            and utc.column_name not in (
              'CREATE_DT',
              'CREATE_ID',
              'MUT_VON',
              'MUT_BIS',
              'KD_LNR_VIS',
              'LOG_LNR_MUT',
              'VERS_VOR',
              'STAT_CD',
              'USERBK_NR',
              'VERS'
            )
            and utc.column_name not in (
               select uic.column_name
               from   user_ind_columns uic
               where  uic.table_name = utc.table_name
               and    uic.index_name like '%C2'
            )
            and utc.column_name not in (
               select nvl(column_value, '[NULL]') from table(l_idx_col_list)
            )
         order by column_id
      ) loop
         -- skip custom index columns
         continue when instr(l_idx_cols, c.column_name) > 0;
         --
         if l_is_vdf and PI_map and not PI_quote then
            l_expr := map_column(c.column_name);
         else
            l_expr := c.column_name;
         end if;
         l_columns := l_columns || l_expr || l_quote||', '||l_quote;
      end loop;
      l_columns := substr(l_columns, 1, (length(l_columns) - 2 - 2 * nvl(length(l_quote), 0))) || l_quote;
      --
      return l_columns;
   exception
      when others then
         ALQMSG00.Msg_Error('table_columns', sqlerrm, $$PLSQL_UNIT); raise;
   end table_columns;

   --------------------------------------------------------------------------------
   function table_pkey(PI_table_name t_table_name)
   return varchar2
   is
      l_pkey         varchar2(4000);
      l_column_name  t_column_name;
      l_expr         varchar2(1000);
      c              sys_refcursor;
      l_idx          varchar2(3) := '%C2';
      l_idx_cols     varchar2(4000);
      l_idx_col_list SRCVARCHAR2_TABLE_SQL := SRCVARCHAR2_TABLE_SQL();
   begin
      -- Get index column override, if set
      execute immediate '
         select idx_cols
           from vl_table_set
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
      else
         open c for '
            select column_name
            from   user_ind_columns
            where  table_name = upper(:tab)
            and    index_name like :idx'
            using PI_table_name, l_idx
         ;
      end if;

      loop
         fetch c into l_column_name;
         exit when c%notfound;
         --
         if substr(l_column_name, 1, 6) = 'VL_LNR' then
            l_expr := 'vlqdiff0.vl_lnr_key(' || l_column_name || ')';
         elsif substr(l_column_name, 1, 10) = 'VL_REF_LNR' then
            l_expr := 'vlqdiff0.vl_ref_lnr_key(' || l_column_name || ')';
         elsif substr(l_column_name, 1, 15) = 'VL_BO_PLATZ_LNR' then
            l_expr := 'vlqdiff0.vl_bo_pl_lnr_key(' || l_column_name || ')';
         elsif substr(l_column_name, 1, 17) = 'VL_STAMM_GSCH_LNR' then
            l_expr := 'vlqdiff0.vl_st_gs_lnr_key(' || l_column_name || ')';
         elsif substr(l_column_name, 1, 16) = 'VL_CLEAR_SYS_LNR' then
            l_expr := 'vlqdiff0.vl_cl_sy_lnr_key(' || l_column_name || ')';
         elsif substr(l_column_name, 1, 10) = 'VL_SYM_LNR' then
            l_expr := 'vlqdiff0.vl_sym_lnr_key(' || l_column_name || ')';
         elsif substr(l_column_name, 1, 17) = 'VL_TRADE_PERP_LNR' then
            l_expr := 'vlqdiff0.vl_tr_pe_lnr_key(' || l_column_name || ')';
         elsif substr(l_column_name, 1, 17) = 'VL_STAMM_LAND_LNR' then
            l_expr := 'vlqdiff0.vl_st_la_lnr_key(' || l_column_name || ')';
         elsif substr(l_column_name, 1, 16) = 'VL_STAMM_KLA_LNR' then
            l_expr := 'vlqdiff0.vl_st_kl_lnr_key(' || l_column_name || ')';
         elsif substr(l_column_name, 1, 16) = 'KURS_REF_LNR' then
            l_expr := 'vlqdiff0.kurs_ref_lnr_key(' || l_column_name || ')';
         else
            l_expr := l_column_name;
         end if;
         l_pkey := l_pkey || l_expr || q'{) || ' | ' || to_char(}';
      end loop;
      l_pkey := substr(l_pkey, 1, length(l_pkey) - 22) || ')';
      --
      return l_pkey;
   exception
      when others then
         ALQMSG00.Msg_Error('table_pkey', sqlerrm, $$PLSQL_UNIT); raise;
   end table_pkey;


   --------------------------------------------------------------------------------
   procedure build_lnr_maps(PI_tag1 varchar2, PI_tag2 varchar2)
   is
      l_stmt clob;
   begin
      -- build up maps for VL_LNRs, VL_BO_PLATZ_LNRs and VL_REF_LNRs that have changed between snapshots
      l_stmt := q'{
         declare
            l_vl_lnr_map vlqdiff0.t_lnr_map;
            l_vl_lnr_key vlqdiff0.t_lnr_key;
            --
            l_vl_bo_pl_lnr_map vlqdiff0.t_lnr_map;
            l_vl_bo_pl_lnr_key vlqdiff0.t_lnr_key;
            --
            l_vl_ref_lnr_map vlqdiff0.t_lnr_map;
            l_vl_ref_lnr_key vlqdiff0.t_lnr_key;
         begin
            for c in (
               select distinct t1.vl_nr, t1.vl_sub_nr, t1.vl_lnr lnr_1, t2.vl_lnr lnr_2
                              ,tbo1.vl_bo_platz_lnr boplnr_1, tbo2.vl_bo_platz_lnr boplnr_2
                              ,tref1.vl_ref_lnr reflnr_1, tref2.vl_ref_lnr reflnr_2
               from   vl_stamm__}'   ||PI_tag1||q'{ t1, vl_stamm__}'     ||PI_tag2||q'{ t2
                     ,vl_bo_platz__}'||PI_tag1||q'{ tbo1, vl_bo_platz__}'||PI_tag2||q'{ tbo2
                     ,vl_ref__}'     ||PI_tag1||q'{ tref1, vl_ref__}'    ||PI_tag2||q'{ tref2
               where  t1.vl_nr          = t2.vl_nr
                  and t1.vl_sub_nr      = t2.vl_sub_nr
                  and t1.userbk_nr      = t2.userbk_nr
                  and t1.vl_lnr        != t2.vl_lnr
                  --
                  and tbo1.vl_lnr       = t1.vl_lnr
                  and tbo1.userbk_nr    = t1.userbk_nr
                  and tbo2.vl_lnr       = t2.vl_lnr
                  and tbo2.userbk_nr    = t2.userbk_nr
                  and tbo1.bo_platz_lnr = tbo2.bo_platz_lnr
                  and tbo1.userbk_nr    = tbo2.userbk_nr
                  --
                  and tref1.vl_lnr        = t1.vl_lnr
                  and tref1.userbk_nr     = t1.userbk_nr
                  and tref2.vl_lnr        = t2.vl_lnr
                  and tref2.userbk_nr     = t2.userbk_nr
            )
            loop
               l_vl_lnr_key := least(c.lnr_1, c.lnr_2) || '/' || greatest(c.lnr_1, c.lnr_2);
               l_vl_lnr_map(c.lnr_1) := l_vl_lnr_key;
               l_vl_lnr_map(c.lnr_2) := l_vl_lnr_key;
               vlqdiff0.time_log('Entry '||c.vl_nr||'.'||c.vl_sub_nr||' has two vl_lnr: '||l_vl_lnr_key);
               --
               l_vl_bo_pl_lnr_key := least(c.boplnr_1, c.boplnr_2) || '/' || greatest(c.boplnr_1, c.boplnr_2);
               l_vl_bo_pl_lnr_map(c.boplnr_1) := l_vl_bo_pl_lnr_key;
               l_vl_bo_pl_lnr_map(c.boplnr_2) := l_vl_bo_pl_lnr_key;
               vlqdiff0.time_log('Entry '||c.vl_nr||'.'||c.vl_sub_nr||' has two vl_bo_platz_lnr: '||l_vl_bo_pl_lnr_key);
               --
               l_vl_ref_lnr_key := least(c.reflnr_1, c.reflnr_2) || '/' || greatest(c.reflnr_1, c.reflnr_2);
               l_vl_ref_lnr_map(c.reflnr_1) := l_vl_ref_lnr_key;
               l_vl_ref_lnr_map(c.reflnr_2) := l_vl_ref_lnr_key;
               vlqdiff0.time_log('Entry '||c.vl_nr||'.'||c.vl_sub_nr||' has two vl_ref_lnr: '||l_vl_ref_lnr_key);
            end loop;
            vlqdiff0.set_vl_lnr_map(l_vl_lnr_map);
            vlqdiff0.set_vl_bo_pl_lnr_map(l_vl_bo_pl_lnr_map);
            vlqdiff0.set_vl_ref_lnr_map(l_vl_ref_lnr_map);
         end;}';
      execute immediate l_stmt;

      -- build up map for VL_STAMM_GSCH_LNRs that have changed between snapshots
      l_stmt := q'{
         declare
            l_vl_st_gs_lnr_map vlqdiff0.t_lnr_map;
            l_vl_st_gs_lnr_key vlqdiff0.t_lnr_key;
            --
            l_vl_cl_sy_lnr_map vlqdiff0.t_lnr_map;
            l_vl_cl_sy_lnr_key vlqdiff0.t_lnr_key;
         begin
            for c in (
               select distinct t1.vl_nr, t1.vl_sub_nr
                              ,t1.vl_lnr lnr_1, t2.vl_lnr lnr_2
                              ,tgs1.vl_stamm_gsch_lnr gslnr_1, tgs2.vl_stamm_gsch_lnr gslnr_2
                              ,tcs1.vl_clear_sys_lnr cslnr_1, tcs2.vl_clear_sys_lnr cslnr_2
               from   vl_stamm__}'     ||PI_tag1||q'{ t1, vl_stamm__}'       ||PI_tag2||q'{ t2
                     ,vl_stamm_gsch__}'||PI_tag1||q'{ tgs1, vl_stamm_gsch__}'||PI_tag2||q'{ tgs2
                     ,vl_clear_sys__}' ||PI_tag1||q'{ tcs1, vl_clear_sys__}' ||PI_tag2||q'{ tcs2
               where  t1.vl_nr            = t2.vl_nr
                  and t1.vl_sub_nr        = t2.vl_sub_nr
                  and t1.userbk_nr        = t2.userbk_nr
                  and t1.vl_lnr          != t2.vl_lnr
                  --
                  and tgs1.vl_lnr         = t1.vl_lnr
                  and tgs1.userbk_nr      = t1.userbk_nr
                  and tgs2.vl_lnr         = t2.vl_lnr
                  and tgs2.userbk_nr      = t2.userbk_nr
                  and tgs1.vl_gsch_lnr    = tgs2.vl_gsch_lnr
                  and tgs1.vl_gsch_zuw_cd = tgs2.vl_gsch_zuw_cd
                  --
                  and tcs1.vl_stamm_gsch_lnr (+) = tgs1.vl_stamm_gsch_lnr
                  and tcs1.userbk_nr         (+) = tgs1.userbk_nr
                  and tcs2.vl_stamm_gsch_lnr (+) = tgs2.vl_stamm_gsch_lnr
                  and tcs2.userbk_nr         (+) = tgs2.userbk_nr
                  --
                  and nvl(tcs1.clear_sys_cd, '(NULL)') = nvl(tcs2.clear_sys_cd, '(NULL)')
            )
            loop
               l_vl_st_gs_lnr_key := least(c.gslnr_1, c.gslnr_2) || '/' || greatest(c.gslnr_1, c.gslnr_2);
               l_vl_st_gs_lnr_map(c.gslnr_1) := l_vl_st_gs_lnr_key;
               l_vl_st_gs_lnr_map(c.gslnr_2) := l_vl_st_gs_lnr_key;
               vlqdiff0.time_log('Entry '||c.vl_nr||'.'||c.vl_sub_nr||' has two vl_stamm_gsch_lnr: '||l_vl_st_gs_lnr_key);
               --
               if c.cslnr_1 is not null and c.cslnr_2 is not null then
                  l_vl_cl_sy_lnr_key := least(c.cslnr_1, c.cslnr_2) || '/' || greatest(c.cslnr_1, c.cslnr_2);
                  l_vl_cl_sy_lnr_map(c.cslnr_1) := l_vl_cl_sy_lnr_key;
                  l_vl_cl_sy_lnr_map(c.cslnr_2) := l_vl_cl_sy_lnr_key;
                  vlqdiff0.time_log('Entry '||c.vl_nr||'.'||c.vl_sub_nr||' has two vl_clear_sys_lnr: '||l_vl_cl_sy_lnr_key);
               end if;
            end loop;
            vlqdiff0.set_vl_st_gs_lnr_map(l_vl_st_gs_lnr_map);
            vlqdiff0.set_vl_cl_sy_lnr_map(l_vl_cl_sy_lnr_map);
         end;}';
      execute immediate l_stmt;

      -- build up map for VL_SYM_LNRs that have changed between snapshots
      l_stmt := q'{
         declare
            l_vl_sym_lnr_map vlqdiff0.t_lnr_map;
            l_vl_sym_lnr_key vlqdiff0.t_lnr_key;
         begin
            for c in (
               select distinct t1.vl_nr, t1.vl_sub_nr, t1.vl_lnr lnr_1, t2.vl_lnr lnr_2, tsy1.vl_sym_lnr sylnr_1, tsy2.vl_sym_lnr sylnr_2
               from   vl_stamm__}'||PI_tag1||q'{ t1, vl_stamm__}'||PI_tag2||q'{ t2
                     ,vl_sym__}'  ||PI_tag1||q'{ tsy1, vl_sym__}'||PI_tag2||q'{ tsy2
               where  t1.vl_nr            = t2.vl_nr
                  and t1.vl_sub_nr        = t2.vl_sub_nr
                  and t1.userbk_nr        = t2.userbk_nr
                  and t1.vl_lnr          != t2.vl_lnr
                  --
                  and tsy1.vl_lnr         = t1.vl_lnr
                  and tsy1.userbk_nr      = t1.userbk_nr
                  and tsy2.vl_lnr         = t2.vl_lnr
                  and tsy2.userbk_nr      = t2.userbk_nr
                  and tsy1.vl_sym_bez     = tsy2.vl_sym_bez
            )
            loop
               l_vl_sym_lnr_key := least(c.sylnr_1, c.sylnr_2) || '/' || greatest(c.sylnr_1, c.sylnr_2);
               l_vl_sym_lnr_map(c.sylnr_1) := l_vl_sym_lnr_key;
               l_vl_sym_lnr_map(c.sylnr_2) := l_vl_sym_lnr_key;
               vlqdiff0.time_log('Entry '||c.vl_nr||'.'||c.vl_sub_nr||' has two vl_sym_lnr: '||l_vl_sym_lnr_key);
            end loop;
            vlqdiff0.set_vl_sym_lnr_map(l_vl_sym_lnr_map);
         end;}';
      execute immediate l_stmt;

      -- build up map for VL_TRADE_PERP_LNRs that have changed between snapshots
      l_stmt := q'{
         declare
            l_vl_tr_pe_lnr_map vlqdiff0.t_lnr_map;
            l_vl_tr_pe_lnr_key vlqdiff0.t_lnr_key;
         begin
            for c in (
               select distinct t1.vl_nr, t1.vl_sub_nr, t1.vl_lnr lnr_1, t2.vl_lnr lnr_2, ttp1.vl_trade_perp_lnr tplnr_1, ttp2.vl_trade_perp_lnr tplnr_2
               from   vl_stamm__}'     ||PI_tag1||q'{ t1, vl_stamm__}'       ||PI_tag2||q'{ t2
                     ,vl_trade_perp__}'||PI_tag1||q'{ ttp1, vl_trade_perp__}'||PI_tag2||q'{ ttp2
               where  t1.vl_nr              = t2.vl_nr
                  and t1.vl_sub_nr          = t2.vl_sub_nr
                  and t1.userbk_nr          = t2.userbk_nr
                  and t1.vl_lnr            != t2.vl_lnr
                  --
                  and ttp1.vl_lnr           = t1.vl_lnr
                  and ttp1.userbk_nr        = t1.userbk_nr
                  and ttp2.vl_lnr           = t2.vl_lnr
                  and ttp2.userbk_nr        = t2.userbk_nr
                  and ttp1.vl_trade_krit_cd = ttp2.vl_trade_krit_cd
            )
            loop
               l_vl_tr_pe_lnr_key := least(c.tplnr_1, c.tplnr_2) || '/' || greatest(c.tplnr_1, c.tplnr_2);
               l_vl_tr_pe_lnr_map(c.tplnr_1) := l_vl_tr_pe_lnr_key;
               l_vl_tr_pe_lnr_map(c.tplnr_2) := l_vl_tr_pe_lnr_key;
               vlqdiff0.time_log('Entry '||c.vl_nr||'.'||c.vl_sub_nr||' has two vl_trade_perp_lnr: '||l_vl_tr_pe_lnr_key);
            end loop;
            vlqdiff0.set_vl_tr_pe_lnr_map(l_vl_tr_pe_lnr_map);
         end;}';
      execute immediate l_stmt;

      -- build up map for VL_STAMM_LAND_LNRs that have changed between snapshots
      l_stmt := q'{
         declare
            l_vl_st_la_lnr_map vlqdiff0.t_lnr_map;
            l_vl_st_la_lnr_key vlqdiff0.t_lnr_key;
         begin
            for c in (
               select distinct t1.vl_nr, t1.vl_sub_nr, t1.vl_lnr lnr_1, t2.vl_lnr lnr_2, tsl1.vl_stamm_land_lnr sllnr_1, tsl2.vl_stamm_land_lnr sllnr_2
               from   vl_stamm__}'     ||PI_tag1||q'{ t1, vl_stamm__}'       ||PI_tag2||q'{ t2
                     ,vl_stamm_land__}'||PI_tag1||q'{ tsl1, vl_stamm_land__}'||PI_tag2||q'{ tsl2
               where  t1.vl_nr              = t2.vl_nr
                  and t1.vl_sub_nr          = t2.vl_sub_nr
                  and t1.userbk_nr          = t2.userbk_nr
                  and t1.vl_lnr            != t2.vl_lnr
                  --
                  and tsl1.vl_lnr           = t1.vl_lnr
                  and tsl1.userbk_nr        = t1.userbk_nr
                  and tsl2.vl_lnr           = t2.vl_lnr
                  and tsl2.userbk_nr        = t2.userbk_nr
                  and tsl1.vl_land_zuw_cd   = tsl2.vl_land_zuw_cd
                  and tsl1.land_lnr         = tsl2.land_lnr
            )
            loop
               l_vl_st_la_lnr_key := least(c.sllnr_1, c.sllnr_2) || '/' || greatest(c.sllnr_1, c.sllnr_2);
               l_vl_st_la_lnr_map(c.sllnr_1) := l_vl_st_la_lnr_key;
               l_vl_st_la_lnr_map(c.sllnr_2) := l_vl_st_la_lnr_key;
               vlqdiff0.time_log('Entry '||c.vl_nr||'.'||c.vl_sub_nr||' has two vl_stamm_land_lnr: '||l_vl_st_la_lnr_key);
            end loop;
            vlqdiff0.set_vl_st_la_lnr_map(l_vl_st_la_lnr_map);
         end;}';
      execute immediate l_stmt;

      -- build up map for VL_STAMM_KLA_LNRs that have changed between snapshots
      l_stmt := q'{
         declare
            l_vl_st_kl_lnr_map vlqdiff0.t_lnr_map;
            l_vl_st_kl_lnr_key vlqdiff0.t_lnr_key;
         begin
            for c in (
               select distinct t1.vl_nr, t1.vl_sub_nr, t1.vl_lnr lnr_1, t2.vl_lnr lnr_2, tsk1.vl_stamm_kla_lnr sklnr_1, tsk2.vl_stamm_kla_lnr sklnr_2
               from   vl_stamm__}'    ||PI_tag1||q'{ t1, vl_stamm__}'      ||PI_tag2||q'{ t2
                     ,vl_stamm_kla__}'||PI_tag1||q'{ tsk1, vl_stamm_kla__}'||PI_tag2||q'{ tsk2
               where  t1.vl_nr              = t2.vl_nr
                  and t1.vl_sub_nr          = t2.vl_sub_nr
                  and t1.userbk_nr          = t2.userbk_nr
                  and t1.vl_lnr            != t2.vl_lnr
                  --
                  and tsk1.vl_lnr           = t1.vl_lnr
                  and tsk1.userbk_nr        = t1.userbk_nr
                  and tsk2.vl_lnr           = t2.vl_lnr
                  and tsk2.userbk_nr        = t2.userbk_nr
                  and tsk1.vl_kla_typ_cd    = tsk2.vl_kla_typ_cd
            )
            loop
               l_vl_st_kl_lnr_key := least(c.sklnr_1, c.sklnr_2) || '/' || greatest(c.sklnr_1, c.sklnr_2);
               l_vl_st_kl_lnr_map(c.sklnr_1) := l_vl_st_kl_lnr_key;
               l_vl_st_kl_lnr_map(c.sklnr_2) := l_vl_st_kl_lnr_key;
               vlqdiff0.time_log('Entry '||c.vl_nr||'.'||c.vl_sub_nr||' has two vl_stamm_kla_lnr: '||l_vl_st_kl_lnr_key);
            end loop;
            vlqdiff0.set_vl_st_kl_lnr_map(l_vl_st_kl_lnr_map);
         end;}';
      execute immediate l_stmt;

      -- build up map for KURS_REF_LNRs that have changed between snapshots
      l_stmt := q'{
         declare
            l_kurs_ref_lnr_map vlqdiff0.t_lnr_map;
            l_kurs_ref_lnr_key vlqdiff0.t_lnr_key;
         begin
            for c in (
               select distinct t1.vl_nr, t1.vl_sub_nr, t1.vl_lnr lnr_1, t2.vl_lnr lnr_2, tka1.kurs_ref_lnr krlnr_1, tka2.kurs_ref_lnr krlnr_2
               from   vl_stamm__}'    ||PI_tag1||q'{ t1, vl_stamm__}'      ||PI_tag2||q'{ t2
                     ,vl_ref__}'      ||PI_tag1||q'{ tr1, vl_ref__}'       ||PI_tag2||q'{ tr2
                     ,vl_kurs_akt__}' ||PI_tag1||q'{ tka1, vl_kurs_akt__}' ||PI_tag2||q'{ tka2
               where  t1.vl_nr              = t2.vl_nr
                  and t1.vl_sub_nr          = t2.vl_sub_nr
                  and t1.userbk_nr          = t2.userbk_nr
                  and t1.vl_lnr            != t2.vl_lnr
                  --
                  and tr1.vl_lnr            = t1.vl_lnr
                  and tr1.userbk_nr         = t1.userbk_nr
                  and tr2.vl_lnr            = t2.vl_lnr
                  and tr2.userbk_nr         = t2.userbk_nr
                  --
                  and tka1.kurs_ref_lnr     = tr1.vl_ref_lnr
                  and tka1.userbk_nr        = tr1.userbk_nr
                  and tka2.kurs_ref_lnr     = tr2.vl_ref_lnr
                  and tka2.userbk_nr        = tr2.userbk_nr
            )
            loop
               l_kurs_ref_lnr_key := least(c.krlnr_1, c.krlnr_2) || '/' || greatest(c.krlnr_1, c.krlnr_2);
               l_kurs_ref_lnr_map(c.krlnr_1) := l_kurs_ref_lnr_key;
               l_kurs_ref_lnr_map(c.krlnr_2) := l_kurs_ref_lnr_key;
               vlqdiff0.time_log('Entry '||c.vl_nr||'.'||c.vl_sub_nr||' has two kurs_ref_lnr: '||l_kurs_ref_lnr_key);
            end loop;
            vlqdiff0.set_kurs_ref_lnr_map(l_kurs_ref_lnr_map);
         end;}';
      execute immediate l_stmt;
   exception
      when others then
         ALQMSG00.Msg_Error('build_lnr_maps', sqlerrm, $$PLSQL_UNIT); raise;
   end build_lnr_maps;


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
      l_table_col_tab    srcvarchar2_table_sql;
      l_field            varchar2(200);
      l_table_pkey       varchar2(1000);
      --
      pragma autonomous_transaction;
   begin
      time_log('---- START DIFF '||PI_tag1||' vs. '||PI_tag2||' ----');
      -- check if snapshots exist and were created on the same table set
      execute immediate '
         select count(*), count(distinct set_name)
         from vl_snapshot
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
         from vl_snapshot
         where tag = :tag1'
         into l_set_name
         using PI_tag1;
      if g_current_table_set is null or l_set_name != g_current_table_set then
         init_table_set(l_set_name);
      end if;

      -- delete older results, if any
      execute immediate q'{
         delete from vl_diff
         where diff = :tag1||'/'||:tag2}'
         using PI_tag1, PI_tag2;
      commit;

      -- for VDF tables, build before/after maps for LNR fields that are regenerated upon re-import
      -- this allows to recognize reimported data and treat it as 'modified'
      if g_current_table_set = 'VDF' then
         build_lnr_maps(PI_tag1, PI_tag2);
      end if;

      -- loop over all VDF related tables
      for idx in g_table_list.first .. g_table_list.last loop
         -- skip tables in exception list
         continue when g_table_excp_list.exists(g_table_list(idx));
         l_table_base_name  := g_table_list(idx);
         l_tab1_name        := l_table_base_name || '__' || PI_tag1;
         l_tab2_name        := l_table_base_name || '__' || PI_tag2;

         l_table_columns    := table_columns(l_table_base_name);
         l_table_q_columns  := table_columns(l_table_base_name, PI_quote => true);
         l_table_nomap_cols := table_columns(l_table_base_name, PI_map => false);
         l_table_col_tab    := srqitem0.f_split(l_table_nomap_cols, ', ');
         l_table_pkey       := table_pkey(l_table_base_name);
         if l_table_pkey is null then
            time_log('Skipping table '||l_table_base_name||': No custom key columns defined, no C2 index columns found');
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
                        insert into vl_diff(status, diff, set_name, table_name, key_flds, key, field, old_val, new_val)
                        values ('NEW', l_diff, l_set_name, l_table_base_name, '}'||g_table_key_tab(l_table_base_name)||q'{', c.pkey, '(ALL)', null, null);
                     when '--' then
                        insert into vl_diff(status, diff, set_name, table_name, key_flds, key, field, old_val, new_val)
                        values ('DEL', l_diff, l_set_name, l_table_base_name, '}'||g_table_key_tab(l_table_base_name)||q'{', c.pkey, '(ALL)', null, null);
                     when 'M' then
                        case c.version
                           when 'old' then}'||chr(13);
         for i in l_table_col_tab.first .. l_table_col_tab.last loop
            l_field := l_table_col_tab(i);
            l_stmt  := l_stmt || q'{                              l_fld_diff_tab('}'||l_field||q'{').old_val := to_char(c.}'||l_field||q'{);}'||chr(13);
         end loop;
         l_stmt := l_stmt || q'{                           when 'new' then}'||chr(13);
         for i in l_table_col_tab.first .. l_table_col_tab.last loop
            l_field := l_table_col_tab(i);
            l_stmt  := l_stmt || q'{                              l_fld_diff_tab('}'||l_field||q'{').new_val := to_char(c.}'||l_field||q'{);}'||chr(13);
         end loop;
         l_stmt := l_stmt || q'{                              --
                              -- new comes after old, so now we can compare
                              l_idx := l_fld_diff_tab.first;
                              while l_idx is not null loop
                                 if nvl(l_fld_diff_tab(l_idx).old_val, '(NULL)') != nvl(l_fld_diff_tab(l_idx).new_val, '(NULL)') then
                                    insert into vl_diff(status, diff, set_name, table_name, key_flds, key, field, old_val, new_val)
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
         time_log('Error in Diff calc, generated code in CTX', l_stmt);
         ALQMSG00.Msg_Error('calc_diff(1)', sqlerrm, $$PLSQL_UNIT); raise;
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
            from   vl_snapshot
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
         ALQMSG00.Msg_Error('calc_diff(2)', sqlerrm, $$PLSQL_UNIT); raise;
   end calc_diff;


   ----------------------------------------------------------------------------------------------------------------------
   /**
      return => the revision of the package.
   */
   function F_Revision return char is
   begin
      return('$Revision: 1.11 $');
   end F_Revision;

begin
   init;
end VLQDIFF0;
/
