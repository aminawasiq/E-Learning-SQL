USE master;
DROP DATABASE E_LEARNING;

CREATE DATABASE E_LEARNING;
USE E_LEARNING;
------------------------Main Tables
CREATE TABLE Instructor (
    Instructor_ID INT PRIMARY KEY ,
    First_Name VARCHAR(50) NOT NULL,
    Last_Name VARCHAR(50) NOT NULL,
	Date_of_Birth DATE NOT NULL,
    Email VARCHAR(50) NOT NULL UNIQUE,
    Contact_Number VARCHAR(30) NOT NULL,
	Expertise_Area VARCHAR(50) NOT NULL,
    Education_BackgrounInstructord VARCHAR(50) NOT NULL,
    Years_of_Experience INT DEFAULT 0,    
    Address_Lines VARCHAR(255),
    Postal_Code VARCHAR(20) NOT NULL,
	City VARCHAR(20)
);

CREATE TABLE Learner (
    Learner_ID INT PRIMARY KEY,
    First_Name VARCHAR(50) NOT NULL,
    Last_Name VARCHAR(50) NOT NULL,
	Date_of_Birth DATE NOT NULL,
    Email VARCHAR(50) NOT NULL UNIQUE,
    Contact_Number VARCHAR(30) NOT NULL,
    Education_Level VARCHAR(50) NOT NULL,
    Address_Lines VARCHAR(255),
    Postal_Code VARCHAR(20) NOT NULL,
	City VARCHAR(20)
);

CREATE  TABLE Course_Categories (
    Category_ID INT PRIMARY KEY,
    Category_Name VARCHAR(100) NOT NULL UNIQUE,
    Description VARCHAR(MAX)
);

CREATE TABLE Courses (
    Course_ID INT PRIMARY KEY,
    Title VARCHAR(100) NOT NULL UNIQUE,
    Duration INT DEFAULT 0, -- Assuming the duration is measured in hours 
    Start_Date DATE,
    End_Date DATE,
	Category_ID INT
);

CREATE TABLE  Content (
    Content_ID INT PRIMARY KEY,
    Title VARCHAR(100) NOT NULL,
    Description VARCHAR(MAX),
	Order_of_Title INT,
	Course_ID INT
);

CREATE TABLE  Course_Materials (
    Course_Material_ID INT PRIMARY KEY,
    Title VARCHAR(100) NOT NULL,
    File_Category VARCHAR(100) NOT NULL,
	File_Path VARCHAR(MAX) NOT NULL,
    Upload_Date DATE DEFAULT GETDATE(),
    Order_of_Material INT NOT NULL,
    Last_Update DATETIME,
	Course_Instructor_ID INT,
	Content_ID INT
);


CREATE TABLE Course_Assessments (
    Assessment_ID INT PRIMARY KEY,
    Title VARCHAR(255) NOT NULL,
    Description VARCHAR(MAX),
    Deadline_StartTime DATETIME NOT NULL,
	Deadline_EndTime DATETIME NOT NULL,
    Order_of_Assessment INT NOT NULL,
    Max_Score DECIMAL(10, 2)  DEFAULT 0 NOT NULL,
    Creation_Date DATETIME DEFAULT GETDATE(),
	Course_Instructor_ID INT
);

CREATE TABLE Course_Type (
    Type_ID INT PRIMARY KEY,
    Type_Name VARCHAR(50) NOT NULL UNIQUE
);


CREATE TABLE Payment (
    Payment_ID INT PRIMARY KEY NOT NULL,
    Date DATE DEFAULT GETDATE() NOT NULL,
    Payment_Amount DECIMAL(15, 2)  DEFAULT 0 NOT NULL,
    Payment_Status VARCHAR(50) NOT NULL
);

CREATE TABLE User_Assessment (
    Assessment_ID INT PRIMARY KEY,
    Date DATETIME DEFAULT GETDATE() NOT NULL,
);

CREATE TABLE User_Assignment (
    Assessment_ID INT PRIMARY KEY,
    File_Name VARCHAR(255) NOT NULL,
    File_Path VARCHAR(MAX) NOT NULL
);

CREATE TABLE User_Quiz_Answers (
    Assessment_ID INT,
    Answer_ID INT NOT NULL,
    Is_Correct BIT NOT NULL,-- 0 or 1 to indicate whether the answer is correct
	Quiz_ID INT , 
    Question_ID INT
	PRIMARY KEY (Assessment_ID,Quiz_ID, Question_ID)
);

CREATE TABLE Quiz_Questions (
    Quiz_ID INT , 
    Question_ID INT,
    Question_Text NVARCHAR(MAX),
    Options NVARCHAR(MAX),
    Correct_Answer NVARCHAR(MAX),
	Course_ID INT,
	PRIMARY KEY (Quiz_ID, Question_ID)
);



CREATE TABLE Result (
    Result_ID INT PRIMARY KEY,
    Score DECIMAL(10, 2) NOT NULL,
    Feedback VARCHAR(MAX) NOT NULL,
    Status VARCHAR(50) NOT NULL,
	Assessment_ID INT,
    Instructor_ID INT
);

CREATE TABLE Attendance (
    Attendance_ID INT PRIMARY KEY,
    Date DATE NOT NULL DEFAULT GETDATE(),
    Attendance_Status VARCHAR(50) NOT NULL
);


CREATE TABLE Course_Schedule (
    Schedule_ID INT PRIMARY KEY,
    Start_Date DATE NOT NULL,
    End_Date DATE NOT NULL,
    Start_Time TIME NOT NULL,
    End_Time TIME NOT NULL,
    Link VARCHAR(255) NOT NULL,
	Course_ID INT 
);


