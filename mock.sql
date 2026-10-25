DROP DATABASE IF EXISTS hospital_management;
CREATE DATABASE hospital_management;
USE hospital_management;

CREATE TABLE patients(
	patient_id INT AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(30) NOT NULL,
    dob DATE,
    gender VARCHAR(15),
    phone_number VARCHAR(20),
    email VARCHAR(150) UNIQUE,
    address VARCHAR(250),
    registration_date DATE NOT NULL
    );
    
     CREATE TABLE doctors(
	doctor_id INT AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(30) NOT NULL,
    specializtion VARCHAR(100) NOT NULL,
    available_days VARCHAR(15),
    phone_number VARCHAR(20),
    email VARCHAR(150) UNIQUE,
    consultation_fee DECIMAL(10,2) NOT NULL,
    joining_date DATE NOT NULL,
    mentor_doctor_id INT NULL
    );

CREATE TABLE departments(
department_id INT AUTO_INCREMENT PRIMARY KEY,
department_name VARCHAR(100) NOT NULL UNIQUE
);

CREATE TABLE appointments(
	appointment_id INT AUTO_INCREMENT PRIMARY KEY,
    patient_id INT NOT NULL,
    doctor_id INT NOT NULL,
    appointment_date DATETIME NOT NULL,
    status ENUM(
		"Scheduled",
        "Completed",
        "Canclled") NOT NULL DEFAULT "Scheduled",
	FOREIGN KEY (patient_id) REFERENCES patients(patient_id),
	FOREIGN KEY (doctor_id)  REFERENCES doctors(doctor_id)
        );

CREATE TABLE medical_records(
	record_id INT AUTO_INCREMENT PRIMARY KEY,
    patient_id INT NOT NULL,
    doctor_id INT NOT NULL,
    diagnosis VARCHAR(250) NOT NULL,
    prescription TEXT,
	treatment_date DATETIME NOT NULL,
    admission_date DATE,
    discharge_date DATE,
   
	FOREIGN KEY (patient_id) REFERENCES patients(patient_id),
	FOREIGN KEY (doctor_id)  REFERENCES doctors(doctor_id)
);

CREATE TABLE billing (
    invoice_id INT AUTO_INCREMENT PRIMARY KEY,
    patient_id INT NOT NULL,
    appointment_id INT NOT NULL,
    amount DECIMAL(10,2) NOT NULL,

    payment_status ENUM(
        'Paid',
        'Pending',
        'Cancelled'
    ) NOT NULL DEFAULT 'Pending',

    payment_date DATE,

    FOREIGN KEY (patient_id)
        REFERENCES patients(patient_id),

    FOREIGN KEY (appointment_id)
        REFERENCES appointments(appointment_id)
);

CREATE TABLE doctor_department (
    doctor_id INT NOT NULL,
    department_id INT NOT NULL,

    PRIMARY KEY (doctor_id, department_id),

    FOREIGN KEY (doctor_id)
        REFERENCES doctors(doctor_id),

    FOREIGN KEY (department_id)
        REFERENCES departments(department_id)
);

SHOW TABLES;

INSERT INTO patients(patient_id, name, dob, gender, phone_number, email, address, registration_date)
VALUES
(1,"Jhon", "2002-04-12", "Male", "9635875698", "jhon@gmail.com", "Rajkot", DATE_SUB(CURDATE(), INTERVAL 2 MONTH)),
(2,"David", "1998-04-12", "Male", "9635875456", "david@gmail.com", "Surat", DATE_SUB(CURDATE(), INTERVAL 3 MONTH)),
(3,"Alisa", "2000-04-12", "Female", "9635875321", "alisa@gmail.com", "Rajkot", DATE_SUB(CURDATE(), INTERVAL 5 MONTH));

INSERT INTO doctors
(name, specializtion, phone_number, email, available_days, consultation_fee, joining_date)
VALUES
( "Dr. Anil Shah", "Cardiology", "9123400001", "anil@hospital.com", "Mon, Wed, Fri", 1500, "2008-05-10"),
("Dr. Meera Patel", "Neurology", "9123400002", "meera@hospital.com", "Tue, Thu", 1800, "2016-01-20");

UPDATE doctors SET mentor_doctor_id = 1 WHERE doctor_id IN (2,3);
UPDATE doctors SET mentor_doctor_id = 2 WHERE doctor_id IN (4,5);

INSERT INTO departments (department_name)
VALUES
('Cardiology'),
('Neurology'),
('Dermatology'),
('Orthopedics'),
('General Medicine');

INSERT INTO doctor_department(doctor_id,department_id)
VALUES
(1, 1),
(2, 2);

