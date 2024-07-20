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

-- Doctor table
GRANT SELECT, insert, update, delete on Doctor to Data_Admin; 
DENY SELECT, update on Doctor(DPhone) to Data_Admin; 
GRANT EXECUTE on dbo.DA_ManageDoctorRecords to Data_Admin -- procedure

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
EXEC DA_ManagePatientRecords @PName = 'TestNew'

-- Deleting patient records
EXEC DA_DeletePatientRecords @PID = 'P10'

-- Adding new doctor records
EXEC DA_ManageDoctorRecords @DName = 'Dr. testNew'

-- Deleting doctor records
EXEC DA_DeleteDoctorRecords @DrID = 'D9'



/* View all role */
SELECT roles.[name] as role_name, members.[name] as user_name
FROM sys.database_role_members 
INNER JOIN sys.database_principals roles 
ON database_role_members.role_principal_id = roles.principal_id
INNER JOIN sys.database_principals members 
ON database_role_members.member_principal_id = members.principal_id
WHERE roles.name in ('Data_Admin','Doctor','Patient')
