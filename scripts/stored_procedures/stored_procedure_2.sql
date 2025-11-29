-- ===== STORED PROCEDURE 2: sp_get_user_order_summary =====
-- Purpose: Returns a comprehensive summary of all orders placed by a given user,
--          including order details, delivery address, and product information.

DELIMITER $$

DROP PROCEDURE IF EXISTS sp_get_user_order_summary $$

CREATE PROCEDURE sp_get_user_order_summary(
    IN p_user_id INT
)
BEGIN
    SELECT
        o.order_id,
        o.order_date,
        o.total_amount,
        a.address_title,
        a.address_line,
        a.city,
        a.postal_code,
        GROUP_CONCAT(
            CONCAT(p.product_name, ' (Qty: ', od.quantity, ')') 
            SEPARATOR ', '
        ) AS products
    FROM Orders o
    JOIN Addresses a ON o.delivery_address_id = a.address_id
    JOIN Order_Details od ON o.order_id = od.order_id
    JOIN Products p ON od.product_id = p.product_id
    WHERE o.user_id = p_user_id
    GROUP BY 
        o.order_id, 
        o.order_date, 
        o.total_amount, 
        a.address_title,
        a.address_line,
        a.city,
        a.postal_code
    ORDER BY o.order_date DESC;
END $$

DELIMITER ;

-- ===== TEST QUERIES FOR STORED PROCEDURE 2 =====

-- Test 1: Call the stored procedure to get order summary for a user
-- Replace 1 with a valid user_id from your database
CALL sp_get_user_order_summary(1);

-- Test 2: Verify the user exists and has orders
SELECT user_id, first_name, last_name, email 
FROM Users 
WHERE user_id = 1;

SELECT COUNT(*) AS order_count 
FROM Orders 
WHERE user_id = 1;

-- Test 3: Test with a different user (if available)
-- CALL sp_get_user_order_summary(2);

-- Test 4: Test with a user that has no orders (should return empty result set)
-- CALL sp_get_user_order_summary(999);
