NAME:
  awrrpt.sql

DESCRIPTION:
  This script generates oracle AWR report.

SUPPORTED OS:
  Linux, Aix, Hp-ux, Solaris, Windows

SUPPORTED ORACLE VERSION:
  11g;10g

USAGE:
  sqlplus连接数据库，运行脚本：
  SQL> @awrrpt

在当前目录生成数据库AWR报告[默认当天9:00-10:00，可修改]

参数定义：day=0-当天;1-昨天;2-前天;依此类推

报告名字：checkdb_hostname_instance_service_awrrpt_YYYYMMDD_StartHour-EndHour.html

报告名字示例：checkdb_hb_rac1_irmsdb1_irmsdb_awrrpt_20170310_9-10.html

注，普通数据库用户需具备如下权限：

grant execute on DBMS_WORKLOAD_REPOSITORY to username;

grant select any dictionary to username;

MODIFIED (YYYY-MM-DD)

likingzi  2021-12-10 - Added service_name to report_name

likingzi  2017-01-16 - Adding Support Windows OS

likingzi  2016-12-05 - Created