CREATE TABLE Certificates (
    Certificate_ID INT PRIMARY KEY,
    Issue_Date DATE NOT NULL,
	Result_ID INT,
	Enrollment_ID INT,
    CONSTRAINT CK_Certificates CHECK (
        dbo.Check_Result_Passing(Result_ID) = 1
    )
);

CREATE TABLE Course_Announcement (
    Announcement_ID INT PRIMARY KEY,
    Title VARCHAR(255) NOT NULL,
    Date DATE NOT NULL DEFAULT GETDATE(),
    Description VARCHAR(MAX) NOT NULL,
	Course_Instructor_ID INT
);

CREATE TABLE Course_Prerequisite (
    Prerequisite_ID INT PRIMARY KEY,
    Course_Name INT NOT NULL UNIQUE,
    Prerequisite_Course_Name INT NOT NULL,
	Course_ID INT
);



----------Bridge Tables and Many to Many Reltionships-------------
CREATE TABLE Course_Instructor (
	Course_Instructor_ID INT PRIMARY KEY,
    Instructor_ID INT,
    Course_ID INT,
    FOREIGN KEY (Instructor_ID) REFERENCES Instructor(Instructor_ID),
    FOREIGN KEY (Course_ID) REFERENCES Courses(Course_ID)
);

CREATE TABLE Learner_Materials (
    Learner_ID INT,
    Course_Material_ID INT,
    PRIMARY KEY (Learner_ID, Course_Material_ID),
    FOREIGN KEY (Learner_ID) REFERENCES Learner(Learner_ID),
    FOREIGN KEY (Course_Material_ID) REFERENCES Course_Materials(Course_Material_ID)
);

CREATE TABLE Learner_Assignments (
    Learner_ID INT,
    Assignment_ID INT,
    PRIMARY KEY (Learner_ID, Assignment_ID),
    FOREIGN KEY (Learner_ID) REFERENCES Learner (Learner_ID),
    FOREIGN KEY (Assignment_ID) REFERENCES  Course_Assessments(Assessment_ID)
);

CREATE TABLE Fee (
    Fee_ID INT PRIMARY KEY,
    Amount DECIMAL(15, 2)  NOT NULL,
    Course_ID INT,
    Type_ID INT,
    FOREIGN KEY (Course_ID) REFERENCES Courses(Course_ID),
    FOREIGN KEY (Type_ID) REFERENCES Course_Type(Type_ID)
);


CREATE TABLE Enrollment (
    Enrollment_ID INT PRIMARY KEY,
    Enrollment_Date DATE DEFAULT GETDATE(),
    Completion_Status VARCHAR(50) NOT NULL,
    Learner_ID INT,
    Course_ID INT,
	Fee_ID INT,
    FOREIGN KEY (Learner_ID) REFERENCES Learner(Learner_ID),
    FOREIGN KEY (Course_ID) REFERENCES Courses (Course_ID)
);


CREATE TABLE Enrollment_Payment (
    Enrollment_ID INT,
    Payment_ID INT,
    PRIMARY KEY (Enrollment_ID, Payment_ID),
    FOREIGN KEY (Enrollment_ID) REFERENCES Enrollment(Enrollment_ID),
    FOREIGN KEY (Payment_ID) REFERENCES Payment(Payment_ID)
);

CREATE TABLE Course_User_Assessment (
    Course_ID INT,
    Assessment_ID INT,
    PRIMARY KEY (Course_ID, Assessment_ID),
    FOREIGN KEY (Course_ID) REFERENCES Courses(Course_ID),
    FOREIGN KEY (Assessment_ID) REFERENCES User_Assessment(Assessment_ID)
);


CREATE TABLE Learner_User_Assessment (
    Learner_ID INT,
    Assessment_ID INT,
    PRIMARY KEY (Learner_ID, Assessment_ID),
    FOREIGN KEY (Learner_ID) REFERENCES Learner(Learner_ID),
    FOREIGN KEY (Assessment_ID) REFERENCES User_Assessment(Assessment_ID)
);

CREATE TABLE Learner_Attendance (
    Learner_ID INT,
    Attendance_ID INT,
    PRIMARY KEY (Learner_ID, Attendance_ID),
    FOREIGN KEY (Learner_ID) REFERENCES Learner(Learner_ID),
    FOREIGN KEY (Attendance_ID) REFERENCES Attendance(Attendance_ID)
);

CREATE TABLE Course_Attendance (
    Course_ID INT,
    Attendance_ID INT,
    PRIMARY KEY (Course_ID, Attendance_ID),
    FOREIGN KEY (Course_ID) REFERENCES Courses(Course_ID),
    FOREIGN KEY (Attendance_ID) REFERENCES Attendance(Attendance_ID)
);


---------------------Other Relationships -----------------------------
ALTER TABLE Courses
ADD CONSTRAINT FK_Courses_Category
FOREIGN KEY (Category_ID) REFERENCES Course_Categories(Category_ID);

ALTER TABLE Content
ADD CONSTRAINT FK_Courses_Content
FOREIGN KEY (Course_ID) REFERENCES Courses(Course_ID);

ALTER TABLE Course_Materials
ADD CONSTRAINT FK_Courses_Materia
FOREIGN KEY (Course_Instructor_ID) REFERENCES Course_Instructor(Course_Instructor_ID);

