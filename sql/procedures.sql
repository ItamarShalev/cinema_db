USE db_cinema;

DROP PROCEDURE IF EXISTS get_products_under_price;
CREATE PROCEDURE get_products_under_price(IN param_price INT)
BEGIN
    DROP TEMPORARY TABLE IF EXISTS temporary_table_products_under_price;
    CREATE TEMPORARY TABLE IF NOT EXISTS temporary_table_products_under_price
    (
        id           INT,
        product_name VARCHAR(255),
        price        INT
    );

    INSERT INTO temporary_table_products_under_price
    SELECT id, product_name, price
    FROM product
    WHERE price < param_price;

    SELECT * FROM temporary_table_products_under_price;
END;
