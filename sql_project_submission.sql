```sql
-- 1. CREATE TABLES

CREATE TABLE Patients (
    patient_id INT PRIMARY KEY,
    name VARCHAR(100) NOT NULL,
    age INT,
    gender VARCHAR(10),
    phone VARCHAR(15),
    address VARCHAR(255),
    registration_date DATE
);

CREATE TABLE Doctors (
    doctor_id INT PRIMARY KEY,
    name VARCHAR(100),
    specialization VARCHAR(100),
    phone VARCHAR(15),
    joining_date DATE
);

CREATE TABLE Appointments (
    appointment_id INT PRIMARY KEY,
    patient_id INT,
    doctor_id INT,
    appointment_date DATE,
    status VARCHAR(20),
    FOREIGN KEY (patient_id) REFERENCES Patients(patient_id),
    FOREIGN KEY (doctor_id) REFERENCES Doctors(doctor_id)
);

CREATE TABLE Rooms (
    room_id INT PRIMARY KEY,
    room_type VARCHAR(50),
    availability_status VARCHAR(20)
);

CREATE TABLE Admissions (
    admission_id INT PRIMARY KEY,
    patient_id INT,
    room_id INT,
    admission_date DATE,
    discharge_date DATE,
    FOREIGN KEY (patient_id) REFERENCES Patients(patient_id),
    FOREIGN KEY (room_id) REFERENCES Rooms(room_id)
);

CREATE TABLE Bills (
    bill_id INT PRIMARY KEY,
    patient_id INT,
    total_amount DECIMAL(10,2),
    payment_status VARCHAR(20),
    bill_date DATE,
    FOREIGN KEY (patient_id) REFERENCES Patients(patient_id)
);


-- 2. INSERT SAMPLE DATA

INSERT INTO Patients VALUES
(1, 'Ravi', 55, 'Male', '9876543210', 'Chennai', '2025-01-10'),
(2, 'Priya', 30, 'Female', '9876543211', 'Bangalore', '2025-02-15'),
(3, 'Kumar', 65, 'Male', '9876543212', 'Hyderabad', '2025-03-20'),
(4, 'Anita', 42, 'Female', '9876543213', 'Mumbai', '2025-04-12'),
(5, 'Arun', 25, 'Male', '9876543214', 'Chennai', '2025-05-18');

INSERT INTO Doctors VALUES
(101, 'Dr. Suresh', 'Cardiology', '9000000001', '2020-01-10'),
(102, 'Dr. Meena', 'Neurology', '9000000002', '2019-05-15'),
(103, 'Dr. Raj', 'Cardiology', '9000000003', '2021-03-20'),
(104, 'Dr. Divya', 'Orthopedics', '9000000004', '2022-07-01');

INSERT INTO Appointments VALUES
(1001, 1, 101, CURDATE(), 'Completed'),
(1002, 2, 102, CURDATE(), 'Scheduled'),
(1003, 1, 101, '2025-06-10', 'Completed'),
(1004, 3, 103, '2025-06-15', 'Cancelled'),
(1005, 4, 104, '2025-06-20', 'Scheduled'),
(1006, 2, 101, '2025-06-25', 'Completed'),
(1007, 1, 103, '2025-07-01', 'Completed');

INSERT INTO Rooms VALUES
(201, 'General', 'Available'),
(202, 'Private', 'Occupied'),
(203, 'ICU', 'Available'),
(204, 'General', 'Occupied');

INSERT INTO Admissions VALUES
(301, 1, 202, '2025-06-01', '2025-06-05'),
(302, 2, 204, '2025-06-10', NULL),
(303, 1, 201, '2025-07-01', '2025-07-04'),
(304, 3, 203, '2025-07-05', NULL);

INSERT INTO Bills VALUES
(401, 1, 15000, 'Paid', '2025-06-05'),
(402, 2, 25000, 'Unpaid', '2025-06-10'),
(403, 3, 35000, 'Paid', '2025-06-15'),
(404, 4, 12000, 'Paid', '2025-06-20'),
(405, 1, 8000, 'Paid', '2025-07-04');


-- 3. BASIC QUERIES

SELECT * FROM Patients WHERE age > 50;

SELECT * FROM Doctors
WHERE specialization = 'Cardiology';

SELECT * FROM Appointments
WHERE appointment_date = CURDATE();

SELECT * FROM Rooms
WHERE availability_status = 'Available';


-- 4. JOINS

SELECT p.name AS patient_name, d.name AS doctor_name
FROM Appointments a
JOIN Patients p ON a.patient_id = p.patient_id
JOIN Doctors d ON a.doctor_id = d.doctor_id;

SELECT a.*, p.name AS patient_name, p.phone
FROM Appointments a
JOIN Patients p ON a.patient_id = p.patient_id;

SELECT ad.*, p.name AS patient_name, r.room_type
FROM Admissions ad
JOIN Patients p ON ad.patient_id = p.patient_id
JOIN Rooms r ON ad.room_id = r.room_id;

SELECT b.*, p.name AS patient_name
FROM Bills b
JOIN Patients p ON b.patient_id = p.patient_id;

SELECT d.name AS doctor_name, p.name AS patient_name
FROM Appointments a
JOIN Doctors d ON a.doctor_id = d.doctor_id
JOIN Patients p ON a.patient_id = p.patient_id;


-- 5. AGGREGATE FUNCTIONS

SELECT COUNT(*) AS total_patients FROM Patients;

SELECT AVG(age) AS average_age FROM Patients;

SELECT SUM(total_amount) AS total_revenue FROM Bills;

SELECT COUNT(*) AS total_appointments FROM Appointments;

SELECT MAX(total_amount) AS highest_bill FROM Bills;


-- 6. SUBQUERIES

SELECT * FROM Patients p
WHERE NOT EXISTS (
    SELECT 1 FROM Appointments a
    WHERE a.patient_id = p.patient_id
);

SELECT * FROM Doctors d
WHERE NOT EXISTS (
    SELECT 1 FROM Appointments a
    WHERE a.doctor_id = d.doctor_id
);

SELECT * FROM Bills
WHERE total_amount > (
    SELECT AVG(total_amount) FROM Bills
);

SELECT p.*
FROM Patients p
JOIN Admissions ad ON p.patient_id = ad.patient_id
GROUP BY p.patient_id, p.name, p.age, p.gender,
         p.phone, p.address, p.registration_date
HAVING COUNT(ad.admission_id) > 1;

SELECT d.doctor_id, d.name, COUNT(a.appointment_id) AS appointment_count
FROM Doctors d
JOIN Appointments a ON d.doctor_id = a.doctor_id
GROUP BY d.doctor_id, d.name
HAVING COUNT(a.appointment_id) > (
    SELECT AVG(appointment_count)
    FROM (
        SELECT COUNT(*) AS appointment_count
        FROM Appointments
        GROUP BY doctor_id
    ) AS doctor_counts
);


-- 7. UPDATES AND DELETES

UPDATE Patients
SET phone = '9999999999'
WHERE patient_id = 1;

UPDATE Doctors
SET specialization = 'Neurology'
WHERE doctor_id = 101;

UPDATE Rooms
SET availability_status = 'Available'
WHERE room_id = 202;

DELETE FROM Appointments
WHERE status = 'Cancelled';

-- Delete patients who have no appointments, admissions, or bills.
DELETE FROM Patients
WHERE NOT EXISTS (
    SELECT 1 FROM Appointments a
    WHERE a.patient_id = Patients.patient_id
)
AND NOT EXISTS (
    SELECT 1 FROM Admissions ad
    WHERE ad.patient_id = Patients.patient_id
)
AND NOT EXISTS (
    SELECT 1 FROM Bills b
    WHERE b.patient_id = Patients.patient_id
);


-- 8. VIEWS

CREATE VIEW PatientAppointments AS
SELECT p.name AS patient_name, d.name AS doctor_name,
       a.appointment_date, a.status
FROM Appointments a
JOIN Patients p ON a.patient_id = p.patient_id
JOIN Doctors d ON a.doctor_id = d.doctor_id;

CREATE VIEW DoctorDetails AS
SELECT doctor_id, name, specialization, phone, joining_date
FROM Doctors;

CREATE VIEW AdmissionDetails AS
SELECT ad.admission_id, p.name AS patient_name,
       r.room_type, ad.admission_date, ad.discharge_date
FROM Admissions ad
JOIN Patients p ON ad.patient_id = p.patient_id
JOIN Rooms r ON ad.room_id = r.room_id;

CREATE VIEW PatientBilling AS
SELECT p.patient_id, p.name,
       COALESCE(SUM(b.total_amount), 0) AS total_billing
FROM Patients p
LEFT JOIN Bills b ON p.patient_id = b.patient_id
GROUP BY p.patient_id, p.name;

CREATE VIEW MostVisitedDoctors AS
SELECT d.doctor_id, d.name, COUNT(a.appointment_id) AS total_visits
FROM Doctors d
LEFT JOIN Appointments a ON d.doctor_id = a.doctor_id
GROUP BY d.doctor_id, d.name;


-- 9. STORED PROCEDURES

DELIMITER //

CREATE PROCEDURE InsertPatient(
    IN p_name VARCHAR(100),
    IN p_age INT,
    IN p_gender VARCHAR(10),
    IN p_phone VARCHAR(15),
    IN p_address VARCHAR(255),
    IN p_registration_date DATE
)
BEGIN
    INSERT INTO Patients
        (patient_id, name, age, gender, phone, address, registration_date)
    VALUES
        ((SELECT COALESCE(MAX(patient_id), 0) + 1 FROM Patients),
         p_name, p_age, p_gender, p_phone, p_address, p_registration_date);
END //

CREATE PROCEDURE UpdateRoomStatus(
    IN p_room_id INT,
    IN p_status VARCHAR(20)
)
BEGIN
    UPDATE Rooms
    SET availability_status = p_status
    WHERE room_id = p_room_id;
END //

CREATE PROCEDURE GetPatientAppointments(
    IN p_patient_id INT
)
BEGIN
    SELECT a.*, d.name AS doctor_name
    FROM Appointments a
    JOIN Doctors d ON a.doctor_id = d.doctor_id
    WHERE a.patient_id = p_patient_id;
END //

CREATE PROCEDURE CalculateTotalRevenue()
BEGIN
    SELECT COALESCE(SUM(total_amount), 0) AS total_revenue
    FROM Bills;
END //

CREATE PROCEDURE GetDoctorsBySpecialization(
    IN p_specialization VARCHAR(100)
)
BEGIN
    SELECT *
    FROM Doctors
    WHERE specialization = p_specialization;
END //

DELIMITER ;


-- 10. REPORTS AND ANALYSIS

-- Top 5 doctors with the most appointments
SELECT d.doctor_id, d.name, COUNT(a.appointment_id) AS total_appointments
FROM Doctors d
LEFT JOIN Appointments a ON d.doctor_id = a.doctor_id
GROUP BY d.doctor_id, d.name
ORDER BY total_appointments DESC
LIMIT 5;

-- Most frequent patients
SELECT p.patient_id, p.name, COUNT(a.appointment_id) AS total_visits
FROM Patients p
JOIN Appointments a ON p.patient_id = a.patient_id
GROUP BY p.patient_id, p.name
ORDER BY total_visits DESC;

-- Monthly appointment report
SELECT YEAR(appointment_date) AS year,
       MONTH(appointment_date) AS month,
       COUNT(*) AS total_appointments
FROM Appointments
GROUP BY YEAR(appointment_date), MONTH(appointment_date)
ORDER BY year, month;

-- Doctor generating the highest revenue
SELECT d.doctor_id, d.name,
       SUM(b.total_amount) AS total_revenue
FROM Doctors d
JOIN Appointments a ON d.doctor_id = a.doctor_id
JOIN Bills b ON a.patient_id = b.patient_id
GROUP BY d.doctor_id, d.name
ORDER BY total_revenue DESC
LIMIT 1;

-- Patient billing analysis
SELECT p.patient_id, p.name,
       COUNT(b.bill_id) AS total_bills,
       COALESCE(SUM(b.total_amount), 0) AS total_billing,
       COALESCE(SUM(
           CASE WHEN b.payment_status = 'Paid'
                THEN b.total_amount ELSE 0 END
       ), 0) AS paid_amount,
       COALESCE(SUM(
           CASE WHEN b.payment_status = 'Unpaid'
                THEN b.total_amount ELSE 0 END
       ), 0) AS unpaid_amount
FROM Patients p
LEFT JOIN Bills b ON p.patient_id = b.patient_id
GROUP BY p.patient_id, p.name;

-- Most demanded specialization
SELECT d.specialization,
       COUNT(a.appointment_id) AS total_appointments
FROM Doctors d
LEFT JOIN Appointments a ON d.doctor_id = a.doctor_id
GROUP BY d.specialization
ORDER BY total_appointments DESC
LIMIT 1;
```


