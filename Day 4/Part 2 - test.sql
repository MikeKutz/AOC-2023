with line_data as (
 select rownum rn, trim(column_value) line_txt
from
apex_string.split( q'[Card 1: 41 48 83 86 17 | 83 86  6 31 17  9 48 53
Card 2: 13 32 20 16 61 | 61 30 68 82 17 32 24 19
Card 3:  1 21 53 59 44 | 69 82 63 72 16 21 14  1
Card 4: 41 92 73 84 69 | 59 84 76 51 58  5 54 83
Card 5: 87 83 26 28 32 | 88 30 70 12 93 22 82 36
Card 6: 31 18 13 56 72 | 74 77 10 23 35 67 36 11
]', chr(10) )
where trim(column_value) is not null
), parsed_data as (
select rn
  ,substr(line_txt,1,instr( line_txt, ':' ) + 1) id
  -- remove NULL elements
  ,apex_string.split( trim(substr(line_txt,instr( line_txt, ':' ) + 1,instr( line_txt, '|' ) - instr( line_txt, ':' ) - 1 )), ' ' ) 
    multiset except distinct apex_t_varchar2( null ) winning#
   -- remove NULL elements
  ,apex_string.split( trim(substr(line_txt,instr( line_txt, '|' ) + 1 ) ), ' ' )
    multiset except distinct apex_t_varchar2( null )  card#
  from line_data
),card_winnings ( rn, id, won_id, original_card, card_n ) as (
  -- describe duplicate cards you've won
  select rn
      ,to_number(substr(replace(id,':', ''),5))
      ,null
      ,cardinality( winning# multiset intersect card# )
      ,cardinality( winning# multiset intersect card# )
  from parsed_data
  union all
  select rn, id
        ,nvl(won_id,id)+1
        ,original_card
        ,card_n -1
  from card_winnings
  where card_n - 1 >=0 
), winning_maps as (
  -- compress CARD_WININGS to ID, CARDS_WON (a NN)
  select id, cast(multiset( select w.won_id 
                            from card_winnings w
                            where w.id = c.id
                              and w.won_id is not null) as APEX_T_NUMBER) won_ids
  from card_winnings c
  where c.won_id is null
), total_won (id,won_ids, lv) as (
  -- duplicate cards per WINNING_MAPS
  select id, won_ids, 1
  from winning_maps m
  union all
  select j.id, j.won_ids, z.lv + 1
  from total_won z
    cross apply table(z.won_ids) a
    join winning_maps j on a.column_value = j.id
  where lv < 10
) cycle id set is_cycle to '1' default '0'
 select * from total_won order by id; -- test line; shows all copies of ID,WINNINGS
select count(*) from total_won; -- the answer of the requested
select id, count(*) N -- shows count(*) by id
from total_won
group by id
order by id
;
