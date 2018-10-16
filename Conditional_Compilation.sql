create or replace package test_pkg is
   $if $$testing $then
      procedure proc1;
   $else
      procedure proc2;
   $end
end test_pkg;

create or replace package body test_pkg is
   procedure proc1 is
   begin
      null;
   end proc1;
   --
   procedure proc2 is
   begin
      null;
   end proc2;
end test_pkg;

alter package test_pkg compile PLSQL_CCFLAGS = 'testing:false' reuse settings;

begin 
   test_pkg.proc1; --> exception
end;

begin
   DBMS_Preprocessor.Print_Post_Processed_Source(
      Schema_Name => 'v0ldati2',
      Object_Type => 'PACKAGE',
      Object_Name => 'TEST_PKG'
       );
end;  --> Processed source in DBMS Output

alter package test_pkg compile PLSQL_CCFLAGS = 'testing:true' reuse settings;

begin 
   test_pkg.proc1; --> OK
end;

begin
   DBMS_Preprocessor.Print_Post_Processed_Source(
      Schema_Name => 'v0ldati2',
      Object_Type => 'PACKAGE',
      Object_Name => 'TEST_PKG'
      );
end;  --> Processed source in DBMS Output
