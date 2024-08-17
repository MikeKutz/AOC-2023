drop table if exists d19_tree purge;

--create table d19_tree as
with
  logic_gate as (
select a.*
  ,b.*
,case
  when var is null then next_step
  when op = '<' and
    case
      when var = 'x' then x
      when var = 'm' then m
      when var = 'a' then a
      when var = 's' then s
    end < comp_value then next_step
  when op = '=' and
    case
      when var = 'x' then x
      when var = 'm' then m
      when var = 'a' then a
      when var = 's' then s
    end = comp_value then next_step
  when op = '>' and
    case
      when var = 'x' then x
      when var = 'm' then m
      when var = 'a' then a
      when var = 's' then s
    end > comp_value then next_step
end actual_next_step

from d19_objects a
 ,d19_decisions b
--where b. step_name = 'in'
order by part#, decision_order
)
select *
from (
        select part#, x,m,a,s, decision_order, step_name, actual_next_step
        from logic_gate
) match_recognize (
  partition by part#, step_name
  order by decision_order
  measures
    first( x ) as x,
    first( m ) as m,
    first( a ) as a,
    first( s ) as s,
    first( actual_next_step ) actual_next_step
  pattern ( not_null any_row* $ )
  define
    not_null as actual_next_step is not null,
    any_row as 1=1
);
