create domain d8_directions_d as varchar(1)
  not null
  check ( d8_directions_d in ('L','R')
      and d8_directions_d is not null -- bug workaround
       );
       
create domain d8_location_d as varchar(3)
  not null
  check ( regexp_like(d8_location_d, '[A-Z]{3}')
    and d8_location_d is not null
        );
        
create or replace
function pick_next_location( direction in varchar2, location_left in varchar2, location_right in varchar2) return varchar2
  sql_macro( scalar )
as
begin
  -- assumes direction and locations meet d8_<>_d assertion
  
  return  case direction
            when 'L' then location_left
            when 'R' then location_right
            else null
          end;
end;
/