ALTER TABLE Course_Materials
ADD CONSTRAINT FK_Course_Materials_Content 
FOREIGN KEY (Content_ID) REFERENCES Content(Content_ID);


ALTER TABLE Course_Assessments
ADD CONSTRAINT FK_Courses_Assessment
FOREIGN KEY (Course_Instructor_ID) REFERENCES Course_Instructor(Course_Instructor_ID);


ALTER TABLE Course_Announcement
ADD CONSTRAINT FK_Courses_Announcement
FOREIGN KEY (Course_Instructor_ID) REFERENCES Course_Instructor(Course_Instructor_ID);

ALTER TABLE Enrollment
ADD CONSTRAINT FK_Fee_Enrollment
FOREIGN KEY (Fee_ID) REFERENCES Fee(Fee_ID);

-- Create subtype of User_Assessment
ALTER TABLE User_Assignment
ADD CONSTRAINT FK_Assignment_Assessment
FOREIGN KEY (Assessment_ID) REFERENCES User_Assessment(Assessment_ID);

-- Create subtype of User_Assessment
ALTER TABLE User_Quiz_Answers
ADD CONSTRAINT FK_QA_Assessment
FOREIGN KEY (Assessment_ID) REFERENCES User_Assessment(Assessment_ID);


ALTER TABLE Result
ADD CONSTRAINT FK_Assessment_Result
FOREIGN KEY (Assessment_ID) REFERENCES User_Assessment(Assessment_ID);

ALTER TABLE Result
ADD CONSTRAINT FK_Instructor_Result
FOREIGN KEY (Instructor_ID) REFERENCES Instructor(Instructor_ID);

ALTER TABLE Course_Schedule
ADD CONSTRAINT FK_Schedule_Courses
FOREIGN KEY (Course_ID) REFERENCES Courses(Course_ID);

ALTER TABLE Certificates
ADD CONSTRAINT FK_Certificates_Result
FOREIGN KEY (Result_ID) REFERENCES Result(Result_ID);

ALTER TABLE Certificates
ADD CONSTRAINT FK_Enrollment_Result 
FOREIGN KEY (Enrollment_ID) REFERENCES Enrollment(Enrollment_ID);

ALTER TABLE Quiz_Questions
ADD CONSTRAINT FK_Quiz_Course
FOREIGN KEY (Course_ID) REFERENCES Courses(Course_ID);

ALTER TABLE User_Quiz_Answers
ADD CONSTRAINT FK_Quiz_QA
FOREIGN KEY (Quiz_ID, Question_ID) REFERENCES Quiz_Questions(Quiz_ID, Question_ID);


ALTER TABLE Course_Prerequisite
ADD CONSTRAINT FK_Pre_Course
FOREIGN KEY (Course_ID) REFERENCES Courses(Course_ID);
-----------------------------Checks ------------------------------------
-----------------only above 18 can register for course 
CREATE FUNCTION CalculateAge (@dob DATE)
RETURNS INT
AS
BEGIN
    DECLARE @age INT;
    SELECT @age = DATEDIFF(YEAR, @dob, GETDATE());
    RETURN @age;
END;
-----------------for only who completed course will provide certificate
CREATE FUNCTION Check_Result_Passing(@Result_ID INT) RETURNS INT
AS
BEGIN
    DECLARE @Passing INT;
    
    SELECT @Passing = CASE
        WHEN EXISTS (
            SELECT 1
            FROM Result r
            WHERE r.Result_ID = @Result_ID
              AND r.Score > 50
        ) THEN 1
        ELSE 0
    END;

    RETURN @Passing;
END;
-----------------------------------------------
ALTER TABLE Instructor
ADD CONSTRAINT CK_InstructorEmail CHECK (Email LIKE '%@%');

ALTER TABLE Instructor
ADD CONSTRAINT CK_InstructorExperience CHECK (Years_of_Experience >= 0);

ALTER TABLE Instructor
ADD CONSTRAINT CK_InstructorPostalCode CHECK (Postal_Code LIKE '% %');

ALTER TABLE Learner
ADD CONSTRAINT CK_LearnerEmail CHECK (Email LIKE '%@%');


ALTER TABLE Learner
ADD CONSTRAINT CK_LearnerPostalCode CHECK (Postal_Code LIKE '% %');


ALTER TABLE Learner
ADD CONSTRAINT CK_LearnerAge CHECK (dbo.CalculateAge(Date_of_Birth) > 18);

ALTER TABLE Courses
ADD CONSTRAINT CK_StartBeforeEnd CHECK (Start_Date < End_Date);

ALTER TABLE Courses
ADD CONSTRAINT CK_Duration CHECK (Duration >= 0 AND Duration <= 50);

ALTER TABLE Course_Materials
ADD CONSTRAINT CHK_LastUpdateAfterUpload CHECK (Last_Update >= Upload_Date);

ALTER TABLE Course_Assessments
ADD CONSTRAINT CK_ValidMaxScore CHECK (Max_Score > 0 AND Max_Score <= 100);

ALTER TABLE Course_Assessments
ADD CONSTRAINT CHK_Deadline CHECK (Deadline_StartTime < Deadline_EndTime);


ALTER TABLE Payment
ADD CONSTRAINT CK_ValidPaymentAmount CHECK (Payment_Amount > 0);

ALTER TABLE Enrollment_Payment
ADD CONSTRAINT UQ_Enrollment_Payment UNIQUE (Enrollment_ID);

ALTER TABLE User_Quiz_Answers
ADD CONSTRAINT CHK_Is_Correct CHECK (Is_Correct IN (0, 1));

