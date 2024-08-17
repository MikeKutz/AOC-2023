with
  inputdata (txt) as (
    -- AoC 2023 Day 8 Part 1 Example 1
    select q'[LR

AAA = (BBB, BBB)
BBB = (AAA, ZZZ)
ZZZ = (ZZZ, ZZZ)]'
  ), locations (rn, area_location, next_left, next_right) as (
    -- extract Location and Next (left|right) Location
    select rownum rn
      ,substr(d.column_value,1,3)
      ,substr(d.column_value,8,3)
      ,substr(d.column_value,13,3)
    from inputdata i
           cross apply apex_string.split( trim(substr(i.txt, instr(txt,chr(10),1,2) + 1)), chr(10) ) d
), ut_locations as (
  -- Unit Test all Locations are of the expected form
  select l.*
    ,domain_check( D8_LOCATION_D, area_location ) is_current_valid
    ,domain_check( D8_LOCATION_D, next_left ) is_left_valid
    ,domain_check( D8_LOCATION_D, next_right ) is_right_valid
    ,domain_check( D8_LOCATION_D, area_location ) is true
     and domain_check( D8_LOCATION_D, next_left ) is true
     and domain_check( D8_LOCATION_D, next_right ) is true are_all_valid
  from locations l
  where domain_check( D8_LOCATION_D, next_right ) is true -- this part IS TRUE (odd ...)
)
-- copy+paste for UT_LOCATIONS to compare CTE and non-CTE ussage of DOMAIN_CHECK
select l.*
  ,domain_check( D8_LOCATION_D, area_location ) is_current_valid
  ,domain_check( D8_LOCATION_D, next_left ) is_left_valid
  ,domain_check( D8_LOCATION_D, next_right ) is_right_valid
  ,domain_check( D8_LOCATION_D, area_location ) is true
   and domain_check( D8_LOCATION_D, next_left ) is true
   and domain_check( D8_LOCATION_D, next_right ) is true are_all_valid
from locations l
union all
select * from ut_locations
/