-- ============================================================
-- 11. ONLINE STORE (MINI E-COMMERCE)
-- ============================================================

CREATE TABLE StoreCustomers (
    customer_id INT PRIMARY KEY,
    name VARCHAR(100) NOT NULL,
    email VARCHAR(120) UNIQUE NOT NULL,
    phone VARCHAR(15),
    address VARCHAR(255),
    registration_date DATE
);

CREATE TABLE StoreCategories (
    category_id INT PRIMARY KEY,
    category_name VARCHAR(100) NOT NULL UNIQUE
);

CREATE TABLE StoreProducts (
    product_id INT PRIMARY KEY,
    category_id INT,
    product_name VARCHAR(150) NOT NULL,
    price DECIMAL(10,2) NOT NULL,
    stock_quantity INT NOT NULL DEFAULT 0,
    FOREIGN KEY (category_id) REFERENCES StoreCategories(category_id)
);

CREATE TABLE StoreOrders (
    order_id INT PRIMARY KEY,
    customer_id INT NOT NULL,
    order_date DATE NOT NULL,
    order_status VARCHAR(30) NOT NULL,
    total_amount DECIMAL(10,2) DEFAULT 0,
    FOREIGN KEY (customer_id) REFERENCES StoreCustomers(customer_id)
);

CREATE TABLE StoreOrderItems (
    order_item_id INT PRIMARY KEY,
    order_id INT NOT NULL,
    product_id INT NOT NULL,
    quantity INT NOT NULL,
    unit_price DECIMAL(10,2) NOT NULL,
    FOREIGN KEY (order_id) REFERENCES StoreOrders(order_id),
    FOREIGN KEY (product_id) REFERENCES StoreProducts(product_id)
);

