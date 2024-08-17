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
), plant_maps as (
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
), seeds as (
  select rownum as seed_rn, to_number(M.column_value) seed#
  from block_parse d
    cross apply apex_string.split( regexp_replace(d.block_txt, '[^0-9]+$', null), chr(10) ) L
    cross apply apex_string.split( trim( L.column_value ), ' ' ) M
  where rn = 2 and ( L.column_value is not null and M.column_value is not null)
), map_traversal (seed#, start#, end#, this_step) as (
select seed#, seed# start#
  ,nvl(s2s.dest_start + (seed# - s2s.source_start), seed# ) end#
  ,1
from seeds s
  left outer join (select * from plant_maps where step# = 1 ) s2s
    on s.seed# between s2s.source_start and s2s.source_end
union all
select seed#, s.end# start#
  ,nvl(s2s.dest_start + (s.end# - s2s.source_start), s.end# ) end#
  ,nullif( s.this_step + 1, 8 )
from map_traversal s
  outer apply (select * from plant_maps p where s.this_step is not null and p.step# = s.this_step + 1
    and s.end# between p.source_start and p.source_end ) s2s
)
cycle start#, this_step set is_cycle to '1' default '0'
,final_planting as (
  select * from (
    select seed#, end#, this_step
    from map_traversal
    where this_step <= 7
  )
  pivot ( min(end#)
    for this_step in ( 1 as soild, 2 as ferilizer, 3 as water, 4 as light, 5 as temperature, 6 as huidity, 7 as location_final )
  )
)
select * from final_planting;