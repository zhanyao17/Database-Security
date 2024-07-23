/* 
    CDC table for Diagnosis tale
    - This cdc table allow the user to perform undo and keep track all the modification on it, 
        however for the soft delete we need to implement manually (refer the Doctor_func.sql procedure: DR_UndoDiagnosis)
*/
-- Enable CDC at the database level
EXEC sys.sp_cdc_enable_db;
 
-- Enable CDC for the Diagnosis table
EXEC sys.sp_cdc_enable_table
    @source_schema = N'dbo',
    @source_name = N'Diagnosis',
    @capture_instance = N'dbo_Diagnosis',
    @role_name = NULL;

-- View 
SELECT *
FROM cdc.dbo_Diagnosis_CT
ORDER BY __$start_lsn DESC
OFFSET 1 ROWS
FETCH NEXT 1 ROW ONLY;

select * from Diagnosis


/* 
Change tracking 
    - One of the technqieus used to keep track changes but in a more ligher weight
        we can have perform synchronize monitoring on the changes since it was light weight
        it will only capture the newest changes done by the user
    - Advantages: Fash, light weight, capacity friendly
    - Disadvntages: hard to find back the oldest recoreds / undo action
*/
ALTER DATABASE MedicalInfoSystem
SET CHANGE_TRACKING = ON
(CHANGE_RETENTION = 2 DAYS, AUTO_CLEANUP = ON);
GO


ALTER TABLE dbo.Diagnosis
ENABLE CHANGE_TRACKING
WITH (TRACK_COLUMNS_UPDATED = ON);
GO


DECLARE @last_sync_version BIGINT;
SET @last_sync_version = 0;
SELECT CT.*
FROM CHANGETABLE(CHANGES dbo.Diagnosis, @last_sync_version) AS CT;
GO


-- view changes with more information
DECLARE @last_sync_version BIGINT;
SET @last_sync_version = 0;
SELECT CT.*, D.*
FROM CHANGETABLE(CHANGES dbo.Diagnosis, @last_sync_version) AS CT
LEFT JOIN dbo.Diagnosis AS D ON CT.[DiagID] = D.[DiagID]
order by CT.sys_change_version desc;
GO


-- perform demo
exec DR_Add_Diagnosis @PID = 'P1' 
select * from Diagnosis
delete from Diagnosis where DiagID = 15
exec DR_Udpate_Diagnosis @DiagID = 16, @Diagnosis = 'Flu'
-- udpate diagnosis
exec DR_Udpate_Diagnosis @DiagID = 14 

GRANT EXEC on dbo.DR_Udpate_Diagnosis to Doctor -- Update diagnosis
GRANT EXEC on dbo.DR_UndoDiagnosis to Doctor -- Update diagnosis
GRANT SELECT ON OBJECT::cdc.dbo_Diagnosis_CT TO Doctor; -- select on cdc file