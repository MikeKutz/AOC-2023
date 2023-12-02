/*
 table e2023_2 has 1 row per pull of cubes
 game_id, game#, set#, red, green, blue

  cross apply apex_string.split was used to extracte data
  validation step showed only red, green, blue colors being used
  pivot command followed by nvl( ,0) -- can it be part of the pivot?
*/
 
 create domain day2_d as ( -- only a concern for Part 1
  red as int not null,
  green as int not null,
  blue as int not null
)
constraint check ( red between 0 and 12
                  and green between 0 and 13
                  and blue between 0 and 14 )
;

select sum( decode(is_valid, true, game#) ) part1
      ,sum( prod ) part2
from (
  select game#
        ,boolean_and_agg( domain_check( day2_d, red, green, blue ) ) is_valid
        ,max( red ) * max( green ) * max( blue ) prod
  from e2023_2
  group by game#
);


 
 