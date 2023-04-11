USE db_cinema;

DROP PROCEDURE IF EXISTS test_get_products_under_price;
CREATE PROCEDURE test_get_products_under_price()
BEGIN
    DECLARE expected_result TEXT DEFAULT '9,Candy,25|4,Small Soda,20';
    DECLARE actual_result TEXT;

    CALL get_products_under_price(30);

    SELECT GROUP_CONCAT(CONCAT(id, ',', product_name, ',', price) SEPARATOR '|')
    INTO actual_result
    FROM temporary_table_products_under_price;

    DROP TEMPORARY TABLE IF EXISTS temporary_table_products_under_price;

    SELECT IF(actual_result != expected_result OR actual_result IS NULL, 0, 1) AS test_result;
END;
