with
  data_input (txt) as (
    select q'[OOOO.#.O..
OO..#....#
OO..O##..O
O..#.OO...
........#.
..#....#.#
..O..#.O.O
..O.......
#....###..
#....#....
]'
  ), parsed_map  as (
    select row_number() over (order by r.rn, s.rn) rn
      ,s.rn x
      ,r.rn y
      ,s.txt symbol_txt
    from data_input i
      cross apply (select rownum rn, trim(a.column_value) txt
                  from apex_string.split(i.txt, chr(10) ) a
                  where trim(a.column_value) is not null) r
      cross apply (select rownum rn, trim(b.column_value) txt
                  from apex_string.split(r.txt, null) b
                  where trim(b.column_value) is not null) s
    where s.txt != '.'
), map_stats (block_width,block_len) as (
  select max(x),max(y) from parsed_map
), cube_rocks as (
  select * from parsed_map where symbol_txt='#'
), round_rocks as (
  select * from parsed_map where symbol_txt='O'
), tilt_north as (
  select rn
      ,x
      ,y + row_number() over (partition by x,y order by rn) y
      ,symbol_txt
  from (
  select a.rn, a.x, max(nvl(b.y,0)) y, a.symbol_txt
  from round_rocks a
    left join cube_rocks b
      on a.x=b.x and a.y > b.y
  group by a.rn, a.x, a.symbol_txt
  )
)
select sum(mass) from (
  select t.y, s.block_len - (t.y - 1) mass
  from tilt_north t, map_stats s
)