CREATE TABLE StorePayments (
    payment_id INT PRIMARY KEY,
    order_id INT NOT NULL,
    payment_date DATE,
    amount DECIMAL(10,2) NOT NULL,
    payment_method VARCHAR(30),
    payment_status VARCHAR(20),
    FOREIGN KEY (order_id) REFERENCES StoreOrders(order_id)
);

INSERT INTO StoreCustomers VALUES
(1, 'Rahul', 'rahul@example.com', '9000001001', 'Vijayawada', '2025-01-05'),
(2, 'Sneha', 'sneha@example.com', '9000001002', 'Hyderabad', '2025-01-12'),
(3, 'Vikram', 'vikram@example.com', '9000001003', 'Chennai', '2025-02-10'),
(4, 'Neha', 'neha@example.com', '9000001004', 'Bangalore', '2025-03-01');

INSERT INTO StoreCategories VALUES
(1, 'Electronics'),
(2, 'Books'),
(3, 'Accessories');

INSERT INTO StoreProducts VALUES
(101, 1, 'Wireless Headphones', 2500.00, 50),
(102, 1, 'Bluetooth Speaker', 1800.00, 35),
(103, 2, 'SQL Programming Book', 900.00, 40),
(104, 3, 'Laptop Backpack', 1500.00, 25),
(105, 3, 'Wireless Mouse', 700.00, 60);

