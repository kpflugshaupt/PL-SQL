drop table kap_log;

create table kap_log(timestp timestamp, title varchar2(400), ctx clob, stack clob);

create index kap_log#i1 on kap_log(timestp desc);

create or replace procedure kap_do_log(
  i_title varchar2
 ,i_ctx   clob := null
) 
is
  pragma autonomous_transaction;
begin
  insert into kap_log values(
    systimestamp
   ,i_title
   ,i_ctx
   ,dbms_utility.format_error_stack || chr(10) ||
    dbms_utility.format_error_backtrace || chr(10) ||
    dbms_utility.format_call_stack
  );
  --
  commit;
end kap_do_log; 

-- call:  kap_do_log('Start VDF_Import_Prod');

-- query: select * from kap_log order by timestp desc;
