create function parse_lines ( input_txt in varchar2 ) return clob
  sql_macro(table)
as
begin

  return
q'[select rownum rn, trim(column_value) line_txt
from apex_string.split( input_txt, chr(10) )
where trim( column_value ) is not null]';
end parse_lines;
/
