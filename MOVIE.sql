-- Movie ticket booking system

CREATE DATABASE MovieTicketBooking

CREATE TABLE Users (
    user_id INT PRIMARY KEY IDENTITY(1,1),
    name VARCHAR(100),
    email VARCHAR(100) UNIQUE,
    password_hash VARCHAR(255)
);

CREATE TABLE Movies (
    movie_id INT PRIMARY KEY IDENTITY(1,1),
    title VARCHAR(255),
    duration INT,  -- in minutes
    release_date DATE
);

CREATE TABLE Theaters (
    theater_id INT PRIMARY KEY IDENTITY(1,1),
    name VARCHAR(100),
    location VARCHAR(255)
);

CREATE TABLE Shows (
    show_id INT PRIMARY KEY IDENTITY(1,1),
    movie_id INT,
    theater_id INT,
    show_time DATETIME,
    available_seats INT,
    FOREIGN KEY (movie_id) REFERENCES Movies(movie_id),
    FOREIGN KEY (theater_id) REFERENCES Theaters(theater_id)
);

CREATE TABLE Bookings (
    booking_id INT PRIMARY KEY IDENTITY(1,1),
    user_id INT,
    show_id INT,
    seats_booked INT,
    booking_date DATETIME DEFAULT GETDATE(),
    FOREIGN KEY (user_id) REFERENCES Users(user_id),
    FOREIGN KEY (show_id) REFERENCES Shows(show_id)
);

CREATE TABLE Payments (
    payment_id INT PRIMARY KEY IDENTITY(1,1),
    booking_id INT,
    amount DECIMAL(10, 2),
    payment_status VARCHAR(50),
    payment_date DATETIME DEFAULT GETDATE(),
    FOREIGN KEY (booking_id) REFERENCES Bookings(booking_id)
);


-- Insert sample data into Users table
INSERT INTO Users (name, email, password_hash)
VALUES 
('Bunty Bajaj', 'bunty@example.com', 'hashed_password_101'),
('Gabbar Singh', 'gabbar@example.com', 'hashed_password_303'),
('Munna Tripathi', 'munna@example.com', 'hashed_password_404'),
('Chintu Verma', 'chintu@example.com', 'hashed_password_606'),
('Golu Gupta', 'golu@example.com', 'hashed_password_707'),
('Bittoo Malhotra', 'bittoo@example.com', 'hashed_password_808'),
('Tinku Yadav', 'tinku@example.com', 'hashed_password_909'),
('Bhaijaan Khan', 'bhaijaan@example.com', 'hashed_password_111'),
('Popat Lal', 'popat@example.com', 'hashed_password_222'),
('Bholu Joshi', 'bholu@example.com', 'hashed_password_777')


-- Insert sample data into Movies table
INSERT INTO Movies (title, duration, release_date)
VALUES 
('Inception', 148, '2010-07-16'),
('The Matrix', 136, '1999-03-31'),
('Interstellar', 169, '2014-11-07'),
('Avatar', 162, '2009-12-18'),
('Titanic', 195, '1997-12-19'),
('The Dark Knight', 152, '2008-07-18'),
('Gladiator', 155, '2000-05-05'),
('The Godfather', 175, '1972-03-24'),
('Forrest Gump', 142, '1994-07-06'),
('Shawshank Redemption', 142, '1994-09-23')

-- Insert sample data into Theaters table
INSERT INTO Theaters (name, location)
VALUES 
('Grand Cinema', '123 Main St'),
('Regal Theater', '456 Elm St'),
('Cineplex 10', '789 Pine St'),
('Downtown Movies', '101 Oak St'),
('Skyline Theater', '202 Maple St'),
('Sunset Cinemas', '303 Birch St'),
('Starlight Theater', '404 Cedar St'),
('Palace Multiplex', '505 Walnut St'),
('Galaxy Cinema', '606 Spruce St'),
('Silver Screen', '707 Ash St')

-- Insert sample data into Shows table
INSERT INTO Shows (movie_id, theater_id, show_time, available_seats)
VALUES 
(1, 1, '2025-03-01 19:00:00', 100),
(2, 2, '2025-03-02 20:00:00', 120),
(3, 3, '2025-03-03 18:30:00', 80),
(4, 4, '2025-03-04 21:00:00', 150),
(5, 5, '2025-03-05 17:00:00', 90),
(6, 6, '2025-03-06 19:30:00', 110),
(7, 7, '2025-03-07 20:45:00', 95),
(8, 8, '2025-03-08 16:00:00', 75),
(9, 9, '2025-03-09 18:00:00', 130),
(10, 10, '2025-03-10 19:15:00', 85)

