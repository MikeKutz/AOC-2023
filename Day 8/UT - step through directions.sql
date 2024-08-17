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
    select q'[LLR

AAA = (BBB, BBB)
BBB = (AAA, ZZZ)
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
), follow_tomtom ( direction_list, current_location, current_step, next_turn, use_me) as (
  select ad.my_gps
    ,'AAA'
    ,1
    ,get_directions( 1, ad.my_gps )
    ,1
  from all_directions ad
  union all
  select f.direction_list
    ,decode(f.next_turn, 'L', g.next_left, g.next_right )
    ,current_step + 1
    ,get_directions( current_step + 1, f.direction_list )
    ,mod(current_step, length(a.my_gps)) +1
  from follow_tomtom f
        join locations g on f.current_location = g.area_location
    ,all_directions a
  where current_location != 'ZZZ' and current_location is not null and current_step < 5
) cycle current_location, use_me set is_cycle to '1' default '0'
select *
from follow_tomtom;
