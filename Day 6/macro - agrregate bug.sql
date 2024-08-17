create or replace
function product( P in  number ) return varchar2
  sql_macro(scalar)
as
begin
  return '( EXP(SUM(LN( P ))) )'; -- fails
--  return '( sum(LN( P )) )';      -- fails
--  return '( LN( P ) )';          -- works
end;
/

select a, product( d.T ) as abc
from (
  select 1 a, 5 T union all
  select 1, 6
) d
group by a;

with data ( T ) as (
  select 5 T union all
  select 6
)
select product( d.t ) 
from data d;

-- expected
select EXP(SUM(LN( t )))
from (
  select 5 T union all
  select 6
);

create or replace function show_date(p_value  date)
  return varchar2 sql_macro(scalar)
is
begin
  return q'{ to_char(p_value, 'YYYY-MM-DD') }';
end;
/


select show_date(sysdate) as my_date from dual;
