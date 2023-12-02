select sum(distinct game#) from (
select *
from e2023_2 g
where g.game# not in (
  select distinct game#
  from e2023_2 j
  where not ( red <= 12 and green <= 13 and blue <= 14 )
)
);