ALTER TABLE User_Assessment
ADD CONSTRAINT CHK_User_Assessment_Type CHECK (Assessment_ID IN (SELECT Assessment_ID FROM User_Quiz_Answers) OR Assessment_ID IN (SELECT Assessment_ID FROM User_Assignment));

ALTER TABLE Result
ADD CONSTRAINT CHK_Score CHECK (Score >= 0 AND Score <= 100);

ALTER TABLE Result
ADD CONSTRAINT CHK_Status CHECK (Status IN ('Completed', 'Failed'));

ALTER TABLE Attendance
ADD CONSTRAINT CHK_Attendance_Status CHECK (Attendance_Status IN ('Present', 'Absent'));

-----------------------Insertion-------------------------------
INSERT INTO Instructor (Instructor_ID, First_Name, Last_Name, Date_of_Birth, Email, Contact_Number, Expertise_Area, Education_Background, Years_of_Experience, Address_Lines, Postal_Code, City)
VALUES
    (101, 'William', 'Taylor', '1982-06-15', 'william.taylor@example.com', '123-456-7890', 'Data Science', 'Ph.D. in Data Science', 10, '1 Park Lane', 'SW1A 1AA', 'London'),
    (102, 'Emma', 'Walker', '1989-09-22', 'emma.walker@example.com', '987-654-3210', 'Computer Programming', 'M.Sc. in Computer Science', 8, '15 Oxford Street', 'WC1A 1AA', 'London'),
    (103, 'James', 'Smith', '1975-12-10', 'james.smith@example.com', '555-555-5555', 'Big Data Analytics', 'M.Sc. in Computer Programming', 15, '25 High Street', 'EH1 1AA', 'Edinburgh'),
    (104, 'Olivia', 'Brown', '1993-03-28', 'olivia.brown@example.com', '777-888-9999', 'Database Management', 'M.S. in Data Science', 5, '10 Main Road', 'G1 1AA', 'Glasgow'),
    (105, 'Jack', 'Miller', '1988-07-19', 'jack.miller@example.com', '111-222-3333', 'Computer Science', 'Ph.D. in Computer Science', 12, '5 King Street', 'M1 1AA', 'Manchester'),
    (106, 'Sophia', 'Williams', '1983-01-02', 'sophia.williams@example.com', '444-444-4444', 'Database Management', 'B.A. in Marketing', 7, '8 Queen Avenue', 'B1 1AA', 'Birmingham'),
    (107, 'Thomas', 'Jones', '1978-09-08', 'thomas.jones@example.com', '888-777-6666', 'Big Data Analytics', 'Ph.D. Big Data Analytics', 20, '12 Market Square', 'LE1 1AA', 'Leicester'),
    (108, 'Isabella', 'Anderson', '1995-11-14', 'isabella.anderson@example.com', '666-555-4444', 'Computer Science', 'M.Sc. in Computer Science', 3, '7 Regent Road', 'EH3 1AA', 'Edinburgh'),
    (109, 'Samuel', 'Martin', '1982-06-30', 'samuel.martin@example.com', '222-333-4444', 'Database Management', 'B.Sc. in Computer Science', 9, '20 Bridge Street', 'BD1 1AA', 'Bradford'),
    (110, 'Emily', 'Harrison', '1975-04-17', 'emily.harrison@example.com', '999-888-7777', 'Database Management', 'Ph.D. Computer Science', 18, '30 Park Road', 'W1A 1AA', 'London');


INSERT INTO Learner (Learner_ID, First_Name, Last_Name, Date_of_Birth, Email, Contact_Number, Education_Level, Address_Lines, Postal_Code, City)
VALUES
    (201, 'Sophie', 'Clark', '1985-08-20', 'sophie.clark@example.com', '123-456-7890', 'Bachelor''s Degree', '10 Elm Street', 'SW1A 1AA', 'London'),
    (202, 'Oliver', 'Roberts', '1998-05-12', 'oliver.roberts@example.com', '987-654-3210', 'High School', '20 Oak Avenue', 'EH1 1AA', 'Edinburgh'),
    (203, 'Mia', 'Wilson', '1993-12-01', 'mia.wilson@example.com', '555-555-5555', 'Master''s Degree', '30 Maple Road', 'M1 1AA', 'Manchester'),
    (204, 'Noah', 'Harris', '2000-03-18', 'noah.harris@example.com', '777-888-9999', 'Doctorate', '40 Birch Lane', 'B1 1AA', 'Birmingham'),
    (205, 'Isabella', 'Hall', '1996-06-25', 'isabella.hall@example.com', '111-222-3333', 'High School', '50 Cedar Close', 'G1 1AA', 'Glasgow'),
    (206, 'James', 'Young', '1997-02-10', 'james.young@example.com', '444-444-4444', 'Bachelor''s Degree', '60 Oak Street', 'LE1 1AA', 'Leicester'),
    (207, 'Charlotte', 'Turner', '1999-09-08', 'charlotte.turner@example.com', '888-777-6666', 'High School', '70 Pine Drive', 'BD1 1AA', 'Bradford'),
    (208, 'William', 'King', '1994-11-14', 'william.king@example.com', '666-555-4444', 'Master''s Degree', '80 Elm Road', 'EH3 1AA', 'Edinburgh'),
    (209, 'Sophia', 'Walker', '1991-06-30', 'sophia.walker@example.com', '222-333-4444', 'High School', '90 Oak Lane', 'W1A 1AA', 'London'),
    (210, 'Liam', 'Scott', '1997-04-17', 'liam.scott@example.com', '999-888-7777', 'Bachelor''s Degree', '100 Maple Street', 'WC1A 1AA', 'London');


