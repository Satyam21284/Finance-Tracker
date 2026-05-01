-- Clear existing data to ensure a clean slate
set FOREIGN_KEY_CHECKS = 0;
truncate table audit_log;
truncate table budgets;
truncate table transactions;
truncate table merchants;
truncate table categories;
truncate table accounts;
truncate table users;
set FOREIGN_KEY_CHECKS = 1;

-- =============================================
-- Create Users
-- =============================================
-- Note: Passwords are Pre-Hashed using bcrypt Library in Python.
-- Regular User: Shailya, Password: SH@il77723
-- Admin User: Admin User, Password: @dminp@ss

insert into users (id, username, email, password_hash, role)
values (1, 'Shailya', 'shailya.gandhi100@gmail.com', '$2b$12$NsY/d9ZOKoWpml.0yh8f2OLtgJQsR31veaukAqMyYrt3jpy7cI0ra', 'user'),
		(2, 'Administrator', 'admin.user@example.com', '$2b$12$GTtsjkX40K12h3uE8u2Voe2qntObEnEA4kH7i6Y0jFf80Mhud4JLe', 'admin');


-- SEED DATA FOR EXPENSE TRACKER (User: Shailya, id=1)
-- ========================
-- ACCOUNTS
-- ========================
INSERT INTO accounts (user_id, name, account_type, balance) VALUES
(1, 'Cash in Hand', 'CashAccount', 5000),
(1, 'SBI Savings Account', 'BankAccount', 450000),
(1, 'ICICI Salary Account', 'BankAccount', 75000),
(1, 'HDFC Credit Card', 'CreditCardAccount', -5000),
(1, 'Paytm Wallet', 'CashAccount', 2000);

-- ========================
-- CATEGORIES
-- ========================
-- Parent categories
INSERT INTO categories (user_id, name, type) VALUES
(1, 'Food & Groceries', 'expense'),
(1, 'Transport', 'expense'),
(1, 'Entertainment', 'expense'),
(1, 'Utilities', 'expense'),
(1, 'Healthcare', 'expense'),
(1, 'Shopping', 'expense'),
(1, 'Salary', 'income'),
(1, 'Investments', 'income'),
(1, 'Miscellaneous', 'expense'),
(1, 'Rent', 'expense');

-- Child categories
INSERT INTO categories (user_id, name, type, parent_id) VALUES
(1, 'Groceries', 'expense', 1),
(1, 'Restaurants', 'expense', 1),
(1, 'Cabs', 'expense', 2),
(1, 'Petrol', 'expense', 2),
(1, 'Movies', 'expense', 3),
(1, 'OTT Subscriptions', 'expense', 3);

-- ========================
-- MERCHANTS
-- ========================
INSERT INTO merchants (name, user_id) VALUES
('D-Mart', 1),
('Big Bazaar', 1),
('Zomato', 1),
('Swiggy', 1),
('Bharat Petrol Pump', 1),
('Uber', 1),
('Amazon India', 1),
('Flipkart', 1),
('Airtel', 1),
('Apollo Pharmacy', 1);

-- ========================
-- TRANSACTIONS (50 entries Jan–Aug 2025)
-- ========================

-- SALARIES (8 months)
INSERT INTO transactions (user_id, account_id, category_id, merchant_id, amount, transaction_type, transaction_date, description) VALUES
(1, 3, (SELECT id FROM categories WHERE name='Salary' AND user_id=1), NULL, 60000, 'income', '2025-01-01', 'January Salary'),
(1, 3, (SELECT id FROM categories WHERE name='Salary' AND user_id=1), NULL, 60000, 'income', '2025-02-01', 'February Salary'),
(1, 3, (SELECT id FROM categories WHERE name='Salary' AND user_id=1), NULL, 60000, 'income', '2025-03-01', 'March Salary'),
(1, 3, (SELECT id FROM categories WHERE name='Salary' AND user_id=1), NULL, 60000, 'income', '2025-04-01', 'April Salary'),
(1, 3, (SELECT id FROM categories WHERE name='Salary' AND user_id=1), NULL, 60000, 'income', '2025-05-01', 'May Salary'),
(1, 3, (SELECT id FROM categories WHERE name='Salary' AND user_id=1), NULL, 60000, 'income', '2025-06-01', 'June Salary'),
(1, 3, (SELECT id FROM categories WHERE name='Salary' AND user_id=1), NULL, 60000, 'income', '2025-07-01', 'July Salary'),
(1, 3, (SELECT id FROM categories WHERE name='Salary' AND user_id=1), NULL, 60000, 'income', '2025-08-01', 'August Salary');

