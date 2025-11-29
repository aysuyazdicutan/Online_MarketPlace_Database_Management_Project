-- ===== STORED PROCEDURE 1: sp_create_single_product_order =====
-- Purpose: Creates a complete order for a single product, including
--          order header and order details. Relies on Trigger 1 to handle
--          stock validation and updates automatically.

DELIMITER $$

DROP PROCEDURE IF EXISTS sp_create_single_product_order $$

CREATE PROCEDURE sp_create_single_product_order(
    IN p_user_id INT,
    IN p_delivery_address_id INT,
    IN p_product_id INT,
    IN p_quantity INT,
    OUT p_new_order_id INT
)
BEGIN
    DECLARE v_price DECIMAL(10, 2);
    DECLARE v_total_amount DECIMAL(10, 2);
    DECLARE v_order_id INT;
    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        ROLLBACK;
        RESIGNAL;
    END;
    
    -- Start transaction
    START TRANSACTION;
    
    -- Get product price
    SELECT price INTO v_price
    FROM Products
    WHERE product_id = p_product_id;
    
    -- Calculate total amount
    SET v_total_amount = v_price * p_quantity;
    
    -- Insert order header
    INSERT INTO Orders (user_id, order_date, total_amount, delivery_address_id)
    VALUES (p_user_id, NOW(), v_total_amount, p_delivery_address_id);
    
    -- Get the generated order_id
    SET v_order_id = LAST_INSERT_ID();
    
    -- Insert order detail
    -- Note: Trigger 1 will automatically check stock and update it
    INSERT INTO Order_Details (order_id, product_id, quantity, unit_price)
    VALUES (v_order_id, p_product_id, p_quantity, v_price);
    
    -- Commit transaction
    COMMIT;
    
    -- Set output parameter
    SET p_new_order_id = v_order_id;
END $$

DELIMITER ;

-- ===== TEST QUERIES FOR STORED PROCEDURE 1 =====

-- Test 1: Check product details before creating order
SELECT product_id, product_name, price, stock_quantity 
FROM Products 
WHERE product_id = 1;

-- Test 2: Call the stored procedure to create an order
-- Replace the parameter values with valid IDs from your database
CALL sp_create_single_product_order(1, 1, 1, 3, @new_order_id);

-- Test 3: Check the output parameter
SELECT @new_order_id AS new_order_id;

-- Test 4: Verify the order was created
SELECT * FROM Orders WHERE order_id = @new_order_id;

-- Test 5: Verify the order details were created
SELECT * FROM Order_Details WHERE order_id = @new_order_id;

-- Test 6: Verify stock was updated (should be decreased by the ordered quantity)
SELECT product_id, product_name, stock_quantity 
FROM Products 
WHERE product_id = 1;

-- Test 7: Test error case - try to order more than available stock
-- This should fail and rollback the transaction
-- First check current stock:
SELECT product_id, product_name, stock_quantity 
FROM Products 
WHERE product_id = 1;

-- Then try to create an order with quantity exceeding stock:
-- (Replace 999 with a quantity larger than current stock_quantity)
CALL sp_create_single_product_order(1, 1, 1, 999, @new_order_id);
