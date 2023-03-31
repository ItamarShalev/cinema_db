USE db_cinema;

DROP VIEW IF EXISTS view_employee_with_sold_products_count;
CREATE VIEW view_employee_with_sold_products_count AS
    (SELECT
         employee.id,
         employee.first_name,
         employee.last_name,
         IF(sell.employee_id IS NULL, 0, COUNT(*)) AS product_count
    FROM employee LEFT JOIN sell
    ON employee.id = sell.employee_id
    GROUP BY employee.id);