-- EXPENSES (42 transactions across months)
INSERT INTO transactions (user_id, account_id, category_id, merchant_id, amount, transaction_type, transaction_date, description) VALUES
-- JANUARY
(1, 2, (SELECT id FROM categories WHERE name='Groceries' AND user_id=1), (SELECT id FROM merchants WHERE name='D-Mart' AND user_id=1), 3500, 'expense', '2025-01-05', 'Monthly Groceries'),
(1, 2, (SELECT id FROM categories WHERE name='Restaurants' AND user_id=1), (SELECT id FROM merchants WHERE name='Zomato' AND user_id=1), 800, 'expense', '2025-01-07', 'Dinner from Zomato'),
(1, 2, (SELECT id FROM categories WHERE name='Petrol' AND user_id=1), (SELECT id FROM merchants WHERE name='Bharat Petrol Pump' AND user_id=1), 2000, 'expense', '2025-01-10', 'Fuel refill'),
(1, 4, (SELECT id FROM categories WHERE name='Shopping' AND user_id=1), (SELECT id FROM merchants WHERE name='Amazon India' AND user_id=1), 2500, 'expense', '2025-01-15', 'New Shoes'),
(1, 2, (SELECT id FROM categories WHERE name='Utilities' AND user_id=1), (SELECT id FROM merchants WHERE name='Airtel' AND user_id=1), 1200, 'expense', '2025-01-18', 'Mobile Bill'),
(1, 2, (SELECT id FROM categories WHERE name='Healthcare' AND user_id=1), (SELECT id FROM merchants WHERE name='Apollo Pharmacy' AND user_id=1), 600, 'expense', '2025-01-20', 'Medicines'),

-- FEBRUARY
(1, 2, (SELECT id FROM categories WHERE name='Groceries' AND user_id=1), (SELECT id FROM merchants WHERE name='Big Bazaar' AND user_id=1), 3200, 'expense', '2025-02-04', 'Monthly Groceries'),
(1, 2, (SELECT id FROM categories WHERE name='Restaurants' AND user_id=1), (SELECT id FROM merchants WHERE name='Swiggy' AND user_id=1), 950, 'expense', '2025-02-08', 'Lunch from Swiggy'),
(1, 2, (SELECT id FROM categories WHERE name='Cabs' AND user_id=1), (SELECT id FROM merchants WHERE name='Uber' AND user_id=1), 500, 'expense', '2025-02-10', 'Airport Drop'),
(1, 2, (SELECT id FROM categories WHERE name='Movies' AND user_id=1), NULL, 700, 'expense', '2025-02-14', 'Valentine Movie'),
(1, 4, (SELECT id FROM categories WHERE name='Shopping' AND user_id=1), (SELECT id FROM merchants WHERE name='Flipkart' AND user_id=1), 2200, 'expense', '2025-02-18', 'Home Essentials'),
(1, 2, (SELECT id FROM categories WHERE name='Utilities' AND user_id=1), (SELECT id FROM merchants WHERE name='Airtel' AND user_id=1), 1100, 'expense', '2025-02-20', 'Broadband Bill'),

