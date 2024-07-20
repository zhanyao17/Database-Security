/* Create new login */
use MedicalInfoSystem;
CREATE LOGIN DA_1 with PASSWORD ='DA1@1234';
CREATE Role Data_Admin;
CREATE USER DA_1 for LOGIN DA_1;
ALTER role Data_Admin add member DA_1


/* Grant permission */
GRANT ALTER ANY ROLE TO Data_Admin; -- Allow adding new role
GRANT VIEW DEFINITION TO Data_Admin; -- Allow viwew all roles
GRANT ALTER ANY USER TO Data_Admin;  -- Allow assigning role to new user

-- Patient table
GRANT SELECT, insert, update, delete on Patient to Data_Admin; 
DENY SELECT, update on Patient(PaymentCardNo) to Data_Admin CASCADE; 
GRANT EXECUTE on dbo.DA_ManagePatientRecords to Data_Admin -- procedure
GRANT select on DA_Active_Patient to Data_Admin -- view active patient
GRANT select on DA_Inactive_Patient to Data_Admin -- view in-active patient

-- Doctor table
GRANT SELECT, insert, update, delete on Doctor to Data_Admin; 
DENY SELECT, update on Doctor(DPhone) to Data_Admin; 
GRANT EXECUTE on dbo.DA_ManageDoctorRecords to Data_Admin -- procedure
GRANT select on DA_Active_Doctor to Data_Admin -- view active doctor
GRANT select on DA_Inactive_Doctor to Data_Admin -- view in-active doctor


-- Exec
GRANT EXECUTE on dbo.DA_ManagePatientRecords to Data_Admin; -- Manage patient records
GRANT EXECUTE on dbo.DA_DeletePatientRecords to Data_Admin; -- Delete patient records
GRANT EXECUTE on dbo.DA_ManageDoctorRecords to Data_Admin; -- Manage doctor records
GRANT EXECUTE on dbo.DA_DeleteDoctorRecords to Data_Admin; -- Manage doctor records


/* Action */
-- Create new 
CREATE USER D2 for LOGIN D2;
ALTER role Doctor add member D2 -- adding new doctor

-- Create new user for patient and assigning roles
CREATE USER P2 for LOGIN P2
ALTER role Patient add member P2 -- adding new patient


-- Adding new patient records
EXEC DA_ManagePatientRecords @PName = 'TestNew2'
-- EXEC DA_ManagePatientRecords @PID = 'P9' ,@PName = 'Ah Meng'

-- Deleting patient records
EXEC DA_DeletePatientRecords @PID = 'P9'

-- Adding new doctor records
EXEC DA_ManageDoctorRecords @DName = 'Dr. testNew'
EXEC DA_ManageDoctorRecords @DrID = 'D1' ,@DName = 'Dr. Ali'

-- Deleting doctor records
EXEC DA_DeleteDoctorRecords @DrID = 'D9'


-- Undo patient
EXEC DA_UndoPatient

-- Undo doctor
EXEC DA_UndoDoctor

-- View active or in-active user
select * from DA_Active_Doctor; -- active doctor
select * from DA_Inactive_Doctor; -- inactive doctor
select * from DA_Active_Patient; -- active patient
select * from DA_Inactive_Patient -- inactive patient


/* View all role */
SELECT roles.[name] as role_name, members.[name] as user_name
FROM sys.database_role_members 
INNER JOIN sys.database_principals roles 
ON database_role_members.role_principal_id = roles.principal_id
INNER JOIN sys.database_principals members 
ON database_role_members.member_principal_id = members.principal_id
WHERE roles.name in ('Data_Admin','Doctor','Patient')
GO

-- others

-- select * from Doctor
-- select * from AuditLog_Patient ORDER by [Log ID] desc

-- audit