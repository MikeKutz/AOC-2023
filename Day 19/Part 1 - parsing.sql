with
  input_data (txt) as (
    select q'[px{a<2006:qkq,m>2090:A,rfg}
pv{a>1716:R,A}
lnx{m>1548:A,A}
rfg{s<537:gd,x>2440:R,A}
qs{s>3448:A,lnx}
qkq{x<1416:A,crn}
crn{x>2662:A,R}
in{s<1351:px,qqz}
qqz{s>2770:qs,m<1801:hdj,R}
gd{a>3333:R,R}
hdj{m>838:A,pv}

{x=787,m=2655,a=1222,s=2876}
{x=1679,m=44,a=2067,s=496}
{x=2036,m=264,a=79,s=2244}
{x=2461,m=1339,a=466,s=291}
{x=2127,m=1623,a=2188,s=1013}
]'
  ), decision_tree_unprocessed (rn, dec_line) as (
    select rownum, trim(column_value)
    from (select substr( txt, 1, instr( txt, chr(10) || chr(10) ) ) txt
          from input_data) a
      cross apply apex_string.split( a.txt, chr(10) ) b
    where trim( b.column_value) is not null
  ), unprocessed_object (rn, obj_line) as (
    select rownum, trim(column_value)
    from (select substr( txt, instr( txt, chr(10) || chr(10) ) + 2 ) txt
          from input_data) a
      cross apply apex_string.split( a.txt, chr(10) ) b
    where trim(b.column_value) is not null
  ), dec_txt as (
    select oa.step_name
      ,ob.column_value dec_rule
      ,case
        when instr(ob.column_value, ':' ) > 0 then substr(ob.column_value,1,1)
       end var
      ,substr(ob.column_value,2, regexp_instr( ob.column_value, '[0-9]' ) - 2) dec_symbol
      ,regexp_substr( ob.column_value, '[0-9]+' ) comp_value
      ,substr( ob.column_value, instr( ob.column_value, ':') + 1 ) next_step
    from (select substr( a.dec_line, 1, instr( a.dec_line, '{' ) - 1) step_name
            ,rtrim( substr( a.dec_line, instr( a.dec_line, '{' ) + 1), '}' ) all_dec
          from decision_tree_unprocessed a) oa
      cross apply apex_string.split( oa.all_dec, ',' ) ob
      where trim(ob.column_value) is not null
      
  ), object_values as (
    select *
    from (
          select rn as part#
            ,substr( b.column_value, 1, 1 ) attribute_name
            ,substr( b.column_value,3) attribute_value
          from unprocessed_object a
            cross apply apex_string.split( ltrim(rtrim(a.obj_line, '}'), '{'), ',' ) b
          where trim(b.column_value) is not null
        )
      pivot ( min(attribute_value)
        for attribute_name in ( 'x' as X, 'm' as M, 'a' as A, 's' as S)
      )
  )
select *
from object_values;
    