-- MARCH
(1, 2, (SELECT id FROM categories WHERE name='Groceries' AND user_id=1), (SELECT id FROM merchants WHERE name='D-Mart' AND user_id=1), 4000, 'expense', '2025-03-05', 'Monthly Groceries'),
(1, 2, (SELECT id FROM categories WHERE name='Restaurants' AND user_id=1), (SELECT id FROM merchants WHERE name='Zomato' AND user_id=1), 1200, 'expense', '2025-03-09', 'Weekend Dinner'),
(1, 2, (SELECT id FROM categories WHERE name='Petrol' AND user_id=1), (SELECT id FROM merchants WHERE name='Bharat Petrol Pump' AND user_id=1), 2100, 'expense', '2025-03-12', 'Fuel refill'),
(1, 4, (SELECT id FROM categories WHERE name='Shopping' AND user_id=1), (SELECT id FROM merchants WHERE name='Amazon India' AND user_id=1), 3000, 'expense', '2025-03-17', 'Headphones'),
(1, 2, (SELECT id FROM categories WHERE name='Healthcare' AND user_id=1), (SELECT id FROM merchants WHERE name='Apollo Pharmacy' AND user_id=1), 900, 'expense', '2025-03-22', 'Medicines'),
(1, 2, (SELECT id FROM categories WHERE name='OTT Subscriptions' AND user_id=1), NULL, 499, 'expense', '2025-03-25', 'Netflix Subscription'),

-- APRIL
(1, 2, (SELECT id FROM categories WHERE name='Groceries' AND user_id=1), (SELECT id FROM merchants WHERE name='Big Bazaar' AND user_id=1), 3700, 'expense', '2025-04-06', 'Monthly Groceries'),
(1, 2, (SELECT id FROM categories WHERE name='Restaurants' AND user_id=1), (SELECT id FROM merchants WHERE name='Swiggy' AND user_id=1), 850, 'expense', '2025-04-11', 'Family Dinner'),
(1, 2, (SELECT id FROM categories WHERE name='Cabs' AND user_id=1), (SELECT id FROM merchants WHERE name='Uber' AND user_id=1), 400, 'expense', '2025-04-15', 'Cab to Office'),
(1, 4, (SELECT id FROM categories WHERE name='Shopping' AND user_id=1), (SELECT id FROM merchants WHERE name='Flipkart' AND user_id=1), 1800, 'expense', '2025-04-19', 'Summer Wear'),
(1, 2, (SELECT id FROM categories WHERE name='Utilities' AND user_id=1), (SELECT id FROM merchants WHERE name='Airtel' AND user_id=1), 1150, 'expense', '2025-04-22', 'Electricity Bill'),

-- MAY
(1, 2, (SELECT id FROM categories WHERE name='Groceries' AND user_id=1), (SELECT id FROM merchants WHERE name='D-Mart' AND user_id=1), 3900, 'expense', '2025-05-03', 'Monthly Groceries'),
(1, 2, (SELECT id FROM categories WHERE name='Restaurants' AND user_id=1), (SELECT id FROM merchants WHERE name='Zomato' AND user_id=1), 950, 'expense', '2025-05-07', 'Lunch Out'),
(1, 2, (SELECT id FROM categories WHERE name='Petrol' AND user_id=1), (SELECT id FROM merchants WHERE name='Bharat Petrol Pump' AND user_id=1), 2300, 'expense', '2025-05-10', 'Fuel refill'),
(1, 4, (SELECT id FROM categories WHERE name='Shopping' AND user_id=1), (SELECT id FROM merchants WHERE name='Amazon India' AND user_id=1), 2800, 'expense', '2025-05-15', 'Kitchen Items'),
(1, 2, (SELECT id FROM categories WHERE name='Movies' AND user_id=1), NULL, 750, 'expense', '2025-05-20', 'Movie Outing'),
(1, 2, (SELECT id FROM categories WHERE name='Utilities' AND user_id=1), (SELECT id FROM merchants WHERE name='Airtel' AND user_id=1), 1250, 'expense', '2025-05-25', 'Mobile Bill'),

