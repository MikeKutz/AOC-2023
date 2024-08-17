with
  function order_by( p_hand in varchar2, joker in varchar2 default '.' ) return varchar2
  as
  begin
--    return translate(translate(p_hand,'TJQKA','AJCDE'), :joker , 1);
    return translate(translate(p_hand,'TJQKA','AJCDE'), joker , 1);
  end;
  function rank_hand( p_hand in varchar2 ) return number
  as
    ret_value int;
  begin
    ret_value := case
          when regexp_like( p_hand, '([2-9TJQKA])\1{4}' ) then 500
          when regexp_like( p_hand, '([2-9TJQKA])\1{3}' ) then 400
          when regexp_like( p_hand,
          '([2-9TJQKA])\1.*([2-9TJQKA])\2{2}' )
            then 350
          when regexp_like( p_hand,
          '([2-9TJQKA])\1{2}.*([2-9TJQKA])\2' )
            then 350
          when regexp_like( p_hand, '([2-9TJQKA])\1{2}' ) then 300
          when regexp_like( p_hand, '([2-9TJQKA])\1.*([2-9TJQKA])\2' )
            then 250
          when regexp_like( p_hand, '([2-9TJQKA])\1' ) then 200
          else 0
        end;
    return ret_value;
  end rank_hand;
  
  raw_data as (
  
select rownum rn
          ,substr( r.column_value, 1, 5)  hand
          ,substr( r.column_value, 6) bet
    from apex_string.split( q'[32T3K 765
T55J5 684
TT4J5 300
KK677 28
KTJJT 220
QQQJA 483
KK777 28
45454 10
54545 10
2222J 999
222J3 888
]', chr(10) ) r
    where trim(column_value) is not null 
), split_cards (rn, hand, sorted_hand, bet) as (
  select rn
      ,hand
      ,listagg( card ) within group (order by
                  decode( card, :joker, 6, order_by )
                  desc nulls first) sorted_hand
      ,bet
    from (
      select d.rn
            ,d.hand
            ,c.column_value card
            ,d.bet
            ,count(*) over (partition by d.rn, c.column_value) order_by
      from raw_data d
        cross apply (select rownum rn, r.column_value from apex_string.split( d.hand, null ) r ) c
    )
    group by rn, hand, bet
),
  data (rn, hand, sorted_hand, bet) as (
    select rn
      ,hand
      -- make all Jokers the first non-Joker card
      ,translate( sorted_hand, :joker, regexp_substr( sorted_hand, '[^' || :joker || ']' ) )
      ,bet
    from (
      -- fix this section
      -- 
      select * from split_cards
--      select d.rn
--            ,d.hand
--            ,listagg( c.column_value ) within group (order by nullif(c.column_value, :joker ) nulls first) sorted_hand
--            ,d.bet
--      from raw_data d
--        cross apply (select rownum rn, column_value from apex_string.split( d.hand, null ) ) c
--      group by d.rn, d.hand, d.bet
    )

), rank_score_win as (
select p.hand, p.bet
  ,row_number() over (order by p.score, p.order_by) winrank
  ,row_number() over (order by p.score, p.order_by) * p.bet winnings
from (
select d.*, rank_hand( d.sorted_hand ) score, order_by( d.hand ) order_by
from data d
) p
)
--select sum(winnings) from rank_score_win;
--/
select d.*
  ,case rank_hand( d.sorted_hand )
    when 500 then '5*'
    when 400 then '4*'
    when 300 then '3*'
    when 200 then '2*'
    when 250 then '2*2*'
    when 350 then '3*2*'
    else 'none'
    end score
  ,order_by( d.hand, :joker ) order_by
from data d
