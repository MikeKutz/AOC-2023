with
  input_data (rn, data_line) as (
    select rownum rn, trim(column_value)
    from apex_string.split(q'[R 6 (#70c710)
D 5 (#0dc571)
L 2 (#5713f0)
D 2 (#d2c081)
R 2 (#59c680)
D 2 (#411b91)
L 5 (#8ceee2)
U 2 (#caa173)
L 1 (#1b58a2)
U 2 (#caa171)
R 2 (#7807d2)
U 3 (#a77fa3)
L 2 (#015232)
U 2 (#7a21e3)
]', chr(10))
    where trim(column_value) is not null
  ), parsed_txt (rn, dig_direction, dig_length, color_code) as (
    select rn
          ,substr(data_line, 1, 1) as dig_direction
          ,substr(data_line, 3,instr(data_line, ' ', 1, 2) - 3) as dig_length
          ,substr(data_line, instr(data_line, ' ', 1, 2) + 2, 7) as color_code
    from input_data
  ), polygon_points (rn, x, y, z, color_code) as (
    select 0 rn, 0 x, 0 y, 0 z, '#000000' color_code
    from dual
    union all
    select a.rn + 1
          ,case b.dig_direction
            when 'R' then a.x + b.dig_length
            when 'L' then a.x - b.dig_length
            else a.x
          end
          ,case b.dig_direction
            when 'U' then a.y + b.dig_length
            when 'D' then a.y - dig_length
            else a.y
          end
          ,a.z
          ,b.color_code
    from polygon_points a
      join parsed_txt b on (a.rn+1)=b.rn
  )
select *
from polygon_points

    