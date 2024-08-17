with
  function extract_value( stack apex_t_number, i int ) return number
  as
  begin
    if stack is null then return null; end if;
    if stack.count < 6 then return null; end if;
    
    return stack(i);
  end;
  input_data(txt) as (
    select q'[19, 13, 30 @ -2,  1, -2
18, 19, 22 @ -1, -1, -2
20, 25, 34 @ -2, -2, -4
12, 31, 28 @ -1, -2, -1
20, 19, 15 @  1, -5, -3]'
),
  parsed_data as (
    select rownum rn, apex_string.split_numbers(
        regexp_replace( translate(trim(b.column_value),',@', '  '), ' +', ' ' )
        , ' '
      ) txt
    from input_data a
      cross apply apex_string.split( a.txt, chr(10) ) b
    where trim(b.column_value) is not null
  ), raw_data as (
    select a.rn
        ,extract_value(a.txt,1) X_start
        ,extract_value(a.txt,2) Y_start
        ,extract_value(a.txt,3) Z_start
        ,extract_value(a.txt,4) v_X
        ,extract_value(a.txt,5) v_Y
        ,extract_value(a.txt,6) v_Z
    from parsed_data a
  ), calculated_data as (
    select b.*
        -- convert to m(X) + b
        --    m = v(y) / v(X)
        --    b = Y / (m * X )
        ,b.v_Y / b.v_X slope
        ,Y_start / ( X_start * v_Y / v_x) b_intersect
    from raw_data b
  )
select i.*
from (
  select d1.rn rn_1
    ,d2.rn rn_2
    ,d1.slope slope_1
    ,d2.slope slope_2
    ,( - d1.b_intersect + d2.b_intersect ) / ( d1.slope - d2.slope ) intersect_t -- this is wrong
  from calculated_data d1, calculated_data d2
  where d1.rn < d2.rn 
    and  d1.slope != d2.slope
) i
--where i.intersect_t >= 0
;
/

select * from user_domains;
select * from user_domain_constraints where domain_name ='DOES_OVERLAP';

