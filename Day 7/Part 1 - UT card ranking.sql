with
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
--    ret_value := case
--          when regexp_like( p_hand, '(A{5}|K{5}|Q{5}|J{5}|T{5}|9{5}|8{5}|7{5}|6{5}|5{5}|4{5}|3{5}|2{5}|1{5})' ) then 500
--          when regexp_like( p_hand, '(A{4}|K{4}|Q{4}|J{4}|T{4}|9{4}|8{4}|7{4}|6{4}|5{4}|4{4}|3{4}|2{4}|1{4})' ) then 400
--          when regexp_like( p_hand,
--          '((A{3}|K{3}|Q{3}|J{3}|T{3}|9{3}|8{3}|7{3}|6{3}|5{3}|4{3}|3{3}|2{3}|1{3})(A{2}|K{2}|Q{2}|J{2}|T{2}|9{2}|8{2}|7{2}|6{2}|5{2}|4{2}|3{2}|2{2}|1{2})|(A{2}|K{2}|Q{2}|J{2}|T{2}|9{2}|8{2}|7{2}|6{2}|5{2}|4{2}|3{2}|2{2}|1{2})(A{3}|K{3}|Q{3}|J{3}|T{3}|9{3}|8{3}|7{3}|6{3}|5{3}|4{3}|3{3}|2{3}|1{3}))' )
--            then 350
--          when regexp_like( p_hand, '(A{3}|K{3}|Q{3}|J{3}|T{3}|9{3}|8{3}|7{3}|6{3}|5{3}|4{3}|3{3}|2{3}|1{3})' ) then 300
--          when regexp_like( p_hand, '(A{2}|K{2}|Q{2}|J{2}|T{2}|9{2}|8{2}|7{2}|6{2}|5{2}|4{2}|3{2}|2{2}|1{2}).*(A{2}|K{2}|Q{2}|J{2}|T{2}|9{2}|8{2}|7{2}|6{2}|5{2}|4{2}|3{2}|2{2}|1{2})' )
--            then 250
--          when regexp_like( p_hand, '(A{2}|K{2}|Q{2}|J{2}|T{2}|9{2}|8{2}|7{2}|6{2}|5{2}|4{2}|3{2}|2{2}|1{2})' ) then 200
--          else 0
--        end;
    return ret_value;
  end rank_hand;
  
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
KK777 28
45454 10
54545 10
KTJJT 220
QQQJA 483]', chr(10) ) r
    where trim(column_value) is not null
) d
    cross apply (select rownum rn, column_value from apex_string.split( d.hand, null ) ) c
  group by d.rn, d.hand, d.bet

)
select d.*, rank_hand( d.sorted_hand ) score
from data d;