INSERT INTO appointments(appointment_id, patient_id, doctor_id, appointment_date, status)
VALUES
(1, 1, 1, DATE_SUB(NOW(), INTERVAL 1 MONTH), "Scheduled"),
(2, 2, 2, DATE_SUB(NOW(), INTERVAL 2 MONTH), "Completed");

INSERT INTO medical_records(record_id, patient_id, doctor_id, diagnosis, prescription, treatment_date, admission_date, discharge_date)
VALUES
(1, 1, 1, 'Hypertension', 'BP monitoring', DATE_SUB(CURDATE(), INTERVAL 1 MONTH), DATE_SUB(CURDATE(), INTERVAL 1 MONTH), DATE_SUB(CURDATE(), INTERVAL 29 DAY)),
(2, 1, 2, 'Migraine', 'Migraine medicine',DATE_SUB(CURDATE(), INTERVAL 4 MONTH),DATE_SUB(CURDATE(), INTERVAL 4 MONTH),DATE_SUB(CURDATE(), INTERVAL 119 DAY));

INSERT INTO billing (invoice_id, patient_id, appointment_id, amount, payment_status, payment_date)
VALUES
(1, 1, 1, 1500, 'Paid', DATE_SUB(CURDATE(), INTERVAL 1 MONTH)),
(2, 2, 2, 1800, 'Paid', DATE_SUB(CURDATE(), INTERVAL 2 MONTH));

SELECT * FROM Patients;
SELECT * FROM Doctors;
SELECT * FROM Departments;
SELECT * FROM Appointments;
SELECT * FROM Medical_Records;
SELECT * FROM Billing;
SELECT * FROM Doctor_Department;

INSERT INTO patients(name, dob, gender, phone_number, email, address, registration_date)
VALUES
('Demo Patient', '1999-01-01', 'Other', '9000000000', 'demo.patient@example.com', 'Old Address', CURDATE());
SET @demo_patient_id = LAST_INSERT_ID();

DELETE FROM appointments WHERE status = "Completed" AND appointment_date < DATE_SUB(NOW(), INTERVAL 6 MONTH);

SELECT * FROM patients;

SELECT patient_id, name FROM patients WHERE registration_date >= DATE_SUB(CURDATE(), INTERVAL 1 YEAR) ORDER BY registration_date DESC;

SELECT doctor_id, name FROM doctors WHERE consultation_fee  > 1000 ORDER BY consultation_fee DESC;

SELECT specializtion, AVG(consultation_fee) AS average_fee FROM doctors GROUP BY specializtion HAVING AVG(consultation_fee) > 1000;

SELECT * FROM appointments WHERE status = "Scheduled" AND doctor_id = 2;

SELECT COALESCE(SUM(amount),0) AS total_revenue FROM billing WHERE payment_status = "Paid";
SELECT MIN(consultation_fee) AS lowest_fee, MAX(consultation_fee) AS highest_fee, COUNT(*) AS total_doctors FROM doctors;

SELECT mr.record_id FROM medical_records mr LEFT JOIN patients p ON mr.patient_id = p.patient_id 
	LEFT JOIN doctors d ON mr.doctor_id = d.doctor_id WHERE p.patient_id IS NULL OR d.doctor_id IS NULL;

SELECT d.doctor_id,
       d.name AS doctor_name,
       dep.department_name
FROM Doctors d
INNER JOIN Doctor_Department dd
    ON d.doctor_id = dd.doctor_id
INNER JOIN Departments dep
    ON dd.department_id = dep.department_id
ORDER BY d.name;

SELECT
    YEAR(appointment_date) AS appointment_year,
    MONTH(appointment_date) AS appointment_month,
    COUNT(*) AS total_appointments
FROM Appointments
GROUP BY
    YEAR(appointment_date),
    MONTH(appointment_date)
ORDER BY appointment_year, appointment_month;

SELECT patient_id,
       UPPER(name) AS uppercase_name
FROM Patients;

SELECT doctor_id,
       doctor_name,
       patients_treated,
       RANK() OVER (
           ORDER BY patients_treated DESC
       ) AS doctor_rank
FROM (
    SELECT d.doctor_id,
           d.name AS doctor_name,
           COUNT(DISTINCT mr.patient_id) AS patients_treated
    FROM Doctors d
    LEFT JOIN Medical_Records mr
        ON d.doctor_id = mr.doctor_id
    GROUP BY d.doctor_id, d.name
) AS doctor_counts
ORDER BY doctor_rank, doctor_name;

SELECT name,
       consultation_fee,
       ROW_NUMBER() OVER (
           ORDER BY consultation_fee DESC
       ) AS row_num,
       RANK() OVER (
           ORDER BY consultation_fee DESC
       ) AS fee_rank,
       DENSE_RANK() OVER (
           ORDER BY consultation_fee DESC
       ) AS dense_fee_rank
FROM Doctors;