INSERT INTO Course_Type (Type_ID, Type_Name)----Backup table 
VALUES
    (301, 'Live Face-to-Face'),
    (302, 'Live Group'),
    (303, 'online Workshop');


-- Insert into Course_Categories
INSERT INTO Course_Categories (Category_ID, Category_Name, Description)
VALUES
    (1001, 'Computer Engineering', 'Courses related to computer engineering and technology'),
    (1002, 'Business', 'Courses related to entrepreneurship and business management'),
    (1003, 'Music', 'Courses related to music theory and instruments'),
    (1004, 'Art', 'Courses related to various forms of art'),
    (1005, 'Fitness', 'Courses related to health and fitness'),
    (1006, 'Languages', 'Courses related to learning foreign languages');

	-- Insert courses related to various subjects into Courses
INSERT INTO Courses (Course_ID, Title, Duration, Start_Date, End_Date, Category_ID)
VALUES
    (2001, 'Data Science Fundamentals', 30, '2022-09-01', '2022-09-30', 1001),
    (2002, 'Computer Programming', 30, '2022-10-01', '2022-10-30', 1001),
    (2003, 'Networking Fundamental', 35, '2022-09-15', '2022-10-20', 1001),
    (2004, 'Web Development Essentials', 45, '2022-11-01', '2022-12-15', 1001),
    (2005, 'Business Management Principles', 50, '2022-10-15', '2022-12-05', 1002),
    (2006, 'Digital Marketing Strategies', 40, '2022-11-15', '2022-12-20', 1002);

	-- Insert content entries related to the course "Introduction to Data Science"
INSERT INTO Content (Content_ID, Title, Description,Order_of_Title, Course_ID)
VALUES
    (3001, 'What is Data Science?', 'Understanding the definition and scope of data science.', 1, 2001),
    (3002, 'Introduction to Database', 'Understanding the fundamentals of database management systems.',2, 2001),
    (3003, 'Data Analysis Techniques', 'Exploring various techniques for analyzing and interpreting data.',3, 2001),
    (3004, 'Introduction to Big Data', 'Understanding the concepts and challenges of big data.', 4, 2001),
    (3005, 'Introduction to Data Mining', 'Exploring techniques for discovering patterns in large datasets.',5,  2001),
	(3006, 'Introduction to Programming Concepts', 'Understanding fundamental programming concepts and terminology.', 1, 2002),
    (3007, 'Intorduction to Data Structutre', 'Learn how to declare variables and work with different data types.', 2,  2002);

	
INSERT INTO Course_Materials (Course_Material_ID, Title, File_Category, File_Path, Order_of_Material, Course_Instructor_ID, Content_ID)
VALUES
    (5001, 'Introduction to Databases', 'Presentation', '\\\\server\\share\\intro_to_databases.pptx', 1, 4001, 3002),
    (5002, 'Relational Database Concepts', 'Tutorial', '\\\\server\\share\\relational_db_concepts.pdf', 2, 4001, 3002),
    (5003, 'SQL Fundamentals', 'Tutorial', '\\\\server\\share\\sql_fundamentals.pdf', 3, 4001, 3002),
    (5004, 'Database Design Principles', 'Documentation', '\\\\server\\share\\db_design_principles.docx', 4, 4001, 3002),
    (5005, 'Data Modeling Techniques', 'Presentation', '\\\\server\\share\\data_modeling_techniques.pptx', 5, 4001, 3002),
    (5006, 'Normalization Process', 'Tutorial', '\\\\server\\share\\normalization_process.pdf', 6, 4003, 3002),
    (5007, 'Indexing and Performance Optimization', 'Documentation', '\\\\server\\share\\indexing_performance_guide.docx', 7, 4003, 3002),
    (5008, 'Transaction Management', 'Presentation', '\\\\server\\share\\transaction_management.pptx', 8, 4001, 3002),
    (5009, 'Database Security Best Practices', 'Tutorial', '\\\\server\\share\\db_security_best_practices.pdf', 9, 4001, 3002);


INSERT INTO Course_Assessments (Assessment_ID, Title, Description, Deadline_StartTime, Deadline_EndTime, Order_of_Assessment, Max_Score, Creation_Date, Course_Instructor_ID)
VALUES
    -- Assessments for Course 'Data Science Fundamentals' (Course_ID: 2001)
    (6001, 'Quiz', ' Data Science Fundamentals-Test your understanding of the concepts of data science.', '2022-09-15 11:00:00','2022-09-15 12:00:00', 1, 100, '2022-09-01', 4003),
    (6002, 'Assignment', 'Data Science Fundamentals-A comprehensive assessment covering the first half of the course.', '2022-09-25 08:00:00','2022-09-25 15:00:00', 2, 100,'2022-09-01', 4001),
    -- Assessments for Course 'Computer Programming' (Course_ID: 2002)
    (6003, 'Quiz', 'Computer Programming-Test your understanding of fundamental programming concepts.', '2022-10-15 12:00:00', '2022-10-15 13:00:00',1, 100, '2022-10-01',4002),
    (6004, 'Assignment', 'Computer Programming-A comprehensive assessment covering all the programming concepts.', '2022-10-30 08:00:00 ','2022-10-30 03:00:00', 2, 100, '2022-10-01', 4002);


