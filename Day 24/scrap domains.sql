create domain is_integer as number
  check ( is_integer = trunc(is_integer) );

create domain is_integer_strict as integer strict;


with
  test_data (val) as (
    select -1 union all
    select -1.234 union all
    select -50 union all
    select 50 union all
    select 0 union all
    select 1e6 union all
    select 2.99e8 union all
    select 3.14159
  )
select val
  ,domain_check( is_integer, val) is_integer
  ,domain_check( is_integer_strict, val) is_strict_integer
from test_data;

create or replace
function h (n number) return integer
  authid current_user
as
  m integer;
begin
  <<assert_input>>
  declare
    b boolean;
  begin
    -- Mind the Scope
    select domain_check( is_integer, n ) into assert_input.b;
    
    if not assert_input.b
    then
      raise_application_error( -20000, 'Not an INTEGER' );
    end if;
  end;
  
  <<actual_code>>
  m := n;
  return m;
end;
/
set serveroutput on;
exec dbms_output.put_line( h(12) );
exec dbms_output.put_line( h(3.14159) );
exec dbms_output.put_line( h( null ) );