INSERT INTO StoreOrders VALUES
(1001, 1, '2025-06-01', 'Delivered', 4300.00),
(1002, 2, '2025-06-03', 'Shipped', 2400.00),
(1003, 1, '2025-06-05', 'Delivered', 1500.00),
(1004, 3, '2025-06-07', 'Pending', 2500.00);

INSERT INTO StoreOrderItems VALUES
(1, 1001, 101, 1, 2500.00),
(2, 1001, 105, 1, 700.00),
(3, 1001, 103, 1, 900.00),
(4, 1002, 102, 1, 1800.00),
(5, 1002, 105, 1, 600.00),
(6, 1003, 104, 1, 1500.00),
(7, 1004, 101, 1, 2500.00);

INSERT INTO StorePayments VALUES
(1, 1001, '2025-06-01', 4100.00, 'UPI', 'Paid'),
(2, 1002, '2025-06-03', 2400.00, 'Card', 'Paid'),
(3, 1003, '2025-06-05', 1500.00, 'Cash', 'Paid'),
(4, 1004, NULL, 2500.00, 'UPI', 'Pending');

-- Store basic queries
SELECT * FROM StoreProducts WHERE stock_quantity < 30;
SELECT * FROM StoreOrders WHERE order_status = 'Pending';

-- Store joins
SELECT o.order_id, c.name AS customer_name, o.order_date,
       o.order_status, o.total_amount
FROM StoreOrders o
JOIN StoreCustomers c ON o.customer_id = c.customer_id;

SELECT o.order_id, p.product_name, oi.quantity, oi.unit_price
FROM StoreOrderItems oi
JOIN StoreOrders o ON oi.order_id = o.order_id
JOIN StoreProducts p ON oi.product_id = p.product_id;

-- Store aggregate/subquery
SELECT category_id, COUNT(*) AS product_count,
       AVG(price) AS average_price
FROM StoreProducts
GROUP BY category_id;

SELECT *
FROM StoreProducts
WHERE price > (SELECT AVG(price) FROM StoreProducts);

SELECT c.customer_id, c.name,
       COALESCE(SUM(o.total_amount), 0) AS total_spent
FROM StoreCustomers c
LEFT JOIN StoreOrders o ON c.customer_id = o.customer_id
GROUP BY c.customer_id, c.name
ORDER BY total_spent DESC;

CREATE VIEW StoreOrderDetails AS
SELECT o.order_id, c.name AS customer_name, p.product_name,
       oi.quantity, oi.unit_price,
       oi.quantity * oi.unit_price AS item_total,
       o.order_status
FROM StoreOrders o
JOIN StoreCustomers c ON o.customer_id = c.customer_id
JOIN StoreOrderItems oi ON o.order_id = oi.order_id
JOIN StoreProducts p ON oi.product_id = p.product_id;

CREATE VIEW StoreSalesSummary AS
SELECT p.product_id, p.product_name,
       COALESCE(SUM(oi.quantity), 0) AS units_sold,
       COALESCE(SUM(oi.quantity * oi.unit_price), 0) AS sales_amount
FROM StoreProducts p
LEFT JOIN StoreOrderItems oi ON p.product_id = oi.product_id
GROUP BY p.product_id, p.product_name;

-- ============================================================
-- 12. MOVIE TICKET BOOKING SYSTEM
-- ============================================================

CREATE TABLE Movies (
    movie_id INT PRIMARY KEY,
    title VARCHAR(150) NOT NULL,
    genre VARCHAR(50),
    language VARCHAR(30),
    duration_minutes INT,
    release_date DATE
);

