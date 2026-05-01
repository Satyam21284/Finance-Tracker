-- Creating Main Tables of the Expense Tracker DB Schema:

-- users table for storing user credentials and roles
CREATE TABLE IF NOT EXISTS `users` (
  `id` INT AUTO_INCREMENT PRIMARY KEY,
  `username` VARCHAR(50) NOT NULL UNIQUE,
  `email` VARCHAR(100) NOT NULL UNIQUE,
  `password_hash` VARCHAR(255) NOT NULL,
  `role` ENUM('user', 'admin') NOT NULL DEFAULT 'user',
  `created_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- accounts table for different types of user accounts
CREATE TABLE IF NOT EXISTS `accounts` (
  `id` INT AUTO_INCREMENT PRIMARY KEY,
  `user_id` INT NOT NULL,
  `name` VARCHAR(100) NOT NULL,
  `account_type` ENUM('CashAccount', 'BankAccount', 'CreditCardAccount') NOT NULL,
  `balance` DECIMAL(15, 2) NOT NULL DEFAULT 0.00,
  `created_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  FOREIGN KEY (`user_id`) REFERENCES `users`(`id`) ON DELETE CASCADE
);

-- categories table for income and expense classification
CREATE TABLE IF NOT EXISTS `categories` (
  `id` INT AUTO_INCREMENT PRIMARY KEY,
  `user_id` INT NOT NULL,
  `name` VARCHAR(100) NOT NULL,
  `type` ENUM('income', 'expense') NOT NULL,
  `parent_id` INT NULL,
  `created_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  FOREIGN KEY (`user_id`) REFERENCES `users`(`id`) ON DELETE CASCADE,
  FOREIGN KEY (`parent_id`) REFERENCES `categories`(`id`) ON DELETE SET NULL,
  UNIQUE KEY `user_category_name` (`user_id`, `name`)
);

-- merchants table for tracking vendors
CREATE TABLE IF NOT EXISTS `merchants` (
  `id` INT AUTO_INCREMENT PRIMARY KEY,
  `name` VARCHAR(255) NOT NULL,
  `user_id` INT, -- User-specific or global (NULL user_id for global)
  `created_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  FOREIGN KEY (`user_id`) REFERENCES `users`(`id`) ON DELETE CASCADE,
  UNIQUE KEY `user_merchant_name` (`user_id`, `name`)
);

-- transactions table to log all financial activities
CREATE TABLE IF NOT EXISTS `transactions` (
  `id` INT AUTO_INCREMENT PRIMARY KEY,
  `user_id` INT NOT NULL,
  `account_id` INT NOT NULL,
  `category_id` INT NOT NULL,
  `merchant_id` INT NULL,
  `amount` DECIMAL(15, 2) NOT NULL,
  `transaction_type` ENUM('expense', 'income') NOT NULL,
  `transaction_date` DATETIME NOT NULL,
  `description` VARCHAR(255),
  `created_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  `updated_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  FOREIGN KEY (`user_id`) REFERENCES `users`(`id`) ON DELETE CASCADE,
  FOREIGN KEY (`account_id`) REFERENCES `accounts`(`id`) ON DELETE CASCADE,
  FOREIGN KEY (`category_id`) REFERENCES `categories`(`id`) ON DELETE RESTRICT,
  FOREIGN KEY (`merchant_id`) REFERENCES `merchants`(`id`) ON DELETE SET NULL,
  INDEX `idx_transaction_date` (`transaction_date`)
);

-- budgets table for setting financial goals
CREATE TABLE IF NOT EXISTS `budgets` (
  `id` INT AUTO_INCREMENT PRIMARY KEY,
  `user_id` INT NOT NULL,
  `category_id` INT NOT NULL,
  `amount` DECIMAL(15, 2) NOT NULL,
  `month` INT NOT NULL CHECK (`month` BETWEEN 1 AND 12),
  `year` INT NOT NULL,
  `created_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  FOREIGN KEY (`user_id`) REFERENCES `users`(`id`) ON DELETE CASCADE,
  FOREIGN KEY (`category_id`) REFERENCES `categories`(`id`) ON DELETE CASCADE,
  UNIQUE KEY `user_category_period` (`user_id`, `category_id`, `year`, `month`)
);

-- audit_log table to track user actions
CREATE TABLE IF NOT EXISTS `audit_log` (
  `id` BIGINT AUTO_INCREMENT PRIMARY KEY,
  `user_id` INT NULL,
  `action` VARCHAR(255) NOT NULL,
  `details` TEXT,
  `timestamp` TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  FOREIGN KEY (`user_id`) REFERENCES `users`(`id`) ON DELETE SET NULL
);