USE db_cinema;

DROP VIEW IF EXISTS view_employee_with_sold_products_count;
CREATE VIEW view_employee_with_sold_products_count AS
(
    SELECT
         employee.id,
         employee.first_name,
         employee.last_name,
         IF(sell.employee_id IS NULL, 0, COUNT(*)) AS product_count
    FROM employee LEFT JOIN sell
    ON employee.id = sell.employee_id
    GROUP BY employee.id
);

-- Return all the movies not for adults
DROP VIEW IF EXISTS view_movies_not_for_adults;
CREATE VIEW view_movies_not_for_adults AS
(
    SELECT id, movie_name
    FROM movie
    WHERE rating != 'R'
);

-- SELECT * FROM view_movies_not_for_adults;

DROP VIEW IF EXISTS view_employee_earn_per_month;
CREATE VIEW view_employee_earn_per_month AS
(
    SELECT
         employee.id,
         YEAR(sell_time) as year,
         MONTH(sell_time) AS month,
         SUM(price) AS sales
     FROM sell INNER JOIN product INNER JOIN employee
     ON sell.product_id = product.id AND sell.employee_id = employee.id
     GROUP BY YEAR(sell_time), MONTH(sell.sell_time), employee.id
);

SELECT * FROM view_employee_earn_per_month;

