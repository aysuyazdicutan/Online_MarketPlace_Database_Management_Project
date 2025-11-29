-- ===== TRIGGER 2: trg_after_insert_reviews_audit =====
-- Purpose: Automatically logs all review insertions into an audit table
--          for tracking and auditing purposes.

-- First, create the audit table if it doesn't exist
CREATE TABLE IF NOT EXISTS Review_Audit (
    audit_id INT PRIMARY KEY AUTO_INCREMENT,
    review_id INT,
    product_id INT,
    user_id INT,
    rating INT,
    action_type VARCHAR(20),
    action_time DATETIME
);

DELIMITER $$

DROP TRIGGER IF EXISTS trg_after_insert_reviews_audit $$

CREATE TRIGGER trg_after_insert_reviews_audit
AFTER INSERT ON Reviews
FOR EACH ROW
BEGIN
    -- Insert audit log entry for the new review
    INSERT INTO Review_Audit (
        review_id,
        product_id,
        user_id,
        rating,
        action_type,
        action_time
    ) VALUES (
        NEW.review_id,
        NEW.product_id,
        NEW.user_id,
        NEW.rating,
        'INSERT',
        NOW()
    );
END $$

DELIMITER ;

-- ===== TEST QUERIES FOR TRIGGER 2 =====

-- Test 1: Check Review_Audit table before insert
-- Run this to capture "before" screenshot
SELECT * FROM Review_Audit ORDER BY audit_id DESC LIMIT 5;

-- Test 2: Insert a new review
-- This will fire the trigger and create an audit log entry
INSERT INTO Reviews (product_id, user_id, rating, comment, review_date)
VALUES (1, 1, 5, 'Great product! Highly recommended.', CURDATE());

-- Test 3: Check Review_Audit table after insert
-- Run this to capture "after" screenshot (should show new audit entry)
SELECT * FROM Review_Audit ORDER BY audit_id DESC LIMIT 5;

-- Test 4: Verify the review was inserted correctly
SELECT * FROM Reviews ORDER BY review_id DESC LIMIT 1;
