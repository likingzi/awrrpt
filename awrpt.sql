-- NAME
--   awrrpt.sql
--
-- DESCRIPTION
--   This script generates oracle AWR report.
--
-- SUPPORTED OS
--   Linux, Aix, Hp-ux, Solaris, Windows
--
-- SUPPORTED ORACLE VERSION
--   11g;10g
--
-- USAGE
--   sqlplus连接数据库，运行脚本：
--   SQL> @awrrpt
--   在当前目录生成数据库AWR报告[默认当天9:00-10:00，可修改]
--   参数定义：day=0-当天;1-昨天;2-前天;依此类推
--
--   报告名字：checkdb_hostname_instance_service_awrrpt_YYYYMMDD_StartHour-EndHour.html
--   报告名字示例：checkdb_hb_rac1_irmsdb1_irmsdb_awrrpt_20170310_9-10.html
--   注，普通数据库用户需具备如下权限：
--   grant execute on DBMS_WORKLOAD_REPOSITORY to username;
--   grant select any dictionary to username;
--
-- MODIFIED (YYYY-MM-DD)
-- likingzi  2021-12-10 - Added service_name to report_name
-- likingzi  2017-01-16 - Adding Support Windows OS
-- likingzi  2016-12-05 - Created

prompt +----------------------------+
prompt + Oracle Database AWR Report +
prompt +----------------------------+

set echo off
set termout off
set trimout off
set feedback off
set heading on
set linesize 200
set pagesize 10000
set numwidth 20
alter session set nls_date_format='yyyy-mm-dd hh24:mi:ss';

-- Define rpt_name <
set termout on
prompt Specify day of report: '0' - today, '1' - yesterday, and so on [Default to '0']
set termout off
column day new_value day noprint;
-- define day=0
select nvl('&&day','0') day from dual;
select 0 day from dual where '&day' < 0 or '&day' > 7;
set termout on
prompt Using day: &day
set termout off
--
set termout on
prompt Specify startTime of report: '0 - 23' [Default to '9']
set termout off
column startTime new_value startTime;
-- define startTime=9
select nvl('&&startTime','9') startTime from dual;
select 9 startTime from dual where &startTime < 0 or &startTime > 23;
set termout on
prompt Using startTime: &startTime
set termout off
--
set termout on
prompt Specify endTime of report: '0 - 23' [Default to '10']
set termout off
column endTime new_value endTime;
-- define endTime=10
select nvl('&&endTime','10') endTime from dual;
select 10 endTime from dual where &endTime < 0 or &endTime > 23 or &endTime < &startTime + 1;
set termout on
prompt Using endTime: &endTime
set termout off
--
COLUMN min_id NEW_VALUE begin_snap NOPRINT
COLUMN max_id NEW_VALUE end_snap NOPRINT
SELECT to_char(min(snap_id)) min_id,to_char(max(snap_id)) max_id FROM dba_hist_snapshot b
WHERE b.end_interval_time BETWEEN trunc(sysdate) - &day + &startTime / 24 AND trunc(sysdate) - &day + ( &endTime + 1) / 24;
--
COLUMN service_names NEW_VALUE service_names NOPRINT
select value service_names from v$parameter where upper(name) like '%SERVICE_NAMES%';
COLUMN rpt_name NEW_VALUE rpt_name NOPRINT
SELECT 'checkdb_'||host_name||'_'||instance_name||'_'||'&service_names'||'_awrrpt_'||TO_CHAR(SYSDATE - &day,'YYYYMMDD_')||'&startTime'||'-'||'&endTime'||'.html' rpt_name FROM v$instance;
-- Define rpt_name >

-- Generate report: rpt_name <
set echo off
set feedback off
set heading off
set veri off
set linesize 1500
--
set termout on
prompt
prompt Start to Create AWR report. Please wait ......
set termout off
--
COLUMN dbid NEW_VALUE dbid NOPRINT
SELECT dbid FROM v$database;
COLUMN instance_number NEW_VALUE instance_number NOPRINT
SELECT instance_number FROM v$instance;
--
set trimspool on
spool &rpt_name
select output from table(dbms_workload_repository.AWR_REPORT_HTML(&dbid, &instance_number, &begin_snap, &end_snap, 0));
spool off
-- Generate report: rpt_name >

set termout on
prompt
prompt Report name: &rpt_name
prompt
prompt Completed!
prompt

undefine day
undefine startTime
undefine endTime
undefine rpt_name
undefine dbid
undefine instance_number
undefine begin_snap
undefine end_snap
