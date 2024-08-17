with
  data (rn, hand, sorted_hand, bet) as (
    select d.rn
          ,d.hand
          ,listagg( c.column_value ) within group (order by c.column_value) sorted_hand
          ,d.bet
    from (select rownum rn
          ,substr( r.column_value, 1, 5)  hand
          ,substr( r.column_value, 6) bet
    from apex_string.split( q'[32T3K 765
T55J5 684
KK677 28
KTJJT 220
QQQJA 483]', chr(10) ) r
    where trim(column_value) is not null
) d
    cross apply (select rownum rn, column_value from apex_string.split( d.hand, null ) ) c
  group by d.rn, d.hand, d.bet

)
select * from data;
