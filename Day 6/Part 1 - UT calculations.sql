with
  function quad_low( T int, d int) return number
  as
    A number := -1;
    B number := T;
    C number := -d;
    x number;
  begin
    x := least(  (-B - sqrt( B*B - 4*A*C) ) / (2*A)
                   ,(-B + sqrt( B*B - 4*A*C) ) / (2*A) );
    return trunc(x) + 1;
  end;
  function quad_high( T int, d int) return number
  as
    A number := -1;
    B number := T;
    C number := -d;
    x number;
  begin
    x := greatest(  (-B - sqrt( B*B - 4*A*C) ) / (2*A)
                   ,(-B + sqrt( B*B - 4*A*C) ) / (2*A) );
    return ceil(x) - 1;
  end;

data (entry#, t, "d") as (
  select 1,7,9 union all
  select 2,15,40 union all
  select 3,30,200
)
select d.*, quad_low( d.T, d."d" ) min, quad_high( d.T, d."d" ) max
  , quad_high( d.T, d."d" ) -  quad_low( d.T, d."d" ) + 1 safety
from data d;
