/* 
This was the third techniques had been implemented for perform recovery action (temporal files)
This table is quite similar to the triggers and CDC tables
- Undo action
- Prevent table to be drop
*/


/* Temporal table methods */
-- create new history table
ALTER TABLE dbo.Doctor
ADD ValidFrom DATETIME2 GENERATED ALWAYS AS ROW START
    DEFAULT GETUTCDATE(),
    ValidTo DATETIME2 GENERATED ALWAYS AS ROW END
    DEFAULT CONVERT(DATETIME2, '9999-12-31 23:59:59.9999999'),
    PERIOD FOR SYSTEM_TIME (ValidFrom, ValidTo);
GO

ALTER TABLE dbo.Doctor SET (SYSTEM_VERSIONING = ON (HISTORY_TABLE = dbo.DoctorHistory));
GO


/* Clear cache inside the history table */
ALTER TABLE dbo.Doctor SET (SYSTEM_VERSIONING = OFF); 
GO
TRUNCATE TABLE dbo.DoctorHistory; 
GO
DELETE FROM dbo.DoctorHistory; 
go


/*  View history table */
select * from DoctorHistory

select * from Doctor