-- JUNE
(1, 2, (SELECT id FROM categories WHERE name='Groceries' AND user_id=1), (SELECT id FROM merchants WHERE name='Big Bazaar' AND user_id=1), 3600, 'expense', '2025-06-04', 'Monthly Groceries'),
(1, 2, (SELECT id FROM categories WHERE name='Restaurants' AND user_id=1), (SELECT id FROM merchants WHERE name='Swiggy' AND user_id=1), 1100, 'expense', '2025-06-09', 'Dinner'),
(1, 2, (SELECT id FROM categories WHERE name='Cabs' AND user_id=1), (SELECT id FROM merchants WHERE name='Uber' AND user_id=1), 450, 'expense', '2025-06-13', 'Cab to Station'),
(1, 2, (SELECT id FROM categories WHERE name='Healthcare' AND user_id=1), (SELECT id FROM merchants WHERE name='Apollo Pharmacy' AND user_id=1), 800, 'expense', '2025-06-18', 'Medicines'),
(1, 2, (SELECT id FROM categories WHERE name='OTT Subscriptions' AND user_id=1), NULL, 499, 'expense', '2025-06-25', 'Netflix Subscription'),

-- JULY
(1, 2, (SELECT id FROM categories WHERE name='Groceries' AND user_id=1), (SELECT id FROM merchants WHERE name='D-Mart' AND user_id=1), 4200, 'expense', '2025-07-05', 'Monthly Groceries'),
(1, 2, (SELECT id FROM categories WHERE name='Restaurants' AND user_id=1), (SELECT id FROM merchants WHERE name='Zomato' AND user_id=1), 1000, 'expense', '2025-07-08', 'Weekend Dinner'),
(1, 2, (SELECT id FROM categories WHERE name='Petrol' AND user_id=1), (SELECT id FROM merchants WHERE name='Bharat Petrol Pump' AND user_id=1), 2400, 'expense', '2025-07-12', 'Fuel refill'),
(1, 4, (SELECT id FROM categories WHERE name='Shopping' AND user_id=1), (SELECT id FROM merchants WHERE name='Amazon India' AND user_id=1), 2700, 'expense', '2025-07-17', 'Electronics'),
(1, 2, (SELECT id FROM categories WHERE name='Movies' AND user_id=1), NULL, 800, 'expense', '2025-07-21', 'Cinema Outing'),

-- AUGUST
(1, 2, (SELECT id FROM categories WHERE name='Groceries' AND user_id=1), (SELECT id FROM merchants WHERE name='Big Bazaar' AND user_id=1), 3900, 'expense', '2025-08-04', 'Monthly Groceries'),
(1, 2, (SELECT id FROM categories WHERE name='Restaurants' AND user_id=1), (SELECT id FROM merchants WHERE name='Swiggy' AND user_id=1), 1200, 'expense', '2025-08-08', 'Birthday Dinner'),
(1, 2, (SELECT id FROM categories WHERE name='Cabs' AND user_id=1), (SELECT id FROM merchants WHERE name='Uber' AND user_id=1), 600, 'expense', '2025-08-10', 'Airport Ride'),
(1, 4, (SELECT id FROM categories WHERE name='Shopping' AND user_id=1), (SELECT id FROM merchants WHERE name='Flipkart' AND user_id=1), 2500, 'expense', '2025-08-15', 'Festival Shopping'),
(1, 2, (SELECT id FROM categories WHERE name='Utilities' AND user_id=1), (SELECT id FROM merchants WHERE name='Airtel' AND user_id=1), 1300, 'expense', '2025-08-20', 'Mobile Bill'),
(1, 2, (SELECT id FROM categories WHERE name='Healthcare' AND user_id=1), (SELECT id FROM merchants WHERE name='Apollo Pharmacy' AND user_id=1), 700, 'expense', '2025-08-25', 'Medicines');