CREATE TABLE Theatres (
    theatre_id INT PRIMARY KEY,
    theatre_name VARCHAR(120) NOT NULL,
    city VARCHAR(80),
    total_screens INT
);

CREATE TABLE Screens (
    screen_id INT PRIMARY KEY,
    theatre_id INT NOT NULL,
    screen_name VARCHAR(50),
    total_seats INT,
    FOREIGN KEY (theatre_id) REFERENCES Theatres(theatre_id)
);

CREATE TABLE Shows (
    show_id INT PRIMARY KEY,
    movie_id INT NOT NULL,
    screen_id INT NOT NULL,
    show_date DATE NOT NULL,
    show_time TIME NOT NULL,
    ticket_price DECIMAL(8,2) NOT NULL,
    FOREIGN KEY (movie_id) REFERENCES Movies(movie_id),
    FOREIGN KEY (screen_id) REFERENCES Screens(screen_id)
);

CREATE TABLE MovieCustomers (
    customer_id INT PRIMARY KEY,
    name VARCHAR(100) NOT NULL,
    email VARCHAR(120) UNIQUE,
    phone VARCHAR(15)
);

CREATE TABLE MovieBookings (
    booking_id INT PRIMARY KEY,
    customer_id INT NOT NULL,
    show_id INT NOT NULL,
    booking_date DATE NOT NULL,
    seats_booked INT NOT NULL,
    total_amount DECIMAL(10,2) NOT NULL,
    booking_status VARCHAR(20) NOT NULL,
    FOREIGN KEY (customer_id) REFERENCES MovieCustomers(customer_id),
    FOREIGN KEY (show_id) REFERENCES Shows(show_id)
);

CREATE TABLE MoviePayments (
    payment_id INT PRIMARY KEY,
    booking_id INT NOT NULL,
    payment_method VARCHAR(30),
    payment_date DATE,
    amount DECIMAL(10,2),
    payment_status VARCHAR(20),
    FOREIGN KEY (booking_id) REFERENCES MovieBookings(booking_id)
);

INSERT INTO Movies VALUES
(1, 'The Adventure', 'Action', 'English', 140, '2025-01-10'),
(2, 'Love Story', 'Romance', 'Telugu', 130, '2025-02-14'),
(3, 'Mystery House', 'Thriller', 'Hindi', 120, '2025-03-01'),
(4, 'Future World', 'Sci-Fi', 'English', 150, '2025-04-10');

INSERT INTO Theatres VALUES
(1, 'City Cinemas', 'Vijayawada', 3),
(2, 'Grand Movies', 'Hyderabad', 4);

INSERT INTO Screens VALUES
(101, 1, 'Screen 1', 120),
(102, 1, 'Screen 2', 100),
(201, 2, 'Screen 1', 150),
(202, 2, 'Screen 2', 120);

INSERT INTO Shows VALUES
(1001, 1, 101, '2025-06-15', '18:00:00', 250.00),
(1002, 2, 102, '2025-06-15', '19:00:00', 200.00),
(1003, 3, 201, '2025-06-16', '17:30:00', 220.00),
(1004, 4, 202, '2025-06-16', '20:00:00', 300.00);

INSERT INTO MovieCustomers VALUES
(1, 'Amit', 'amit@example.com', '9000010001'),
(2, 'Pooja', 'pooja@example.com', '9000010002'),
(3, 'Kiran', 'kiran@example.com', '9000010003'),
(4, 'Meena', 'meena@example.com', '9000010004');

INSERT INTO MovieBookings VALUES
(5001, 1, 1001, '2025-06-10', 2, 500.00, 'Confirmed'),
(5002, 2, 1002, '2025-06-11', 3, 600.00, 'Confirmed'),
(5003, 3, 1003, '2025-06-12', 2, 440.00, 'Confirmed'),
(5004, 4, 1004, '2025-06-12', 4, 1200.00, 'Cancelled');

INSERT INTO MoviePayments VALUES
(1, 5001, 'UPI', '2025-06-10', 500.00, 'Paid'),
(2, 5002, 'Card', '2025-06-11', 600.00, 'Paid'),
(3, 5003, 'UPI', '2025-06-12', 440.00, 'Paid'),
(4, 5004, 'Card', '2025-06-12', 1200.00, 'Refunded');

-- Movie booking queries
SELECT s.show_id, m.title, t.theatre_name, t.city,
       s.show_date, s.show_time, s.ticket_price
FROM Shows s
JOIN Movies m ON s.movie_id = m.movie_id
JOIN Screens sc ON s.screen_id = sc.screen_id
JOIN Theatres t ON sc.theatre_id = t.theatre_id;

SELECT m.title, SUM(b.seats_booked) AS total_tickets
FROM Movies m
JOIN Shows s ON m.movie_id = s.movie_id
JOIN MovieBookings b ON s.show_id = b.show_id
WHERE b.booking_status = 'Confirmed'
GROUP BY m.movie_id, m.title
ORDER BY total_tickets DESC;

