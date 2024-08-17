-- create the acl using the new recommended 12c method as Oracle recommends
-- NB: I've avoided the deprecated function create_acl
BEGIN
  DBMS_NETWORK_ACL_ADMIN.append_host_ace (
    host       => 'adventofcode.com', 
    lower_port => 443,
    upper_port => 443,
    ace        => xs$ace_type(privilege_list => xs$name_list('http', 'https'), -- https fails TODO -- check why
                              principal_name => 'ADVENT_OF_CODE',
                              principal_type => xs_acl.ptype_db)); 
END;
/