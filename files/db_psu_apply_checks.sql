set echo off termout on feedback off linesize 150 pagesize 10000 heading off
select '==> Database name: '||name from v$database;
select '==> Instance name: '||INSTANCE_NAME from v$instance;

col COMP_ID for a25
col COMP_NAME for a60
col DBA_REGISTRY for a15
col STATUS for a15
select '==> report from DBA_REGISTRY:' from dual;
set heading on
select COMP_ID,COMP_NAME,VERSION,STATUS from dba_Registry order by 1,2;
set heading off

col INSTALL_DATE for a20
col ACTION for a20
col VERSION for a27
col ID for 99999999
col BUNDLE_SERIES for a15
col COMMENTS for a30
select '==> report from DBA_REGISTRY_HISTORY:' from dual;
set heading on
select to_char(ACTION_TIME, 'YYYY-MM-DD HH24:MI:SS') INSTALL_DATE, ACTION, VERSION, ID, COMMENTS from dba_registry_history order by INSTALL_DATE desc;
set heading off

select '==> report from DBA_REGISTRY_SQLPATCH:' from dual;
col action for a8
col version for a8
col BSER for a4
col status for a8
col description for a70
set heading on
select to_char(ACTION_TIME, 'YYYY-MM-DD HH24:MI:SS') INSTALL_DATE, ACTION, VERSION, PATCH_ID, BUNDLE_SERIES "BSER", STATUS, DESCRIPTION from dba_registry_sqlpatch order by INSTALL_DATE desc;
set heading off

select '==> report from REGISTRY$HISTORY:' from dual;
col ACTION_TIME for a28
col ACTION for a16
col NAMESPACE for a10
col BUNDLE_SERIES for a14
col version for a24
col comments for a24
col ACT_TIME for a19
set heading on
select to_char(ACTION_TIME,'YYYY-MM-DD HH24:MI:SS') ACT_TIME,ACTION,COMMENTS,NAMESPACE,VERSION,BUNDLE_SERIES,ID from registry$history order by 1 desc;
set heading off

col object_name for a40
col owner for a25
col OBJECT_TYPE for a30
col status for a10
select '==> report of object types in INVALID state:' from dual;
set heading on
select owner, object_type, status, count(*) from dba_objects group by owner, object_type, status having status <> 'VALID';
set heading off

select '==> list of objects in INVALID state:' from dual;
set heading on
select owner, object_type, object_name from dba_objects where status <> 'VALID' order by 1,2,3;
set heading off

