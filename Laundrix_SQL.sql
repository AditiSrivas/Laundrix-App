DROP DATABASE IF EXISTS laundramat2;
CREATE DATABASE laundramat2;
USE laundramat2;

CREATE TABLE registration (
    id INT AUTO_INCREMENT PRIMARY KEY,
    username VARCHAR(50) UNIQUE NOT NULL,
    password VARCHAR(50),
    email VARCHAR(100) UNIQUE NOT NULL
);

CREATE TABLE user(
    UserID int PRIMARY KEY AUTO_INCREMENT,
    Username varchar(50) UNIQUE NOT NULL,
    Password varchar(50) NOT NULL,
    Email varchar(100) UNIQUE NOT NULL,
    UserType ENUM ("Customer", "LaundryWorker") NOT NULL,
    FOREIGN KEY(username) REFerences registration(username),
    FOREIGN KEY(Email) REFerences registration(email)
    
);

CREATE TABLE vendor(
    VendorID int PRIMARY KEY AUTO_INCREMENT,
    Name varchar(100) UNIQUE NOT NULL,
    Location varchar(255) NOT NULL,
    Email varchar(100) UNIQUE NOT NULL,
    Logo varchar(255),
    FOREIGN KEY (Email) REFERENCES registration(email)
);

CREATE TABLE profile(
    ProfileID int PRIMARY KEY AUTO_INCREMENT,
    VendorID int UNIQUE,
    Prices decimal(10,2),
    Offers TEXT,
    Descriptions TEXT,
    Ratings decimal(3,2),
    FOREIGN KEY (VendorID) REFERENCES vendor(VendorID)
);

CREATE TABLE customer(
    CustomerID int PRIMARY KEY AUTO_INCREMENT,
    Name varchar(100) NOT NULL,
    Email varchar(100) UNIQUE NOT NULL,
    Age int
);

CREATE TABLE payments(
    PaymentID int PRIMARY KEY AUTO_INCREMENT,
    Amount decimal(10,2) NOT NULL,
    Date date NOT NULL,
    CustomerID int,
    FOREIGN KEY (CustomerID) REFERENCES Customer(CustomerID)
);

CREATE TABLE orders(
    OrderID int PRIMARY KEY AUTO_INCREMENT,
    Amount decimal(10,2) NOT NULL,
    Type varchar(50),
    CustomerID int,
    FOREIGN KEY (CustomerID) REFERENCES Customer(CustomerID)
);

CREATE TABLE feedback(
    FeedbackID int PRIMARY KEY AUTO_INCREMENT,
    OrderID int,
    Rating int NOT NULL,
    Review TEXT,
    FOREIGN KEY (OrderID) REFERENCES orders(OrderID)
);

CREATE TABLE services(
    ServiceID int PRIMARY KEY AUTO_INCREMENT,
    VendorID int,
    Amount decimal(10,2) NOT NULL,
    Type varchar(50),
    FOREIGN KEY (VendorID) REFERENCES vendor(VendorID)
);

CREATE TABLE service_type(
    ServiceTypeID int PRIMARY KEY,
    TypeName varchar(50)  NOT NULL
);

CREATE TABLE location(
    LocationID int PRIMARY KEY,
    LocationName varchar(100) UNIQUE NOT NULL
);

CREATE TABLE order_item(
    OrderItemID int PRIMARY KEY auto_increment,
    OrderID int,
    ItemName varchar(100) NOT NULL,
    Quantity int NOT NULL,
    FOREIGN KEY (OrderID) REFERENCES orders(OrderID)
);

CREATE TABLE payment_status(
    PaymentStatusID int PRIMARY KEY,
    StatusName varchar(50)  NOT NULL
);

CREATE TABLE notification(
    NotificationID int PRIMARY KEY auto_increment,
    UserID int,
    Message TEXT NOT NULL,
    SentDateTime DATETIME NOT NULL,
    FOREIGN KEY (UserID) REFERENCES user(UserID)
);

