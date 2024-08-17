set serveroutput on;
clear screen;

declare
  dat       apex_t_number := apex_t_number(10,  13 , 16  ,21  ,30 , 45);
  next_row  apex_t_number;
  last#_list  apex_t_number := new apex_t_number();      
  last#_hist  int := 0;
  first#_list apex_t_number := new apex_t_number();      
  first#_hist  int := 0;
begin
  next_row := dat;
  d9_calculator.push_num( last#_list, next_row( next_row.last ) );
  d9_calculator.push_num( first#_list, next_row( next_row.first ) );

  for i in 1 .. 10
  loop
    d9_calculator.to_string( next_row );
    
    next_row := d9_calculator.calc_diffs( next_row );
    
    d9_calculator.push_num( last#_list, next_row( next_row.last ) );
    d9_calculator.push_num( first#_list, next_row( next_row.first ) );
    
    exit when d9_calculator.is_zero( next_row );
  end loop;
  
  for i in reverse 2 .. last#_list.count 
  loop
    dbms_output.put( last#_list(i) || ',' || first#_list(i) || ' (' || last#_hist || ')  ' );
    last#_hist :=  last#_hist + last#_list(i-1) - last#_list(i);
  end loop;
    if last#_list.exists(2) then
      last#_hist :=  last#_hist + last#_list(2) - last#_list(1);
    end if;
  
  dbms_output.put_line( '==  ' ||  first#_hist || ',' || last#_hist );
end;
/