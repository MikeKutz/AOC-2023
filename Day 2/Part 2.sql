select sum( max_red * max_green * max_blue ) answer
from (
select game#
      ,max( RED_max ) max_red
      ,max( GREEN_max ) max_green
      ,max( BLUE_max ) max_blue
from e2023_2
group by game#
);
