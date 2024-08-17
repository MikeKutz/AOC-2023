with
  data( rn, input_txt ) as (
    select rownum, trim(column_value)
    from apex_string.split( q'[rn=1,cm-,qp=3,cm=2,qp-,pc=4,ot=9,ab=5,pc-,pc=6,ot=7]', ',' )
    where trim(column_value) is not null
  ), add_lenses as (
    select rn
    ,substr( input_txt, 1, instr(input_txt,'=') - 1) lens_id
    ,d15_conversion( substr( input_txt, 1, instr(input_txt,'=') - 1) ) box_id
    ,to_number( substr(input_txt, instr(input_txt, '=') + 1  )) focal_length
    from data
    where input_txt like '%=%'
  ), remove_lenses as (
    select rn
    ,substr( input_txt, 1, instr(input_txt,'-') - 1) lens_id
    ,d15_conversion( substr( input_txt, 1, instr(input_txt,'-') - 1) ) box_id
    ,cast(null as number) focal_length
    from data
    where input_txt like '%-'
  ), lenses_decoded as (
    select * from add_lenses
    union all
    select * from remove_lenses
  ), final_lenses as (
  select max(rn)keep (dense_rank last order by rn) rn
    ,box_id
    ,lens_id
    ,max(focal_length) keep (dense_rank last order by rn) focal_length
  from lenses_decoded
  match_recognize ( -- lenses can be removed then added
    partition by box_id, lens_id
    order by rn
    measures
      first(add_lens.rn) as rn,
      last(focal_length) as focal_length
    pattern ( remove_lens* add_lens+ $ )
    define
      remove_lens as focal_length is null,
      add_lens    as focal_length is not null
  ) a
  group by box_id, lens_id
)
  select sum(focusing_power) answer
  from (
  select l.*
    ,(1+l.box_id)
      * row_number() over (partition by l.box_id order by l.rn)
      * l.focal_length
      as focusing_power
  from final_lenses l
  order by box_id, rn
)
;


/*
use
  match_recognize pattern (  remove_lens* add_lens+ $ )
to find the last delete then updata sequence

exclude add_lens+ remove_lens* 
*/