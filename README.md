# Database-Security
Performing security features on MSSQL (Sql server)

# Step for setting up
Run files follow with this steps ...
1. Pre-process 
2. Perform_data_secure (perform_tde)
3. Function (all)
4. User-Managment(all)
5. Prepare docker env
    - mkdir `opt/mssql/backup`
    - mkdir `opt/mssql/audit`
    - cp local:`/Backup_files/backup.sql` to env: `/opt/mssql/backup`
    - cp local:`/Backup_files/run_backup.sh` to env:`opt/mssql/backup`
    - same goes to the certificate (KEY & CERT files)
    - `apt install crontab` for setup sceduler
    - `apt install vim` for edit crontab -e

# Important
- Since we have limitation on using SSMS on a unix devices, some of the setup for the auditing and auto scheduling backup.
- Multiple encryption methods had been implemented in this databse for security purposes:
    - Default: Masker key + CERT
    - Asymmetric encryption
    - Symmetric encryption
    - Dynamic Masking
    - Anonimization
- Auditing covers:
    - Login/Logout/Login Failed
    - DML
    - DCL
    - DDL