-- ========================
-- BUDGETS (Jan–Aug 2025, 4 categories)
-- ========================
INSERT INTO budgets (user_id, category_id, amount, year, month) VALUES
-- Groceries
(1, (SELECT id FROM categories WHERE name='Groceries' AND user_id=1), 4000, 2025, 1),
(1, (SELECT id FROM categories WHERE name='Groceries' AND user_id=1), 4000, 2025, 2),
(1, (SELECT id FROM categories WHERE name='Groceries' AND user_id=1), 4200, 2025, 3),
(1, (SELECT id FROM categories WHERE name='Groceries' AND user_id=1), 4200, 2025, 4),
(1, (SELECT id FROM categories WHERE name='Groceries' AND user_id=1), 4300, 2025, 5),
(1, (SELECT id FROM categories WHERE name='Groceries' AND user_id=1), 4300, 2025, 6),
(1, (SELECT id FROM categories WHERE name='Groceries' AND user_id=1), 4400, 2025, 7),
(1, (SELECT id FROM categories WHERE name='Groceries' AND user_id=1), 4500, 2025, 8),

-- Restaurants
(1, (SELECT id FROM categories WHERE name='Restaurants' AND user_id=1), 2500, 2025, 1),
(1, (SELECT id FROM categories WHERE name='Restaurants' AND user_id=1), 2500, 2025, 2),
(1, (SELECT id FROM categories WHERE name='Restaurants' AND user_id=1), 2600, 2025, 3),
(1, (SELECT id FROM categories WHERE name='Restaurants' AND user_id=1), 2600, 2025, 4),
(1, (SELECT id FROM categories WHERE name='Restaurants' AND user_id=1), 2700, 2025, 5),
(1, (SELECT id FROM categories WHERE name='Restaurants' AND user_id=1), 2700, 2025, 6),
(1, (SELECT id FROM categories WHERE name='Restaurants' AND user_id=1), 2800, 2025, 7),
(1, (SELECT id FROM categories WHERE name='Restaurants' AND user_id=1), 2800, 2025, 8),

-- Transport
(1, (SELECT id FROM categories WHERE name='Transport' AND user_id=1), 5000, 2025, 1),
(1, (SELECT id FROM categories WHERE name='Transport' AND user_id=1), 5000, 2025, 2),
(1, (SELECT id FROM categories WHERE name='Transport' AND user_id=1), 5200, 2025, 3),
(1, (SELECT id FROM categories WHERE name='Transport' AND user_id=1), 5200, 2025, 4),
(1, (SELECT id FROM categories WHERE name='Transport' AND user_id=1), 5400, 2025, 5),
(1, (SELECT id FROM categories WHERE name='Transport' AND user_id=1), 5400, 2025, 6),
(1, (SELECT id FROM categories WHERE name='Transport' AND user_id=1), 5600, 2025, 7),
(1, (SELECT id FROM categories WHERE name='Transport' AND user_id=1), 5600, 2025, 8),

-- Entertainment
(1, (SELECT id FROM categories WHERE name='Entertainment' AND user_id=1), 3000, 2025, 1),
(1, (SELECT id FROM categories WHERE name='Entertainment' AND user_id=1), 3000, 2025, 2),
(1, (SELECT id FROM categories WHERE name='Entertainment' AND user_id=1), 3200, 2025, 3),
(1, (SELECT id FROM categories WHERE name='Entertainment' AND user_id=1), 3200, 2025, 4),
(1, (SELECT id FROM categories WHERE name='Entertainment' AND user_id=1), 3400, 2025, 5),
(1, (SELECT id FROM categories WHERE name='Entertainment' AND user_id=1), 3400, 2025, 6),
(1, (SELECT id FROM categories WHERE name='Entertainment' AND user_id=1), 3500, 2025, 7),
(1, (SELECT id FROM categories WHERE name='Entertainment' AND user_id=1), 3600, 2025, 8);