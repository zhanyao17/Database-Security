#!/bin/bash
/opt/mssql-tools/bin/sqlcmd -S 127.0.0.1,1433 -U SA -P 'zhanyao88' -i /opt/mssql/backup/backup.sql