SELECT *
FROM MovieBookings
WHERE booking_status = 'Confirmed'
  AND total_amount > (SELECT AVG(total_amount)
                      FROM MovieBookings
                      WHERE booking_status = 'Confirmed');

CREATE VIEW MovieBookingDetails AS
SELECT b.booking_id, c.name AS customer_name,
       m.title, t.theatre_name, t.city,
       s.show_date, s.show_time,
       b.seats_booked, b.total_amount, b.booking_status
FROM MovieBookings b
JOIN MovieCustomers c ON b.customer_id = c.customer_id
JOIN Shows s ON b.show_id = s.show_id
JOIN Movies m ON s.movie_id = m.movie_id
JOIN Screens sc ON s.screen_id = sc.screen_id
JOIN Theatres t ON sc.theatre_id = t.theatre_id;

CREATE VIEW MovieRevenueReport AS
SELECT m.movie_id, m.title,
       COALESCE(SUM(CASE WHEN b.booking_status = 'Confirmed'
                         THEN b.total_amount ELSE 0 END), 0) AS revenue
FROM Movies m
LEFT JOIN Shows s ON m.movie_id = s.movie_id
LEFT JOIN MovieBookings b ON s.show_id = b.show_id
GROUP BY m.movie_id, m.title;

-- ============================================================
-- 13. GYM MEMBERSHIP MANAGEMENT SYSTEM
-- ============================================================

CREATE TABLE GymMembers (
    member_id INT PRIMARY KEY,
    name VARCHAR(100) NOT NULL,
    gender VARCHAR(10),
    age INT,
    phone VARCHAR(15),
    join_date DATE,
    status VARCHAR(20)
);

CREATE TABLE GymPlans (
    plan_id INT PRIMARY KEY,
    plan_name VARCHAR(80) NOT NULL,
    duration_months INT NOT NULL,
    fee DECIMAL(10,2) NOT NULL
);

CREATE TABLE GymMemberships (
    membership_id INT PRIMARY KEY,
    member_id INT NOT NULL,
    plan_id INT NOT NULL,
    start_date DATE NOT NULL,
    end_date DATE NOT NULL,
    membership_status VARCHAR(20),
    FOREIGN KEY (member_id) REFERENCES GymMembers(member_id),
    FOREIGN KEY (plan_id) REFERENCES GymPlans(plan_id)
);

CREATE TABLE GymTrainers (
    trainer_id INT PRIMARY KEY,
    trainer_name VARCHAR(100) NOT NULL,
    specialization VARCHAR(80),
    phone VARCHAR(15)
);

CREATE TABLE GymTrainerAssignments (
    assignment_id INT PRIMARY KEY,
    member_id INT NOT NULL,
    trainer_id INT NOT NULL,
    assignment_date DATE,
    FOREIGN KEY (member_id) REFERENCES GymMembers(member_id),
    FOREIGN KEY (trainer_id) REFERENCES GymTrainers(trainer_id)
);

CREATE TABLE GymPayments (
    payment_id INT PRIMARY KEY,
    membership_id INT NOT NULL,
    payment_date DATE,
    amount DECIMAL(10,2),
    payment_method VARCHAR(30),
    payment_status VARCHAR(20),
    FOREIGN KEY (membership_id) REFERENCES GymMemberships(membership_id)
);

CREATE TABLE GymAttendance (
    attendance_id INT PRIMARY KEY,
    member_id INT NOT NULL,
    attendance_date DATE,
    check_in TIME,
    check_out TIME,
    FOREIGN KEY (member_id) REFERENCES GymMembers(member_id)
);

INSERT INTO GymMembers VALUES
(1, 'Arjun', 'Male', 25, '9100000001', '2025-01-05', 'Active'),
(2, 'Divya', 'Female', 29, '9100000002', '2025-02-10', 'Active'),
(3, 'Ramesh', 'Male', 35, '9100000003', '2025-03-15', 'Active'),
(4, 'Kavya', 'Female', 24, '9100000004', '2025-04-20', 'Inactive');

INSERT INTO GymPlans VALUES
(1, 'Monthly', 1, 1500.00),
(2, 'Quarterly', 3, 4000.00),
(3, 'Half Yearly', 6, 7500.00),
(4, 'Yearly', 12, 14000.00);

INSERT INTO GymMemberships VALUES
(1001, 1, 2, '2025-01-05', '2025-04-04', 'Expired'),
(1002, 2, 4, '2025-02-10', '2026-02-09', 'Active'),
(1003, 3, 3, '2025-03-15', '2025-09-14', 'Active'),
(1004, 4, 1, '2025-04-20', '2025-05-19', 'Expired');

INSERT INTO GymTrainers VALUES
(201, 'Vijay', 'Strength Training', '9200000001'),
(202, 'Anjali', 'Yoga', '9200000002'),
(203, 'Sanjay', 'Cardio', '9200000003');

INSERT INTO GymTrainerAssignments VALUES
(1, 1, 201, '2025-01-06'),
(2, 2, 202, '2025-02-11'),
(3, 3, 201, '2025-03-16');

