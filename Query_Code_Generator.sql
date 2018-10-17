declare
   l_query    varchar2(4000);
   l_code     clob;
   l_cursor   pls_integer := dbms_sql.open_cursor;
   l_desc_tab dbms_sql.desc_tab2;
   l_col_cnt  pls_integer;
   l_col_name dba_tab_columns.column_name%type;
   l_col_type varchar2(100);
begin
   l_query := 'select * from vl_stamm';
   dbms_sql.parse(l_cursor, l_query, dbms_sql.native);
   dbms_sql.describe_columns2(l_cursor, l_col_cnt, l_desc_tab);
   --
   l_code := '
   /* 
      Generated code to run query '''||l_query||'''
   */
   declare
      type t_result_rec is record(';
   for i in 1 .. l_col_cnt loop
      l_col_name := l_desc_tab(i).col_name;
      l_col_type := case l_desc_tab(i).col_type
         when 1 then case l_desc_tab(i).col_charsetform when 2 then 'NVARCHAR2' else 'VARCHAR2' end 
                  || case when l_desc_tab(i).col_max_len > 0 then '(' || l_desc_tab(i).col_max_len || ')' else null end
         when 2 then case when l_desc_tab(i).col_scale is null then (case when l_desc_tab(i).col_precision is null then 'NUMBER' else 'FLOAT' end) else 'NUMBER' end 
                  || case when l_desc_tab(i).col_precision > 0 then '(' || l_desc_tab(i).col_precision  
                                                                 || case when l_desc_tab(i).col_scale > 0 then ',' || l_desc_tab(i).col_scale else null end || ')'
                          else null end
         when 8 then  'LONG'
         when 9 then  case l_desc_tab(i).col_charsetform when 2 then 'NCHAR VARYING' else 'VARCHAR' end
                   || case when l_desc_tab(i).col_precision > 0 then '(' || l_desc_tab(i).col_precision || ')' else null end
         when 12 then  'DATE'
         when 23 then  'RAW'
         when 24 then  'LONG RAW'
         when 58 then  '??SYNOBJ_58'
         when 69 then  'ROWID'
         when 96 then  case l_desc_tab(i).col_charsetform when 2 then 'NCHAR' else 'CHAR' end
                    || case when l_desc_tab(i).col_precision > 0 then '(' || l_desc_tab(i).col_precision || ')' else null end
         when 100 then  'BINARY_FLOAT'
         when 101 then  'BINARY_DOUBLE'
         when 105 then  'MLSLABEL'
         when 106 then  'MLSLABEL'
         when 111 then  '??SYNOBJ_111'
         when 112 then  case l_desc_tab(i).col_charsetform when 2 then 'NCLOB' else 'CLOB' end
         when 113 then  'BLOB'
         when 114 then  'BFILE'
         when 115 then  'CFILE'
         when 121 then  '??SYNOBJ_121'
         when 122 then  '??SYNOBJ_122'
         when 123 then  '??SYNOBJ_123'
         when 178 then  'TIME(' || l_desc_tab(i).col_scale || ')'
         when 179 then  'TIME(' || l_desc_tab(i).col_scale || ')' || ' WITH TIME ZONE'
         when 180 then  'TIMESTAMP(' || l_desc_tab(i).col_scale || ')'
         when 181 then  'TIMESTAMP(' || l_desc_tab(i).col_scale || ')' || ' WITH TIME ZONE'
         when 231 then  'TIMESTAMP(' || l_desc_tab(i).col_scale || ')' || ' WITH LOCAL TIME ZONE'
         when 182 then  'INTERVAL YEAR(' || l_desc_tab(i).col_precision || ') TO MONTH'
         when 183 then  'INTERVAL DAY(' || l_desc_tab(i).col_precision || ') TO SECOND(' || l_desc_tab(i).col_scale || ')'
         when 208 then  'UROWID'
         else '??UNDEFINED'
      end;
      l_code := l_code || chr(13) || '         ' || lower(l_col_name) || ' ' || lower(l_col_type) || ', ';
   end loop;
   l_code := rtrim(l_code, ', ') || chr(13) || '      );';
   l_code := l_code || '
      type t_result_tab is table of t_result_rec index by pls_integer;
      --
      l_result_tab t_result_tab;
   begin
      select *
      bulk collect into l_result_tab
      from ('||l_query||');
      dbms_output.put_line(l_result_tab.count || '' rows selected'');
   end;'; 
   dbms_output.put_line(l_code);
   dbms_sql.close_cursor(l_cursor);
end;
