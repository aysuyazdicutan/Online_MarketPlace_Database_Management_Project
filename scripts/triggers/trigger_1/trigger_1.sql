-- ===== TRIGGER 1: trg_before_insert_order_details_update_stock =====
-- Purpose: Automatically checks stock availability and updates product stock
--          when a new order detail is inserted. Prevents orders if insufficient stock.

DELIMITER $$

DROP TRIGGER IF EXISTS trg_before_insert_order_details_update_stock $$

CREATE TRIGGER trg_before_insert_order_details_update_stock
BEFORE INSERT ON Order_Details
FOR EACH ROW
BEGIN
    DECLARE v_stock INT;
    
    -- Lock the product row and get current stock quantity
    SELECT stock_quantity INTO v_stock
    FROM Products
    WHERE product_id = NEW.product_id
    FOR UPDATE;
    
    -- Check if there is enough stock
    IF v_stock < NEW.quantity THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Not enough stock for this product.';
    END IF;
    
    -- Update stock quantity by subtracting the ordered quantity
    UPDATE Products
    SET stock_quantity = stock_quantity - NEW.quantity
    WHERE product_id = NEW.product_id;
END $$

DELIMITER ;

-- ===== TEST QUERIES FOR TRIGGER 1 =====

-- Test 1: Check current stock before insert
-- Run this to capture "before" screenshot
SELECT product_id, product_name, stock_quantity 
FROM Products 
WHERE product_id = 1;

-- Test 2: Insert order detail (should succeed if stock is sufficient)
-- This will fire the trigger and update stock
INSERT INTO Order_Details (order_id, product_id, quantity, unit_price)
VALUES (1, 1, 2, 19.99);

-- Test 3: Check stock after insert
-- Run this to capture "after" screenshot (stock should be decreased)
SELECT product_id, product_name, stock_quantity 
FROM Products 
WHERE product_id = 1;

-- Test 4: Test error case - try to order more than available stock
-- This should fail with error message "Not enough stock for this product."
-- First, check current stock:
SELECT product_id, product_name, stock_quantity 
FROM Products 
WHERE product_id = 1;

-- Then try to insert an order detail with quantity exceeding stock:
-- (Replace 999 with a quantity larger than current stock_quantity)
INSERT INTO Order_Details (order_id, product_id, quantity, unit_price)
VALUES (1, 1, 999, 19.99);