INSERT INTO GymPayments VALUES
(1, 1001, '2025-01-05', 4000.00, 'UPI', 'Paid'),
(2, 1002, '2025-02-10', 14000.00, 'Card', 'Paid'),
(3, 1003, '2025-03-15', 7500.00, 'UPI', 'Paid'),
(4, 1004, '2025-04-20', 1500.00, 'Cash', 'Paid');

INSERT INTO GymAttendance VALUES
(1, 1, '2025-06-01', '06:30:00', '07:45:00'),
(2, 2, '2025-06-01', '07:00:00', '08:10:00'),
(3, 1, '2025-06-02', '06:40:00', '07:50:00'),
(4, 3, '2025-06-02', '18:00:00', '19:20:00'),
(5, 2, '2025-06-03', '07:05:00', '08:15:00');

-- Gym queries
SELECT * FROM GymMembers WHERE status = 'Active';

SELECT m.name, p.plan_name, gm.start_date, gm.end_date,
       gm.membership_status
FROM GymMemberships gm
JOIN GymMembers m ON gm.member_id = m.member_id
JOIN GymPlans p ON gm.plan_id = p.plan_id;

SELECT m.name, COUNT(a.attendance_id) AS attendance_count
FROM GymMembers m
LEFT JOIN GymAttendance a ON m.member_id = a.member_id
GROUP BY m.member_id, m.name
ORDER BY attendance_count DESC;

SELECT *
FROM GymPlans
WHERE fee > (SELECT AVG(fee) FROM GymPlans);

SELECT SUM(amount) AS total_gym_revenue
FROM GymPayments
WHERE payment_status = 'Paid';

CREATE VIEW ActiveGymMemberships AS
SELECT m.member_id, m.name, p.plan_name,
       gm.start_date, gm.end_date
FROM GymMembers m
JOIN GymMemberships gm ON m.member_id = gm.member_id
JOIN GymPlans p ON gm.plan_id = p.plan_id
WHERE gm.membership_status = 'Active';

CREATE VIEW GymTrainerReport AS
SELECT t.trainer_id, t.trainer_name,
       t.specialization, COUNT(a.assignment_id) AS assigned_members
FROM GymTrainers t
LEFT JOIN GymTrainerAssignments a ON t.trainer_id = a.trainer_id
GROUP BY t.trainer_id, t.trainer_name, t.specialization;

-- ============================================================
-- 14. WAREHOUSE MANAGEMENT SYSTEM
-- ============================================================

CREATE TABLE Warehouses (
    warehouse_id INT PRIMARY KEY,
    warehouse_name VARCHAR(120) NOT NULL,
    location VARCHAR(150),
    capacity INT
);

CREATE TABLE WarehouseCategories (
    category_id INT PRIMARY KEY,
    category_name VARCHAR(100) NOT NULL
);

CREATE TABLE WarehouseProducts (
    product_id INT PRIMARY KEY,
    category_id INT,
    product_name VARCHAR(150) NOT NULL,
    unit_price DECIMAL(10,2),
    reorder_level INT,
    FOREIGN KEY (category_id) REFERENCES WarehouseCategories(category_id)
);

CREATE TABLE WarehouseInventory (
    inventory_id INT PRIMARY KEY,
    warehouse_id INT NOT NULL,
    product_id INT NOT NULL,
    quantity INT NOT NULL DEFAULT 0,
    last_updated DATE,
    FOREIGN KEY (warehouse_id) REFERENCES Warehouses(warehouse_id),
    FOREIGN KEY (product_id) REFERENCES WarehouseProducts(product_id)
);

CREATE TABLE Suppliers (
    supplier_id INT PRIMARY KEY,
    supplier_name VARCHAR(120) NOT NULL,
    phone VARCHAR(15),
    city VARCHAR(80)
);

CREATE TABLE PurchaseOrders (
    purchase_order_id INT PRIMARY KEY,
    supplier_id INT NOT NULL,
    warehouse_id INT NOT NULL,
    order_date DATE,
    status VARCHAR(30),
    total_amount DECIMAL(10,2),
    FOREIGN KEY (supplier_id) REFERENCES Suppliers(supplier_id),
    FOREIGN KEY (warehouse_id) REFERENCES Warehouses(warehouse_id)
);

CREATE TABLE PurchaseOrderItems (
    purchase_item_id INT PRIMARY KEY,
    purchase_order_id INT NOT NULL,
    product_id INT NOT NULL,
    quantity INT NOT NULL,
    unit_cost DECIMAL(10,2),
    FOREIGN KEY (purchase_order_id) REFERENCES PurchaseOrders(purchase_order_id),
    FOREIGN KEY (product_id) REFERENCES WarehouseProducts(product_id)
);

