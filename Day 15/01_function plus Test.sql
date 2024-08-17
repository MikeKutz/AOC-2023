create or replace
function d15_conversion( s varchar2) return int
  deterministic
  authid current_user
as
  ret_value int := 0;
begin
  for i in 1 .. length( s )
  loop
    /*
    for each character:
      += ascii( c );
      *= 17;
      %= 256;
    */
    ret_value := ret_value + ascii( substr( s, i, 1) );
    ret_value := ret_value * 17;
    ret_value := mod(ret_value,256);
  end loop;
  
  return ret_value;
end;
/

select d15_conversion('HASH') val;

with
  data( rn, input_txt ) as (
    select rownum, trim(column_value)
    from apex_string.split( q'[rn=1,cm-,qp=3,cm=2,qp-,pc=4,ot=9,ab=5,pc-,pc=6,ot=7]', ',' )
    where trim(column_value) is not null
  )
select d.*
  , d15_conversion( d.input_txt) val
  ,sum(d15_conversion( d.input_txt)) over () sum_val
from data d