CREATE TABLE discount(
    DiscountID INT PRIMARY KEY auto_increment,
    DiscountCode VARCHAR(20) UNIQUE NOT NULL,
    Percentage DECIMAL(5, 2) NOT NULL,
    ValidFrom DATE NOT NULL,
    ValidTo DATE NOT NULL
);
-- Step 1: Create a table to store failed login attempts
CREATE TABLE login_attempts (
    UserID INT,
    AttemptDateTime DATETIME,
    FOREIGN KEY (UserID) REFERENCES user(UserID)
);

-- Step 2: Create a trigger to block the user after three failed login attempts
DELIMITER //
CREATE TRIGGER block_user_after_three_failures
AFTER INSERT ON notification
FOR EACH ROW
BEGIN
    DECLARE attempt_count INT;
    
    -- Count the number of failed login attempts for the user
    SELECT COUNT(*) INTO attempt_count
    FROM login_attempts
    WHERE UserID = NEW.UserID
    AND AttemptDateTime >= NOW() - INTERVAL 1 DAY;
    
    -- If there are three or more failed attempts, block the user
    IF attempt_count >= 3 THEN
        UPDATE user
        SET UserType = 'Blocked'
        WHERE UserID = NEW.UserID;
        
    END IF;
END//
DELIMITER ;
DELIMITER //

CREATE TRIGGER check_service_inventory_level
AFTER INSERT ON orders
FOR EACH ROW
BEGIN
    DECLARE service_count INT;
    
    -- Get the current count of orders for the ordered service
    SELECT COUNT(*) INTO service_count
    FROM services
    WHERE Type = NEW.Type;
    

    IF service_count <= 5 THEN

        INSERT INTO notification (UserID, Message, SentDateTime) VALUES (1, CONCAT('Low inventory for service: ', NEW.Type), NOW());
    END IF;
END//

DELIMITER ;


-- new 
USE laundramat2;

-- Add values to the 'registration' table
INSERT INTO registration (username, password, email) VALUES
('siri_bot', 'siri123', 'ram@gmail.com'),
('alexa_bot', 'alexa456', 'shyam@gmail.com'),
('cortana_bot', 'cortana789', 'lata@gmail.com'),
('watson_bot', 'watson321', 'mohan@gmail.com'),
('assistant_bot', 'assistant654', 'rohan@gmail.com');

-- Add values to the 'user' table
-- Add values to the 'user' table
INSERT INTO user (Username, Password, Email, UserType) VALUES
('siri_bot', 'siri123', 'ram@gmail.com', 'Customer'),
('alexa_bot', 'alexa456', 'shyam@gmail.com', 'LaundryWorker'),
('cortana_bot', 'cortana789', 'lata@gmail.com', 'Customer'),
('watson_bot', 'watson321', 'mohan@gmail.com', 'LaundryWorker'),
('assistant_bot', 'assistant654', 'rohan@gmail.com', 'Customer');


-- Add values to the 'vendor' table
INSERT INTO vendor (Name, Location, Email, Logo) VALUES
('Saree Cleaners', 'Mumbai', 'ram@gmail.com', 'saree_cleaners_logo.png'),
('Shirt & Tie Laundry', 'Delhi', 'shyam@gmail.com', 'shirt_tie_logo.png'),
('Laundry Mart', 'Bangalore', 'lata@gmail.com', 'laundry_mart_logo.png'),
('Fresh n Fold', 'Chennai', 'mohan@gmail.com', 'fresh_n_fold_logo.png'),
('Spotless Cleaners', 'Kolkata', 'rohan@gmail.com', 'spotless_cleaners_logo.png');

-- Add values to the 'profile' table
INSERT INTO profile (VendorID, Prices, Offers, Descriptions, Ratings) VALUES
(1, 10.00, 'Free pickup', 'Best saree cleaning service in Mumbai', 4.5),
(2, 15.00, 'Express service', 'Quick shirt and tie laundry in Delhi', 4.0),
(3, 12.00, 'Discount on first order', 'Top-notch laundry services in Bangalore', 4.2),
(4, 20.00, 'Special care for delicate fabrics', 'Professional laundry services in Chennai', 4.7),
(5, 18.00, 'Same-day service', 'Expert laundry solutions in Kolkata', 4.3);

