with
  function get_directions( step# in int, full_directions in varchar2 ) return varchar2
  as
    directions varchar2(1);
    n int;
    l int;
  begin
    -- direction# := mod( step#, length ); if 0 then length
    n := nvl(nullif(mod( step#, length(full_directions)),0), length(full_directions) );
    
    directions := substr( full_directions, n, 1 );
    
    return directions;
  end;
  inputdata (txt) as (
    select q'[RLLLR

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
select get_directions( i.lv, ad.my_gps )
from  all_directions ad
    ,(select level lv from dual connect by level <=10 ) i