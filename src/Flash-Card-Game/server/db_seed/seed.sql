DROP ROLE IF EXISTS flashcard_dev;

CREATE ROLE flashcard_dev LOGIN PASSWORD 'flashcard_password';

ALTER ROLE flashcard_dev WITH SUPERUSER;

DROP DATABASE flashcard_db;

CREATE DATABASE flashcard_db;

\c flashcard_db;

CREATE TABLE Users (
    id SERIAL PRIMARY KEY, 
    name VARCHAR(255) NOT NULL,
    email VARCHAR(255) NOT NULL,
    password VARCHAR(255) NOT NULL,
    stars INTEGER DEFAULT 0,
    gems INTEGER DEFAULT 0,
    createdAt timestamp,
    updatedAt timestamp,
    lastsignedIn timestamp,
    firstTimeGems boolean
);

INSERT INTO
    Users (name, email, password, stars, lastSignedIn, firsttimegems)
VALUES
    ('Alice','alice@gmail.com', '123123', 10, NOW(), FALSE),
    ('Bob','bob@gmail.com', '456456', 5, NOW(), FALSE),
    ('Carol','carol@gmail.com', 'asdasd', 4, NOW(), FALSE),
    ('Dan','dan@gmail.com', 'password123', 2, NOW(), FALSE),
    ('Edgar','edgar@gmail.com', 'password456', 1, NOW(), FALSE),
    ('Frodo','frodo@gmail.com', 'password789', 5, NOW(), FALSE),
    ('Gandalf','gandalf@gmail.com', 'greywizard', 0, NOW(), FALSE),
    ('Horace','horace@gmail.com', 'mypwd', 2, NOW(), FALSE),
    ('Iris','iris@gmail.com', 'iris', 1, NOW(), FALSE),
    ('Jon','jon@gmail.com', '1221', 1, NOW(), FALSE);

CREATE TABLE Cards (
    id SERIAL PRIMARY KEY,
    front VARCHAR(255),
    back VARCHAR(255),
    cardset VARCHAR(255),
    image_url VARCHAR(255),
    createdAt timestamp,
    updatedAt timestamp
);

INSERT INTO
    Cards (front, back, cardset)
VALUES
    ('What does SQL stand for?', 'Structured Query Language', 'SQL'),
    ('Which SQL statement is used to extract data from a database?', 'SELECT', 'SQL'),
    ('With SQL, how do you select a column named "FirstName" from a table named "Persons"?', 'SELECT FirstName FROM Persons', 'SQL'),
    ('The OR operator displays a record if ANY conditions listed are true. The AND operator displays a record if ALL of the conditions listed are true', 'True', 'SQL'),
    ('Which SQL statement is used to return only different values?', 'SELECT DISTINCT', 'SQL'),
    ('Which SQL keyword is used to sort the result-set?', 'ORDER BY', 'SQL'),
    ('What is the most common type of join?', 'INNER JOIN', 'SQL'),
    ('What is the command for adding columns to a table?', 'ALTER TABLE', 'SQL'),
    ('What does RDBMS stand for?', 'It stands for Relational Database Management System', 'SQL'),
    ('What is the keyword to sort data in ascending order?', 'ASC keyword', 'SQL'),
    ('What is ECMAScript', 'It is a Standard for a scripting languages. It provides the specifications for languages like Javascript and Jscript.',  'JavaScript'),
    ('What is Just-In-Time compilation', 'It means the code is converted to machine code all at once and then executed immediately such that there is no portable file like in Java.',  'JavaScript'),
    ('What are JavaScript primitive data types', 'A primitive data type is data that isnt an object and has no methods. i.e. Number Null Undefined Boolean BigInt String Symbol',  'JavaScript'),
    ('What is dynamic typing', 'Dynamic typing means that you dont need to specify what type the variable is, in contrast to a statically typed language.',  'JavaScript'),
    ('What is immutability?', 'It means something cannot change once it is created.',  'JavaScript'),
    ('Jumps out of a loop and start at the top', 'continue',  'JavaScript'),
    ('Terminates a switch or a loop', 'break', 'JavaScript'),
    ('What is the difference between Set and array', 'Set can only contain unique values of any type; array is a 0 indexed list of values, which can be accessed by their index.', 'JavaScript'),
    ('What are 3 ways to declare a function in JavaScript', '1. Function declaration 2. Function expression 3. Arrow Function (ES6)', 'JavaScript'),
    ('Executes a block of statements, and repeats the block, while a condition is true', 'do ... while', 'JavaScript'),
    ('What is the capital of California?', 'Sacramento', 'US State Capitals'),
    ('What is the capital of New York?', 'New York City', 'US State Capitals'),
    ('What is the capital of New Jersey?', 'Trenton', 'US State Capitals'),
    ('What is the capital of Pennsylvania?', 'Philadelphia', 'US State Capitals'),
    ('What is the capital of Alaska?', 'Juneau', 'US State Capitals'),
    ('What is the capital of Nebraska?', 'Lincoln', 'US State Capitals'),
    ('What is the capital of Ohio?', 'Columbus', 'US State Capitals'),
    ('What is the capital of Oregon?', 'Salem', 'US State Capitals'),
    ('What is the capital of Washington state?', 'Olympia', 'US State Capitals'),
    ('What is a correct syntax to output "Hello World" in Python?', 'print("Hello World")', 'Python'),
    ('How do you insert COMMENTS in Python code?', '#This is a comment', 'Python'),
    ('What is the correct file extension for Python files?', '.py', 'Python'),
    ('What is the correct syntax to output the type of a variable or object in Python?', 'print(type(x))', 'Python'),
    ('What is the correct way to create a function in Python?', 'def myFunction():', 'Python'),
    ('What is a correct syntax to return the first character in a string?', 'x = "Hello"[0]', 'Python'),
    ('Which method can be used to remove any whitespace from both the beginning and the end of a string?', 'strip()', 'Python'),
    ('Which method can be used to return a string in upper case letters?', 'upper()', 'Python'),
    ('What is a Tuple in Python?', 'Tuples are used to store multiple items in a single variable. e.g. mytuple = ("apple", "banana", "cherry")', 'Python'),
    ('Which collection is ordered, changeable, and allows duplicate members?', 'List', 'Python');

INSERT INTO
    Cards (front, back, cardset, image_url)
VALUES
    ('What is the capital of Utah?', 'Salt Lake City', 'US State Capitals', 'https://upload.wikimedia.org/wikipedia/commons/thumb/4/46/Salt_Lake_City_montage_19_July_2011.jpg/800px-Salt_Lake_City_montage_19_July_2011.jpg'),
    ('What is the capital of Texas?', 'Austin', 'US State Capitals', 'https://upload.wikimedia.org/wikipedia/commons/thumb/d/da/Austin_August_2019_19_%28skyline_and_Lady_Bird_Lake%29.jpg/1280px-Austin_August_2019_19_%28skyline_and_Lady_Bird_Lake%29.jpg'),
    ('What is the capital of Hawaii?', 'Honolulu', 'US State Capitals', 'https://upload.wikimedia.org/wikipedia/commons/thumb/6/64/Downtown_Honolulu_from_P%C5%ABowaina_%28Punchbowl_Crater%29.jpg/1280px-Downtown_Honolulu_from_P%C5%ABowaina_%28Punchbowl_Crater%29.jpg');