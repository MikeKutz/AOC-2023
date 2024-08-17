drop domain must_be_number;
create domain must_be_number as varchar(100)
  not null
  check ( must_be_number is not null
    and to_number( must_be_number default null on conversion error ) is not null
    );

drop domain is_a_symbol;
create domain is_a_symbol as varchar(1) not null
  check ( regexp_like( is_a_symbol, '[^.[:alnum:]' || chr(10) || ']' ) );

drop domain does_overlap;
create domain does_overlap as (
  start_1 as int not null,
  end_1   as int not null,
  start_2 as int not null,
  end_2   as int not null
)
constraint check ( start_1 <= end_2 and end_1 >= start_2
  and start_1 is not null and start_2 is not null
  and end_1 is not null and end_2 is not null);

with data (rn, txt) as (
  select rownum rn, trim(column_value)
  from apex_string.split( q'[467..114..
...*......
..35..633.
......#...
617*......
.....+.58.
..592.....
......755.
...$.*...
.664.598..]', chr(10) )
), find_pattern (rn, original_str, pattern_str, start_pos, end_pos, next_start_pos, occurance ) as (
  select d.rn
        ,d.txt
        ,regexp_substr( d.txt, '([0-9]+|[^.0-9]+)', 1, 1 )
        ,regexp_instr( d.txt, '([0-9]+|[^.0-9]+)', 1, 1, 0 )
        ,regexp_instr( d.txt, '([0-9]+|[^.0-9]+)', 1, 1, 1 ) - 1
        ,regexp_instr( d.txt, '([0-9]+|[^.0-9]+)', 1, 1, 1 )
        ,1
  from data d
  union all
  select f.rn
        ,f.original_str
        ,regexp_substr( f.original_str, '([0-9]+|[^.0-9]+)', 1, occurance + 1 )
        ,regexp_instr( f.original_str, '([0-9]+|[^.0-9]+)', 1, occurance + 1, 0 )
        ,regexp_instr( f.original_str, '([0-9]+|[^.0-9]+)', 1, occurance + 1, 1 ) - 1
        ,regexp_instr( f.original_str, '([0-9]+|[^.0-9]+)', 1, occurance + 1, 1 )
        ,occurance + 1
  from find_pattern f
  where regexp_instr( f.original_str, '([0-9]+|[^.0-9]+)', 1, occurance + 1, 0 ) > 0
)
--  cycle rn, start_pos, end_pos set cycle to 1 default 0
, all_numbers as (
  select n.*
  from find_pattern n
  where domain_check( must_be_number, pattern_str ) is true
--    and cycle = 0
), all_symbols as (
  select * from (
    select s.*
          ,rn -1 p_rn
          ,rn+1 n_rn
    from find_pattern s
--    where cycle = 0
  )
  where domain_check( must_be_number, pattern_str ) is false
), final_table as (
  select rn, start_pos, num_rn, num_start_pos, num_end_pos, pattern_str, num_str
  from (
  select a.rn, a.start_pos, a.pattern_str
        ,b.rn num_rn, b.start_pos num_start_pos, b.end_pos num_end_pos, b.pattern_str num_str
  from all_symbols a
    join all_numbers b on b.rn in (a.p_rn, a.rn, a.n_rn)
  where domain_check( does_overlap, a.start_pos - 1, a.end_pos + 1
                      ,b.start_pos, b.end_pos ) is true
  )
)
select sum( to_number(num_str) ) from final_table;
