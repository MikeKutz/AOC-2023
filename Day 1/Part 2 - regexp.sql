--select rn, str, first_digit_word, last_digit_word, to_number( to_char( f1.num ) || to_char( f2.num ) ) numnum
select sum( to_number( to_char( f1.num ) || to_char( f2.num ) ) ) numnum
from (
  select rn, str
    ,regexp_substr( str, '(1|2|3|4|5|6|7|8|9|one|two|three|four|five|six|seven|eight|nine)' ) first_digit_word
    ,regexp_replace( str, '^.*(1|2|3|4|5|6|7|8|9|one|two|three|four|five|six|seven|eight|nine).*?$', '\1') last_digit_word
  from e2023_1
) d
 left outer join full_conversion_table f1 on d.first_digit_word = f1.num_str
 left outer join full_conversion_table f2 on d.last_digit_word = f2.num_str
  
