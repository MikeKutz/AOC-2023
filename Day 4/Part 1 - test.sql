with line_data as (
 select rownum rn, trim(column_value) line_txt
from
apex_string.split( q'[Card 1: 41 48 83 86 17 | 83 86  6 31 17  9 48 53
Card 2: 13 32 20 16 61 | 61 30 68 82 17 32 24 19
Card 3:  1 21 53 59 44 | 69 82 63 72 16 21 14  1
Card 4: 41 92 73 84 69 | 59 84 76 51 58  5 54 83
Card 5: 87 83 26 28 32 | 88 30 70 12 93 22 82 36
Card 6: 31 18 13 56 72 | 74 77 10 23 35 67 36 11
]', chr(10) )
where trim(column_value) is not null
), parsed_data as (
select rn
  ,substr(line_txt,1,instr( line_txt, ':' ) + 1) id
  ,apex_string.split( trim(substr(line_txt,instr( line_txt, ':' ) + 1,instr( line_txt, '|' ) - instr( line_txt, ':' ) - 1 )), ' ' ) winning#
  ,apex_string.split( trim(substr(line_txt,instr( line_txt, '|' ) + 1 ) ), ' ' ) card#
from line_data
)
select  sum(power(2, nullif(cardinality( winning# multiset intersect card# ), 0 ) -1 ))  matches# from parsed_data;

select * from user_domains;