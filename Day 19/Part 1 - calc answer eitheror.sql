with
  get_answers (part#, step_name, x,m,a,s,actual_next_step, i) as (
    select a.*, 1
    from d19_tree a
    where step_name = 'in'
    union all
    select a.part#
      ,b.step_name
      ,a.x, a.m, a.a, a.s
      ,b.actual_next_step
      ,a.i + 1
    from get_answers a
      join d19_tree b on a.actual_next_step = b.step_name
        and a.part# = b.part#
  )
select a.*, x+m+a+s  answer
from get_answers a
where part# = 2
--where actual_next_step = 'A'
order by part#, i;

-- in
-- qqz
-- qs
-- lnx
-- A -- stopping signal



select *
from d19_tree
where part# = 2
--and step_name = 'in'
;
-- PROBLEM CHILD IS HERE
-- 1679	44	2067	496
-- s < 1351 : px 
-- qqz
select * from d19_decisions
where step_name = 'in';

select part#, step_name
from d19_tree
group by part#, step_name
having count(*) > 1;