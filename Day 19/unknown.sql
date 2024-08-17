with
  decision_tree (step_name,decision_order, var,op,comp_value, next_step) as (
    select 'in', 1, 's', '<', 1531, 'ps'
  ), compare_objects (id, x,m,a, s ) as (
    select 2, 1679,	44,	2067,	496
  ),  logic_gate as (
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
    end < to_number(comp_value) then next_step
  when op = '=' and
    case
      when var = 'x' then x
      when var = 'm' then m
      when var = 'a' then a
      when var = 's' then s
    end = to_number(comp_value) then next_step
  when op = '>' and
    case
      when var = 'x' then x
      when var = 'm' then m
      when var = 'a' then a
      when var = 's' then s
    end > to_number(comp_value) then next_step
end actual_next_step

from d19_objects a
 ,d19_decisions b
--where b. step_name = 'in'
order by part#, decision_order
)


select * from logic_gate
where part# = 2 and step_name = 'in';
select a.*, b.*

from compare_objects a, decision_tree b;

