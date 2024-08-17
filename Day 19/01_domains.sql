drop domain d19_step;
drop domain d19_var;
drop domain d19_symbol;
drop domain d19_value;

create domain d19_step as varchar2(10)
  not null
  check ( regexp_like( d19_step, '^([a-z]+|A|R)$' )
    and d19_step is not null
        );

create domain d19_var  as varchar2(1)
  check ( d19_var in ( 'x','m','a','s' ) );

create domain d19_symbol as varchar2(3)
  check (d19_symbol in ( '<', '=', '>' ) );
  
create domain d19_value as integer;
