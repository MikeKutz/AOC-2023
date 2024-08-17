with
  inputdata (txt) as (
    select q'[RL

AAA = (BBB, CCC)
BBB = (DDD, EEE)
CCC = (ZZZ, GGG)
DDD = (DDD, DDD)
EEE = (EEE, EEE)
GGG = (GGG, GGG)
ZZZ = (ZZZ, ZZZ)]'
  ),raw_directions (rn, direction) as (
    select rownum rn, trim(d.column_value)
    from inputdata i
           cross apply apex_string.split( trim(substr(i.txt,1, instr(txt,chr(10),1,1) - 1)), null ) d
           
), all_directions (my_gps) as (
  select trim(substr(i.txt,1, instr(txt,chr(10),1,1) - 1))
  from inputdata i
), raw_locations (rn, area_location, next_left, next_right) as (
    select rownum rn
      ,substr(d.column_value,1,3)
      ,substr(d.column_value,8,3)
      ,substr(d.column_value,13,3)
    from inputdata i
           cross apply apex_string.split( trim(substr(i.txt, instr(txt,chr(10),1,2) + 1)), chr(10) ) d
), locations as (
  select * from raw_locations
)
select * from  all_directions