INSERT INTO Payment (Payment_ID, Date, Payment_Amount, Payment_Status)
VALUES
    (1, '2022-08-20', 4000.00, 'Paid'),
    (2, '2022-08-22', 4000.00, 'Paid'),
    (3, '2022-08-23', 4500.00, 'Paid'),
	(4, '2022-08-24', 3000.00, 'Paid'),
    (5, '2022-08-25', 3000.00, 'Paid'),
    (6, '2022-08-25', 2500.00, 'Paid');

	
INSERT INTO Quiz_Questions (Quiz_ID, Question_ID, Question_Text, Options, Correct_Answer, Course_ID)
VALUES
    (7001, 1, 'What does SQL stand for?', 'A. System Query Language, B. Structured Query Language, C. Simple Query Language, D. Standard Query Language', 'B', 2001),
    (7001, 2, 'Which SQL statement is used to insert new data into a database?', 'A. SELECT, B. UPDATE, C. INSERT, D. DELETE', 'C', 2001),
    (7001, 3, 'What does the SQL keyword "WHERE" do?', 'A. Sort the result set, B. Filter the result set based on a condition, C. Combine tables, D. Group rows', 'B', 2001),
    (7001, 4, 'Which SQL clause is used to retrieve only distinct (different) values?', 'A. SELECT, B. DISTINCT, C. UNIQUE, D. DIFF', 'B', 2001),
    (7002, 1, 'What is the output of the following Python code?\nprint("Hello, world!")', 'A. Hello, B. World!, C. Hello, world!, D. Nothing', 'C', 2002),
    (7002, 2, 'What data type is used to store a sequence of characters in Python?', 'A. Integer, B. Float, C. String, D. Boolean', 'C', 2002);


INSERT INTO User_Assessment (Assessment_ID, Date)
VALUES
    (8001, '2022-09-15'),
    (8002, '2022-09-15'),
	(9001, '2022-09-25'),
	(9002, '2022-09-25'),
	(9003, '2022-09-28'),
	(9004, '2022-09-27');

INSERT INTO User_Quiz_Answers (Assessment_ID, Answer_ID, Is_Correct, Quiz_ID, Question_ID)
VALUES
    (8001, 1, 0, 7001, 1),
    (8001, 3, 1, 7001, 2),
    (8001, 2, 1, 7001, 3),
    (8001, 2, 1, 7001, 4),
	(8002, 1, 0, 7001, 1),
    (8002, 3, 1, 7001, 2),
    (8002, 1, 0, 7001, 3),
    (8002, 2, 1, 7001, 4);

INSERT INTO User_Assignment (Assessment_ID, File_Name, File_Path)
VALUES
    (9001, 'assignment_submission_1.pdf', '\\\\server\\share\\assignment_submission_1.pdf'),
    (9002, 'assignment_submission_2.pdf',  '\\\\server\\share\\assignment_submission_2.pdf'),
    (9003, 'assignment_submission_3.pdf', '\\\\server\\share\\assignment_submission_3.pdf'),
	(9004, 'assignment_submission_4.pdf', '\\\\server\\share\\assignment_submission_4.pdf');

-- Insert data into Result
INSERT INTO Result (Result_ID, Score, Feedback, Status, Assessment_ID, Instructor_ID)
VALUES
    (601, 85.0, 'Good job, your answers were accurate and well-organized.', 'Completed', 8001, 103),
    (602, 95.0, 'Excellent work, you demonstrated a deep understanding of the material.', 'Completed', 8002, 103),
    (603, 55.0, 'You made some mistakes, but keep practicing to improve your skills.', 'Completed', 9001, 101),
    (604, 46.0, 'Not Good, Practice more', 'Failed', 9002, 101);

-- Insert data into Attendance
INSERT INTO Attendance (Attendance_ID, Date, Attendance_Status)
VALUES
    (1, '2023-09-01', 'Present'),
    (2, '2023-09-01', 'Absent'),
    (3, '2023-09-01', 'Present'),
    (4, '2023-09-01', 'Present'),
	(5, '2023-09-02', 'Present'),
    (6, '2023-09-02', 'Present'),
    (7, '2023-09-02', 'Absent'),
    (8, '2023-09-02', 'Absent');

-- Insert data into Course_Schedule
INSERT INTO Course_Schedule (Schedule_ID, Start_Date, End_Date, Start_Time, End_Time, Link, Course_ID)
VALUES
    (1, '2022-09-01', '2022-09-01', '09:00:00', '10:00:00', 'https://example.com/link1', 2001),
    (2, '2022-09-02', '2022-09-02', '09:00:00', '10:00:00', 'https://example.com/link2', 2001),
	(3, '2022-09-03', '2022-09-03', '09:00:00', '10:00:00', 'https://example.com/link1', 2001),
    (4, '2022-09-04', '2022-09-04', '09:00:00', '10:00:00', 'https://example.com/link2', 2001);

INSERT INTO Certificates (Certificate_ID, Issue_Date, Result_ID, Enrollment_ID)
VALUES
    (701, '2022-10-02', 601,401 ),
    (702, '2022-10-03', 602,402 ),
    (703, '2022-10-03', 603,404 );

