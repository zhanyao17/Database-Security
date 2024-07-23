/* 
This file consist all the permission granting and action can be perform by this roles
#TAKE NOTES
Sub-headings
1. Create new login (run using sa account)
2. Grant permission (run using sa account)
3. Action (run using D1)
*/


/* Create login and user for patient roles */
CREATE Role Patient; -- Create role
CREATE LOGIN P1 with PASSWORD ='P_1@1234'; -- creat new user
CREATE USER P1 for LOGIN P1;
ALTER role Patient add member P1

-- Patient 2
CREATE LOGIN P2 with PASSWORD ='P_2@1234'; -- creat new user
-- CREATE USER P2 for LOGIN P2;


/* Grant permission */
GRANT SELECT on P_View_personal to Patient -- views personal info
GRANT EXECUTE on dbo.P_Manage_PII to Patient -- execute update pii procedure
GRANT SELECT ON P_View_diagnosis to Patient -- view diagnosis info

-- For Asymetric key
GRANT CONTROL ON ASYMMETRIC KEY::AsymKey_paymentCarNo TO Patient;
GRANT VIEW DEFINITION ON ASYMMETRIC KEY::AsymKey_paymentCarNo TO Patient;

-- For symetric key to view doctor contact
GRANT CONTROL ON SYMMETRIC KEY::SimKey_contact1 TO Patient;
GRANT CONTROL ON CERTIFICATE::CertForCLE TO Patient;

/* Action */
-- view own pii
select * from P_View_personal

-- Changing own info
EXEC P_Manage_PII @PName='Ali'

-- View own diagnosis records
OPEN SYMMETRIC KEY SimKey_contact1
DECRYPTION BY CERTIFICATE CertForCLE;
select * from P_View_diagnosis
CLOSE SYMMETRIC KEY SimKey_contact1