set serveroutput on;

create or replace
package d9_calculator
as
  function calc_diffs( dat in apex_t_number ) return apex_t_number
    deterministic;
  
  function is_zero( dat in apex_t_number ) return boolean
    deterministic;
  procedure to_string( dat in apex_t_number );
  
  procedure push_num( dat in out nocopy apex_t_number, n int );
  
end;
/

create or replace
package body d9_calculator
as
  function calc_diffs( dat in apex_t_number ) return apex_t_number
    deterministic
  as
    array_size int;
    ret_value  apex_t_number := new apex_t_number();
  begin
    if dat is null
    then
      dbms_output.put_line( 'NULL sent' );
      return new apex_t_number();
    end if;
    array_size := dat.count;

    if false
    then
      dbms_output.put_line( array_size || '  ' || dat.count || ' --- size array sent' );
      return new apex_t_number();
    end if;

    if array_size <= 0
    then
      dbms_output.put_line( '0 size array sent' );
      return new apex_t_number();
    end if;


    ret_value.extend(array_size - 1);
--    return new apex_t_number();
    
    
    for i in 1 .. (array_size-1)
    loop
      ret_value(i) := dat(i+1) - dat(i);
    end loop;
    
    return ret_value;
  end calc_diffs;
  
  function is_zero( dat in apex_t_number ) return boolean
    deterministic
  as
  begin
    for i in 1 .. dat.count -- indices of dat
    loop
      if dat(i) != 0
      then
        return false;
      end if;
    end loop;
    
    return true;
  end is_zero;
    
  procedure to_string( dat in apex_t_number )
  as
  begin
    for i in 1 .. dat.count -- indices of dat
    loop
      dbms_output.put( dat(i) || '  ');
    end loop;
    dbms_output.put_line( null );
  end to_string;

  procedure push_num( dat in out nocopy apex_t_number, n int )
  as
  begin
    if dat is null then return; end if;
    
    dat.extend(1);
    dat( dat.last ) := n;
  end;

end;
/