CREATE TABLE StockMovements (
    movement_id INT PRIMARY KEY,
    warehouse_id INT NOT NULL,
    product_id INT NOT NULL,
    movement_type VARCHAR(20),
    quantity INT NOT NULL,
    movement_date DATE,
    reference_no VARCHAR(50),
    FOREIGN KEY (warehouse_id) REFERENCES Warehouses(warehouse_id),
    FOREIGN KEY (product_id) REFERENCES WarehouseProducts(product_id)
);

INSERT INTO Warehouses VALUES
(1, 'Central Warehouse', 'Vijayawada', 10000),
(2, 'North Warehouse', 'Hyderabad', 8000),
(3, 'South Warehouse', 'Chennai', 7000);

INSERT INTO WarehouseCategories VALUES
(1, 'Electronics'),
(2, 'Furniture'),
(3, 'Office Supplies');

INSERT INTO WarehouseProducts VALUES
(101, 1, 'LED Monitor', 12000.00, 20),
(102, 1, 'Keyboard', 1200.00, 30),
(103, 2, 'Office Chair', 6500.00, 15),
(104, 3, 'Printer Paper Box', 2500.00, 25),
(105, 3, 'Printer Cartridge', 3500.00, 10);

INSERT INTO WarehouseInventory VALUES
(1, 1, 101, 50, '2025-06-01'),
(2, 1, 102, 100, '2025-06-01'),
(3, 2, 103, 35, '2025-06-02'),
(4, 2, 104, 20, '2025-06-02'),
(5, 3, 105, 8, '2025-06-03');

INSERT INTO Suppliers VALUES
(1, 'Tech Suppliers Pvt Ltd', '9300000001', 'Hyderabad'),
(2, 'Office Mart', '9300000002', 'Vijayawada'),
(3, 'Furniture World', '9300000003', 'Chennai');

INSERT INTO PurchaseOrders VALUES
(5001, 1, 1, '2025-06-01', 'Received', 60000.00),
(5002, 2, 2, '2025-06-02', 'Received', 50000.00),
(5003, 3, 2, '2025-06-03', 'Pending', 32500.00);

INSERT INTO PurchaseOrderItems VALUES
(1, 5001, 101, 5, 12000.00),
(2, 5002, 104, 20, 2500.00),
(3, 5003, 103, 5, 6500.00);

INSERT INTO StockMovements VALUES
(1, 1, 101, 'IN', 20, '2025-06-01', 'PO-5001'),
(2, 1, 102, 'OUT', 10, '2025-06-02', 'SALE-1001'),
(3, 2, 103, 'IN', 10, '2025-06-03', 'PO-5003'),
(4, 2, 104, 'OUT', 5, '2025-06-03', 'SALE-1002'),
(5, 3, 105, 'OUT', 3, '2025-06-04', 'SALE-1003');

-- Warehouse queries
SELECT w.warehouse_name, p.product_name, i.quantity
FROM WarehouseInventory i
JOIN Warehouses w ON i.warehouse_id = w.warehouse_id
JOIN WarehouseProducts p ON i.product_id = p.product_id
ORDER BY w.warehouse_name, p.product_name;

SELECT w.warehouse_name, p.product_name, i.quantity, p.reorder_level
FROM WarehouseInventory i
JOIN Warehouses w ON i.warehouse_id = w.warehouse_id
JOIN WarehouseProducts p ON i.product_id = p.product_id
WHERE i.quantity <= p.reorder_level;

SELECT s.supplier_name, COUNT(po.purchase_order_id) AS total_orders,
       COALESCE(SUM(po.total_amount), 0) AS total_purchase_value
FROM Suppliers s
LEFT JOIN PurchaseOrders po ON s.supplier_id = po.supplier_id
GROUP BY s.supplier_id, s.supplier_name;

SELECT p.product_name, SUM(sm.quantity) AS total_moved
FROM WarehouseProducts p
JOIN StockMovements sm ON p.product_id = sm.product_id
GROUP BY p.product_id, p.product_name
ORDER BY total_moved DESC;

SELECT *
FROM WarehouseProducts
WHERE unit_price > (SELECT AVG(unit_price) FROM WarehouseProducts);

CREATE VIEW WarehouseStockReport AS
SELECT w.warehouse_id, w.warehouse_name,
       p.product_id, p.product_name,
       i.quantity, p.reorder_level,
       CASE
           WHEN i.quantity <= p.reorder_level THEN 'REORDER'
           ELSE 'SUFFICIENT'
       END AS stock_status
FROM WarehouseInventory i
JOIN Warehouses w ON i.warehouse_id = w.warehouse_id
JOIN WarehouseProducts p ON i.product_id = p.product_id;

CREATE VIEW WarehousePurchaseReport AS
SELECT po.purchase_order_id, s.supplier_name,
       w.warehouse_name, po.order_date,
       po.status, po.total_amount
FROM PurchaseOrders po
JOIN Suppliers s ON po.supplier_id = s.supplier_id
JOIN Warehouses w ON po.warehouse_id = w.warehouse_id;

-- ============================================================
-- END OF PROJECT
-- ============================================================
