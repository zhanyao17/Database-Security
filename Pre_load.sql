Use MedicalInfoSystem
Go

INSERT INTO Doctor (DrID, DName, DPhone) VALUES
('D1', 'Dr. John Smith', '123-456-7890'),
('D2', 'Dr. Emily Brown', '234-567-8901'),
('D3', 'Dr. Michael Davis', '345-678-9012'),
('D4', 'Dr. Sarah Wilson', '456-789-0123'),
('D5', 'Dr. David Martinez', '567-890-1234'),
('D6', 'Dr. Laura Thompson', '678-901-2345'),
('D7', 'Dr. James Garcia', '789-012-3456'),
('D8', 'Dr. Jessica Lee', '890-123-4567');


INSERT INTO Patient (PID, PName, PPhone, PaymentCardNo) VALUES
('P1', 'Alice Johnson', '321-654-9870', '1111-2222-3333-4444'),
('P2', 'Bob Williams', '432-765-0981', '5555-6666-7777-8888'),
('P3', 'Carol Taylor', '543-876-1092', '9999-0000-1111-2222'),
('P4', 'David Harris', '654-987-2103', '3333-4444-5555-6666'),
('P5', 'Eva Clark', '765-098-3214', '7777-8888-9999-0000'),
('P6', 'Frank Rodriguez', '876-109-4325', '2222-3333-4444-5555'),
('P7', 'Grace Lewis', '987-210-5436', '6666-7777-8888-9999'),
('P8', 'Henry Walker', '098-321-6547', '0000-1111-2222-3333');


INSERT INTO Diagnosis (PatientID, DoctorID, DiagnosisDate, Diagnosis) VALUES
('P1', 'D1', '2023-01-01 09:00:00', 'Flu'),
('P2', 'D2', '2023-01-02 10:00:00', 'Common Cold'),
('P3', 'D3', '2023-01-03 11:00:00', 'Bronchitis'),
('P4', 'D4', '2023-01-04 12:00:00', 'Asthma'),
('P5', 'D5', '2023-01-05 13:00:00', 'Diabetes'),
('P6', 'D6', '2023-01-06 14:00:00', 'Hypertension'),
('P7', 'D7', '2023-01-07 15:00:00', 'Allergies'),
('P8', 'D8', '2023-01-08 16:00:00', 'Arthritis');
