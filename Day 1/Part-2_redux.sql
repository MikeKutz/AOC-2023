-- this version is supposed to recognize multi-digit words
-- still has problems with sixteen --> 616

with
  found_digits (rn, str, num, num_str, start_pos, found_pos) as (
    select x.rn, x.str, y.num, y.num_str, 1 start_pos, instr( x.str, y.num_str ) found_pos
    from e2023_1 x, full_conversion_table y
    where instr( x.str, y.num_str ) > 0
      and y.num_str between '0' and '9' -- limitor for Part 1
  union all
    select b.rn, b.str, b.num, b.num_str, b.found_pos+1 start_pos, instr( b.str, b.num_str, b.found_pos+1 ) found_pos
    from found_digits b
    where instr( b.str, b.num_str, b.found_pos+1 ) > 0
  ), pulled_numbers as (
    select str, listagg( to_char(num) ) within group (order by found_pos) num_full
    from found_digits
    group by str
  )
select sum( to_number(  substr( num_full,1,1) || substr( num_full,-1) ) ) answer
from pulled_numbers;

