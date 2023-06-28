USE db_cinema;

-- Return how many tables there is in the database
DROP FUNCTION IF EXISTS count_tables_in_database;
CREATE FUNCTION count_tables_in_database()
    RETURNS INT
    DETERMINISTIC
BEGIN
    DECLARE count_tables INT;

    SELECT COUNT(*)
    INTO count_tables
    FROM information_schema.tables
    WHERE table_schema = DATABASE()
    AND table_type = 'BASE TABLE';

    RETURN count_tables;
END;

DROP FUNCTION IF EXISTS get_money_earned_in_month;
CREATE FUNCTION get_money_earned_in_month(param_year INT, param_month INT)
    RETURNS INT
    DETERMINISTIC
BEGIN
    DECLARE result INT;

    SELECT COALESCE(SUM(sales), 0)
    INTO result
    FROM view_earn_per_month
    WHERE at_year = param_year AND at_month = param_month;

    RETURN result;
END;

DROP FUNCTION IF EXISTS get_money_earned_in_year;
CREATE FUNCTION get_money_earned_in_year(param_year INT)
    RETURNS INT
    DETERMINISTIC
BEGIN
    DECLARE result INT;

    SELECT COALESCE(SUM(sales), 0)
    INTO result
    FROM view_earn_per_month
    WHERE at_year = param_year;

    RETURN result;
END;

DROP PROCEDURE IF EXISTS get_employee;
CREATE PROCEDURE get_employee(IN employee_id INT)
BEGIN
    SELECT * FROM employee WHERE id = employee_id;
END;

DROP PROCEDURE IF EXISTS delete_employee;
CREATE PROCEDURE delete_employee(IN param_id INT, OUT succeed BOOLEAN)
BEGIN
    IF NOT EXISTS(SELECT *
                  FROM employee
                  WHERE employee.id = param_id)
    THEN
        SET succeed = FALSE;
        SELECT 'Error';
    ELSE
        UPDATE employee
        SET still_active = 0
        WHERE param_id = id;
        SET succeed = TRUE;
    END IF;
END;
