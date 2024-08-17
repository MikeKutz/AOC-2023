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

data as (
    select rownum rn, substr(trim(column_value), 10) row_txt
    from apex_string.split( q'[Time:      7  15   30
Distance:  9  40  200
]', chr(10) )
    where trim(column_value) is not null
), races (entry#, t, "d") as (
  select a.rn, a.T, b.distance
  from (
    select rownum rn, to_number( r.column_value ) T
    from data d
      cross apply apex_string.split( d.row_txt, ' ' )
                  multiset except distinct apex_t_varchar2( null ) R
    where d.rn = 1
  ) a
  join (
    select rownum rn, to_number( r.column_value ) distance
    from data d
      cross apply apex_string.split( d.row_txt, ' ' )
                  multiset except distinct apex_t_varchar2( null ) R
    where d.rn = 2
  ) b
  on a.rn = b.rn
)
   -- see SCALAR - AGGREGATE BUG
select EXP(SUM(LN( dd.safety ))) answer from (
select 0 nobody
--  ,d.*
--  ,quad_low( d.T, d."d" ) min
--  ,quad_high( d.T, d."d" ) max
  ,quad_high( d.T, d."d" ) -  quad_low( d.T, d."d" ) + 1 safety
from races d
) dd;
/