INSERT INTO Course_Announcement (Announcement_ID, Title, Date, Description, Course_Instructor_ID)
VALUES
    (1, 'Office Hours Announcement', '2023-08-25', 'I will be holding virtual office hours tomorrow to address any questions or concerns you have about the course material.', 4001),
    (2, 'Group Project Teams', '2023-08-28', 'Group project teams have been assigned. Please check the group and your team members on the course website.', 4001),
    (3, 'Course Survey', '2023-08-31', 'We value your feedback! Please take a few minutes to complete the course survey to help us improve your learning experience.', 4003),
    (4, 'Final Exam Details', '2023-09-10', 'The final exam schedule and format have been posted. Please review the details on the course website.', 4003),
    (5, 'Guest Lecture on Machine Learning', '2023-09-12', 'We have a special guest lecture on machine learning scheduled for next week. Dont miss this opportunity!', 4003),
    (6, 'Course Completion Certificate', '2023-09-30', 'Congratulations on completing the course! Certificates will be issued upon successful completion of all assessments.', 4001),
    (7, 'Course Feedback Session', '2023-09-30', 'We want to hear your thoughts on the course. Join us for a feedback session to share your suggestions and ideas.', 4003);


INSERT INTO Course_Prerequisite (Prerequisite_ID, Course_Name, Prerequisite_Course_Name, Course_ID)
VALUES
    (801, 'Data Science Fundamentals','Statictics', 2001),
	(802, 'Computer Programming','Mathematic', 2002),
	(803, 'Networking Fundamental','Programming', 2003),
	(804, 'Web Development Essentials','Programming', 2004),
	(805, 'Business Management Principles','Communication', 2005),


---------------------------------------------- Insert data into Bridge tables 
INSERT INTO Course_Instructor (Course_Instructor_ID, Instructor_ID, Course_ID)
VALUES
    (4001, 101, 2001), 
    (4002, 102, 2002), 
    (4003, 103, 2001), 
    (4004, 104, 2001), 
    (4005, 105, 2002), 
    (4006, 106, 2001),
	(4007, 106, 2001),
	(4008, 104, 2002); 

INSERT INTO Learner_Materials (Learner_ID, Course_Material_ID)
VALUES
    (201, 5001), 
    (202, 5001), 
    (204, 5001), 
    (206, 5001), 
	(201, 5002), 
    (202, 5002), 
    (204, 5002), 
    (206, 5002); 

INSERT INTO Learner_Assignments (Learner_ID, Assignment_ID)
VALUES
    (201, 6001),
    (202, 6001), 
    (204, 6001), 
    (206, 6001), 
	(201, 6002),
    (202, 6002), 
    (204, 6002), 
    (206, 6002);

INSERT INTO Fee (Fee_ID, Amount, Course_ID, Type_ID)
VALUES
    (501, 4000.00, 2001, 301), 
    (502, 3000.00, 2001, 302),
    (503, 4500.00, 2002, 301),
	(504, 2500.00, 2002, 302); 


INSERT INTO Enrollment (Enrollment_ID, Completion_Status, Learner_ID, Course_ID, Fee_ID)
VALUES
    (401, 'Enrolled', 201, 2001,501), 
    (402, 'Enrolled', 202, 2001,501), 
    (403, 'Enrolled',  203, 2002, 503), 
    (404, 'Enrolled', 204, 2001, 502), 
    (405, 'Enrolled', 206, 2001, 502),
    (406, 'Enrolled', 206, 2002, 504); 
	
INSERT INTO Enrollment_Payment (Enrollment_ID, Payment_ID)
VALUES
    (401, 1),
    (402, 2),
    (403, 3),
	(404, 4),
    (405, 5),
    (406, 6);


INSERT INTO Course_User_Assessment (Course_ID, Assessment_ID)
VALUES
    (2001, 8001),
    (2001, 8002),
    (2001, 9001),
    (2001, 9002),
    (2001, 9003);

-- Insert data into Learner_User_Assessment
INSERT INTO Learner_User_Assessment (Learner_ID, Assessment_ID)
VALUES
    (201, 8001),
    (202, 8002),
    (204, 9001),
    (206, 9002);


	
-- Insert data into Learner_Attendance
INSERT INTO Learner_Attendance (Learner_ID, Attendance_ID)
VALUES
    (201, 1),
    (202, 2),
    (204, 3),
    (206, 4),
    (201, 5),
    (202, 6),
	(204, 7),
    (206, 8);

-- Insert data into Course_Attendance
INSERT INTO Course_Attendance (Course_ID, Attendance_ID)
VALUES
    (2001, 1),
    (2001, 2),
    (2001, 3),
    (2001, 4),
    (2001, 5),
    (2001, 6),
	(2001, 7),
    (2001, 8);
-------------------------------------------Optimization ---------------------------------
DECLARE @RowCount INT = 100;

-- Loop for the first date
DECLARE @Counter INT = 1;
DECLARE @Date1 DATE = '2022-08-20';

WHILE @Counter <= @RowCount / 3
BEGIN
    INSERT INTO Payment (Payment_ID, Date, Payment_Amount, Payment_Status)
    VALUES (@Counter, @Date1, 4000.00, 'Paid');
    
    SET @Counter = @Counter + 1;
END;

-- Loop for the second date
SET @Counter = 1;
DECLARE @Date2 DATE = '2022-08-22';

WHILE @Counter <= @RowCount / 3
BEGIN
    INSERT INTO Payment (Payment_ID, Date, Payment_Amount, Payment_Status)
    VALUES (@Counter + @RowCount / 3, @Date2, 4000.00, 'Paid');
    
    SET @Counter = @Counter + 1;
END;

-- Loop for the third date
SET @Counter = 1;
DECLARE @Date3 DATE = '2022-08-23';

WHILE @Counter <= @RowCount / 3
BEGIN
    INSERT INTO Payment (Payment_ID, Date, Payment_Amount, Payment_Status)
    VALUES (@Counter + 2 * @RowCount / 3, @Date3, 4500.00, 'Paid');
    
    SET @Counter = @Counter + 1;
