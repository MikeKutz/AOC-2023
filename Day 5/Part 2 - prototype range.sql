with block_parse as (
  select rownum rn, column_value block_txt
  from apex_string.split( q'[seeds: 79 14 55 13

seed-to-soil map:
50 98 2
52 50 48

soil-to-fertilizer map:
0 15 37
37 52 2
39 0 15

fertilizer-to-water map:
49 53 8
0 11 42
42 0 7
57 7 4

water-to-light map:
88 18 7
18 25 70

light-to-temperature map:
45 77 23
81 45 19
68 64 13

temperature-to-humidity map:
0 69 1
1 0 69

humidity-to-location map:
60 56 37
56 93 4
]', ':' ) a
), block_data_rows as (
  select d.rn as step#, rownum as row#, L.column_value row_str
  from block_parse d
    cross apply apex_string.split( regexp_replace(d.block_txt, '[^0-9]+$', null), chr(10) ) L
  where rn > 2 and L.column_value is not null
), gappy_plant_maps as (
  select step# - 2 as step#
        ,row_number() over (partition by step# order by row#) row#
        ,source_start
        ,source_start + range_length  - 1 source_end
        ,dest_start
        ,dest_start + range_length - 1 dest_end
        ,range_length
  from (
  select step#, row#, number#, num
  from block_data_rows r
      cross apply (select rownum number#, to_number(column_value) num
                    from apex_string.split( trim(r.row_str), ' ' )
                )
  )
  pivot (
    min(num)
    for number# in ( 1 as dest_start
                    ,2 as source_start
                    ,3 as range_length )
  )
), consolodated_islands as (
  select *
  from gappy_plant_maps
  match_recognize (
    partition by step# order by source_start
    measures
      first( source_start ) source_start,
      last( source_end ) source_end
    pattern ( strt next_row* )
    define
      next_row as source_start -1 = prev( source_end )
  )
), range_gaps as (
  select * from (
  select x.step#
    ,cast(null  as int) row#
    ,x.source_end + 1 source_start
    ,nvl(lead( source_start ) over (partition by step# order by source_start ) -1, 9e28) source_end
    ,x.source_end + 1 dest_start
    ,nvl(lead( source_start ) over (partition by step# order by source_start ) -1, 9e28) dest_end
    ,nvl(lead( source_start ) over (partition by step# order by source_start ) -1, 9e28)
     - x.source_end + 2 range_length
  from consolodated_islands x
  union all
  select step#
    ,cast(null  as int) row#
    ,0 , min(source_start) -1 
    ,0 , min(source_start) -1 
    , min(source_start) -1 
  from consolodated_islands
  group by step#
  order by step#, source_start
  ) where range_length >0
), plant_maps as (
  select * from range_gaps
  union all
  select * from gappy_plant_maps
  order by step#, source_start
), seeds as (
  select rownum as seed_rn, to_number(M.column_value) seed#, to_number(M.column_value) seed_end
  from block_parse d
    cross apply apex_string.split( regexp_replace(d.block_txt, '[^0-9]+$', null), chr(10) ) L
    cross apply apex_string.split( trim( L.column_value ), ' ' ) M
  where rn = 2 and ( L.column_value is not null and M.column_value is not null)
), map_traversal (seed#, source_start, source_end, dest_start, dest_end, this_step) as (
select seed#
  ,seed#     source_start
  ,seed_end  source_end
  ,s2s.dest_start + greatest( seed#, s2s.source_start ) - s2s.source_start
  ,s2s.dest_start + least( seed_end, s2s.source_end ) - s2s.source_start
  ,1
from seeds s
  left outer join (select * from plant_maps where step# = 1 ) s2s
    on s.seed# <= s2s.source_end and s.seed_end >= s2s.source_start
union all
select
   s.seed#
  ,s.dest_start
  ,s.dest_end
  ,s2s.dest_start + greatest( s.dest_start, s2s.source_start ) - s2s.source_start
  ,s2s.dest_start + least( s.dest_end, s2s.source_end ) - s2s.source_start
  ,nullif( s.this_step + 1, 8 )
from map_traversal s
  cross apply (select * from plant_maps p where s.this_step is not null and p.step# = s.this_step + 1) s2s
--where domain_check(does_overlap, s.end#, s.seed_end, s2s.source_start and s2s.source_end) is true
  where s.dest_start <= s2s.source_end and s.dest_end >= s2s.source_start
)
cycle source_start, source_end, this_step set is_cycle to '1' default '0'

select min(dest_start) answer
from map_traversal
where this_step = 7
;

select * from user_domain_constraints where domain_name='DOES_OVERLAP';
/

create or replace
function does_overlap_m( start_1 int, end_1 int,start_2 int, end_2 int) return varchar2
  sql_macro(scalar)
as
begin
  return q'[ 
  ( start_1 <= end_2 and end_1 >= start_2
  and start_1 is not null and start_2 is not null
  and end_1 is not null and end_2 is not null )
  ]';
end;
/