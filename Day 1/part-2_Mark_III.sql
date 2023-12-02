with trans_tab (num, num_str) as (
  select level, to_char(level)
  from dual
  where true
    connect by level < 10
  union all
  select level, replace( to_char( to_date( level, 'yyyy' ), 'year'), '-', null )
  from dual
  where true
    connect by level < 100
  union all
  select 0, '0'
  union all
  select 0, 'zero'
), find_num_pos (rn, str, num, num_str, occurance, pos, max_count) as (
  select d.rn, d.str, t.num, t.num_str
    ,1 occurance
    ,regexp_instr( d.str, t.num_str ) pos
    ,regexp_count( d.str, t.num_str ) max_count
  from e2023_1 d, trans_tab t
  where regexp_count( d.str, t.num_str ) > 0
    and d.rn <= 10
  union all
  select p.rn, p.str, p.num, p.num_str
    ,p.occurance + 1
    ,regexp_instr( p.str, p.num_str, 1, p.occurance + 1 ) pos
    ,p.max_count
  from find_num_pos p
  where occurance + 1 <= max_count
)
select rn, str
      ,listagg( to_char( num, 'fm90' ) ) within group (order by pos) full_number
from find_num_pos
group by rn, str
order by rn