END;


Drop INDEX IX_Payment_Date ON Payment;

SET STATISTICS TIME ON;

SELECT Date, SUM(Payment_Amount) AS Total_Payment
FROM Payment
GROUP BY Date
ORDER BY Date;

SET STATISTICS TIME OFF;

-----After Index Cretaion

CREATE   INDEX idx_Payment_Date ON Payment (Date);

SET STATISTICS TIME ON;

SELECT Date, SUM(Payment_Amount) AS Total_Payment
FROM Payment
GROUP BY Date
ORDER BY Date;

SET STATISTICS TIME OFF;
SELECT
 *
FROM sys.indexes
WHERE name like 'idx%'

----------------------------------------
DROP TABLE Payment;
DROP PARTITION FUNCTION PaymentDatePF;
DROP PARTITION SCHEME PaymentDatePS;



-- Create the partition function for quarters of August
CREATE PARTITION FUNCTION PaymentDatePF (DATE)  
AS RANGE RIGHT FOR VALUES 
    ('2022-08-01', '2022-08-08', '2022-08-15', '2022-08-22', '2022-09-01');

CREATE PARTITION SCHEME PaymentDatePS
AS PARTITION PaymentDatePF 
ALL TO ([PRIMARY]);



-- Create the table and associate it with the partition scheme
CREATE TABLE Payment (
    Payment_ID INT NOT NULL,
    Date DATE DEFAULT GETDATE() NOT NULL,
    Payment_Amount DECIMAL(15, 2)  DEFAULT 0 NOT NULL,
    Payment_Status VARCHAR(50) NOT NULL
)
ON PaymentDatePS(Date);


-- To select data from a specific partition using the PARTITION function
SELECT Payment_ID, Date, Payment_Amount, Payment_Status
FROM Payment
WHERE $PARTITION.PaymentDatePF(Date) = 3;


SELECT *
FROM sys.partition_schemes;

-- Query to get details of partitions within a partition scheme
SELECT ps.name AS PartitionScheme,
       pf.name AS PartitionFunction,
       prv.boundary_id AS PartitionNumber,
       prv.value AS BoundaryValue
FROM sys.partition_schemes ps
JOIN sys.partition_functions pf ON ps.function_id = pf.function_id
JOIN sys.partition_range_values prv ON pf.function_id = prv.function_id
ORDER BY ps.name, prv.boundary_id;

---------------------------------Selection ---------------------------------------------------------

SELECT e.Enrollment_ID, l.Learner_ID, CONCAT(l.First_Name, ' ', l.Last_Name) AS Learner_Name,
       c.Title AS Course_Title,cc.Category_Name AS Cours_Categry,
       l.Date_of_Birth, l.Email, l.Contact_Number,
       l.Education_Level, l.Postal_Code, l.City
FROM Enrollment e
JOIN Learner l ON e.Learner_ID = l.Learner_ID
JOIN Courses c ON e.Course_ID = c.Course_ID
JOIN Course_Categories cc ON c.Category_ID = cc.Category_ID
ORDER BY Enrollment_ID;



SELECT u.First_Name, u.Last_Name,
       SUM(CASE WHEN r.Status = 'Completed' THEN 1 ELSE 0 END) AS Completed_Assessments,
       SUM(CASE WHEN r.Status = 'Failed' THEN 1 ELSE 0 END) AS Failed_Assessments
FROM Learner_User_Assessment ua
JOIN Learner u ON ua.Learner_ID = u.Learner_ID
JOIN Result r ON ua.Assessment_ID = r.Assessment_ID
GROUP BY u.First_Name, u.Last_Name;


SELECT
    c.Course_ID,
    c.Title AS Course_Title, a.Date,
    COUNT(CASE WHEN a.Attendance_Status = 'Present' THEN 1 ELSE NULL END) AS Present_Count,
    COUNT(CASE WHEN a.Attendance_Status = 'Absent' THEN 1 ELSE NULL END) AS Absent_Count
FROM Courses c
JOIN Course_Attendance ca ON c.Course_ID = ca.Course_ID
JOIN Attendance a ON ca.Attendance_ID = a.Attendance_ID
WHERE c.Course_ID = 2001
GROUP BY c.Course_ID, c.Title , a.Date;


SELECT
    l.Learner_ID,CONCAT(l.First_Name, ' ', l.Last_Name) AS Learner_Name,
    r.Score AS Quiz_Score,
    CASE
        WHEN R.Score > 49 THEN  'Certificate Applicable'
        ELSE 'Not Applicable'
    END AS Certificate_Status,
c.Issue_Date AS Certificate_Issue_Date
FROM Learner l
JOIN Learner_User_Assessment ua ON l.Learner_ID = ua.Learner_ID
JOIN Result r ON ua.Assessment_ID = r.Assessment_ID
LEFT JOIN Certificates c ON r.Result_ID = c.Result_ID;

SELECT
    i.Instructor_ID,
    CONCAT(i.First_Name, ' ', i.Last_Name) AS Instructor_Name,
    c.Course_ID,
    c.Title AS Course_Title,
	ca.Title AS Assessment_Type
FROM Course_Instructor ci
JOIN Instructor i ON ci.Instructor_ID = i.Instructor_ID
JOIN Courses c ON ci.Course_ID = c.Course_ID
JOIN Course_Assessments ca ON ci.Course_Instructor_ID = ca.Course_Instructor_ID


