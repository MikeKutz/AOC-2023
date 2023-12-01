create user advent_of_code identified by Change0nInstall
  default tablespace users
  temporary tablespace temp
  quota unlimited on users
  account unlock
  ;
  
grant db_developer_role to advent_of_code;

-- ?? grant execute any domain on schema sys to advent_of_code;