-- Insert sample data into Bookings table
INSERT INTO Bookings (user_id, show_id, seats_booked)
VALUES 
(1, 1, 2),
(2, 2, 4),
(3, 3, 1),
(4, 4, 3),
(5, 5, 5),
(6, 6, 2),
(7, 7, 6),
(8, 8, 3),
(9, 9, 4),
(10, 10, 2)



SELECT * FROM Users

SELECT title, release_date FROM Movies

SELECT name, location FROM Theaters

-- Update seat availability after booking
UPDATE Shows
SET available_seats = available_seats - 2
WHERE show_id = 1

-- Delete a booking
DELETE FROM Bookings
WHERE booking_id = 2

-- Inner Join: Get booking details
SELECT U.name, M.title, T.name AS theater_name, S.show_time, B.seats_booked
FROM Bookings B
INNER JOIN Users U ON B.user_id = U.user_id
INNER JOIN Shows S ON B.show_id = S.show_id
INNER JOIN Movies M ON S.movie_id = M.movie_id
INNER JOIN Theaters T ON S.theater_id = T.theater_id

-- Left Join: List all shows with or without bookings
SELECT M.title, T.name AS theater_name, S.show_time, B.booking_id, B.seats_booked
FROM Shows S
LEFT JOIN Bookings B ON S.show_id = B.show_id
INNER JOIN Movies M ON S.movie_id = M.movie_id
INNER JOIN Theaters T ON S.theater_id = T.theater_id

-- Complex Query: Total seats booked per movie
SELECT M.title, SUM(B.seats_booked) AS total_seats_booked
FROM Movies M
INNER JOIN Shows S ON M.movie_id = S.movie_id
INNER JOIN Bookings B ON S.show_id = B.show_id
GROUP BY M.title

-- Complex Query: Available seats for a specific show
SELECT M.title, S.show_time, S.available_seats
FROM Shows S
INNER JOIN Movies M ON S.movie_id = M.movie_id
WHERE S.show_id = 2


--#############################################################################################

-- Procedure: Book a Ticket
ALTER PROCEDURE BookTicket
    @user_id INT,
    @show_id INT,
    @seats_booked INT
AS
BEGIN
    SET NOCOUNT ON;
    
    DECLARE @available_seats INT;
    SELECT @available_seats = available_seats FROM Shows WHERE show_id = @show_id;
    
    IF @available_seats >= @seats_booked
    BEGIN
        INSERT INTO Bookings (user_id, show_id, seats_booked)
        VALUES (@user_id, @show_id, @seats_booked);
        
        UPDATE Shows 
        SET available_seats = available_seats - @seats_booked
        WHERE show_id = @show_id;
        
        PRINT 'Booking successful..!';
    END
    ELSE
    BEGIN
        PRINT 'Not enough seats available..!';
    END
END

EXEC BookTicket @user_id = 3, @show_id = 2, @seats_booked = 10


-- Procedure: Retrieve User Bookings
CREATE PROCEDURE GetUserBookings
    @user_id INT
AS
BEGIN
    SET NOCOUNT ON
    
    SELECT B.booking_id, M.title, S.show_time, T.name AS theater_name, B.seats_booked
    FROM Bookings B
    JOIN Shows S ON B.show_id = S.show_id
    JOIN Movies M ON S.movie_id = M.movie_id
    JOIN Theaters T ON S.theater_id = T.theater_id
    WHERE B.user_id = @user_id
END

EXEC GetUserBookings @user_id = 3


-- Procedure: Process Payment
CREATE PROCEDURE ProcessPayment
    @booking_id INT,
    @amount DECIMAL(10, 2),
    @payment_status VARCHAR(50)
AS
BEGIN
    SET NOCOUNT ON
    
    INSERT INTO Payments (booking_id, amount, payment_status)
    VALUES (@booking_id, @amount, @payment_status)
    
    PRINT 'Payment processed successfully!';
END

EXEC ProcessPayment @booking_id = 1, @amount = 15.99, @payment_status = 'Completed';