-- Add values to the 'customer' table
INSERT INTO customer (Name, Email, Age) VALUES
('Shreya', 'shreya@gmail.com', 30),
('Anushka', 'anushka@gmail.com', 25),
('Rohit', 'rohit@gmail.com', 35),
('Rohan', 'rohan@gmail.com', 40),
('Ramesh', 'ramesh@gmail.com', 28);

-- Add values to the 'payments' table
INSERT INTO payments (Amount, Date, CustomerID) VALUES
(20.00, '2024-03-31', 1),
(15.00, '2024-03-30', 2),
(25.00, '2024-03-29', 3),
(30.00, '2024-03-28', 4),
(18.00, '2024-03-27', 5);

-- Add values to the 'orders' table
INSERT INTO orders (Amount, Type, CustomerID) VALUES
(25.00, 'Dry Cleaning', 1),
(30.00, 'Wash & Fold', 2),
(20.00, 'Ironing', 3),
(18.00, 'Dry Cleaning', 4),
(15.00, 'Wash & Iron', 5);

-- Add values to the 'feedback' table
INSERT INTO feedback (OrderID, Rating, Review) VALUES
(1, 4, 'Great service, my sarees look amazing!'),
(2, 3, 'Decent job, but could improve on folding'),
(3, 5, 'Absolutely satisfied with the quality and speed'),
(4, 4, 'Good attention to delicate fabrics, happy with the service'),
(5, 4, 'Efficient and reliable, will use again');

-- Add values to the 'services' table
INSERT INTO services (VendorID, Amount, Type) VALUES
(1, 12.00, 'Saree Cleaning'),
(2, 15.00, 'Shirt Laundry'),
(3, 10.00, 'Wash & Fold'),
(4, 20.00, 'Dry Cleaning'),
(5, 18.00, 'Ironing');

-- Add values to the 'service_type' table
INSERT INTO service_type (ServiceTypeID, TypeName) VALUES
(1, 'Dry Cleaning'),
(2, 'Wash & Fold'),
(3, 'Shirt Laundry'),
(4, 'Saree Cleaning'),
(5, 'Ironing');

-- Add values to the 'location' table
INSERT INTO location (LocationID, LocationName) VALUES
(1, 'Mumbai'),
(2, 'Delhi'),
(3, 'Bangalore'),
(4, 'Chennai'),
(5, 'Kolkata');

-- Add values to the 'order_item' table
INSERT INTO order_item (OrderID, ItemName, Quantity) VALUES
(1, 'Silk Saree', 2),
(2, 'Cotton Shirt', 3),
(3, 'Bed Sheets', 1),
(4, 'Woolen Sweater', 1),
(5, 'Pants', 2);

-- Add values to the 'payment_status' table
INSERT INTO payment_status (PaymentStatusID, StatusName) VALUES
(1, 'Pending'),
(2, 'Completed'),
(3, 'Failed'),
(4, 'Refunded'),
(5, 'Cancelled');

-- Add values to the 'notification' table
INSERT INTO notification (UserID, Message, SentDateTime) VALUES
(1, 'Your order is ready for pickup', NOW()),
(2, 'New laundry request received', NOW()),
(3, 'Payment received for order #1234', NOW()),
(4, 'Your laundry will be delivered tomorrow', NOW()),
(5, 'Reminder: Your laundry pickup is scheduled for today', NOW());

-- Add values to the 'discount' table
INSERT INTO discount (DiscountID, DiscountCode, Percentage, ValidFrom, ValidTo) VALUES
(1, 'FIRSTORDER', 10.00, '2024-01-01', '2024-12-31'),
(2, 'FREESHIP', 5.00, '2024-03-01', '2024-03-31'),
(3, 'SALE20', 20.00, '2024-04-01', '2024-04-30'),
(4, 'LOYALTY', 15.00, '2024-01-01', '2024-12-31'),
(5, 'SPRING15', 15.00, '2024-03-01', '2024-03-31');