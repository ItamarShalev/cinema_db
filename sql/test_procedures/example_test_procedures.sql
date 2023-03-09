-- This file is an example of how to write a test for a stored procedure
-- Every separator of row is ';' and every separator of column is ','
-- Since the stored procedure is return the result of the query to the client,
-- and need to be tested, it first store the result of the query in a temporary table,
-- and then return the result of the temporary table to the client.

DROP DATABASE IF EXISTS db_example;
CREATE DATABASE db_example;

USE db_example;

CREATE TABLE test_table
(
    id         INT          NOT NULL,
    name_value VARCHAR(255) NOT NULL,
    PRIMARY KEY (id)
);

INSERT INTO test_table(id, name_value)
VALUES (1, 'test1'),
       (2, 'test2'),
       (3, 'test3');

DROP PROCEDURE IF EXISTS example_scalar_procedure;
CREATE PROCEDURE example_scalar_procedure(IN param_name_value TEXT, OUT param_id INT)
BEGIN
    SELECT id
    INTO param_id
    FROM test_table
    WHERE name_value = param_name_value;
END;

-- CALL example_scalar_procedure('test1', @id);
-- SELECT @id;

DROP PROCEDURE IF EXISTS example_list_procedure;
CREATE PROCEDURE example_list_procedure()
BEGIN

    DROP TABLE IF EXISTS table_example_list_procedure;
    CREATE TEMPORARY TABLE IF NOT EXISTS table_example_list_procedure
    (
        name_value VARCHAR(255)
    );

    INSERT INTO table_example_list_procedure (name_value) SELECT name_value FROM test_table;

    SELECT * FROM table_example_list_procedure ORDER BY name_value DESC;
END;

-- CALL example_list_procedure();

DROP PROCEDURE IF EXISTS example_multi_procedure;
CREATE PROCEDURE example_multi_procedure()
BEGIN
    DROP TABLE IF EXISTS table_example_multi_procedure;
    CREATE TEMPORARY TABLE IF NOT EXISTS table_example_multi_procedure
    (
        id         INT,
        name_value VARCHAR(255)
    );

    INSERT INTO table_example_multi_procedure
    SELECT id, name_value
    FROM test_table
    WHERE id != 2;

    SELECT * FROM table_example_multi_procedure ORDER BY id DESC;
END;

-- CALL example_multi_procedure();

DROP PROCEDURE IF EXISTS test_example_scalar_procedure;
CREATE PROCEDURE test_example_scalar_procedure()
BEGIN
    DECLARE excepted_result INT DEFAULT 1;
    DECLARE actual_result INT;
    CALL example_scalar_procedure('test1', actual_result);
    SELECT IF((actual_result != excepted_result OR actual_result IS NULL), 0, 1) AS test_result;
END;

-- CALL test_example_scalar_function();

DROP PROCEDURE IF EXISTS test_example_list_procedure;
CREATE PROCEDURE test_example_list_procedure()
BEGIN

    -- Declare the expected result and the actual result
    -- The values of the expected result separated by ','.
    DECLARE expected_result TEXT DEFAULT 'test1,test2,test3';
    DECLARE actual_result TEXT;

    -- Execute the example_list_procedure and store the result in the temporary table
    CALL example_list_procedure();

    -- Get the actual result by selecting the result from the temporary table
    SELECT GROUP_CONCAT(name_value ORDER BY name_value SEPARATOR ',')
    INTO actual_result
    FROM table_example_list_procedure;

    -- Drop the temporary table
    DROP TABLE IF EXISTS table_example_list_procedure;

    -- Compare the expected and actual results and return 1 if they match, 0 otherwise
    SELECT IF(actual_result != expected_result OR actual_result IS NULL, 0, 1) AS test_result;
END;


-- CALL test_example_list_procedure();

DROP PROCEDURE IF EXISTS test_example_multi_procedure;
CREATE PROCEDURE test_example_multi_procedure()
BEGIN

    -- Declare the expected result and the actual result
    -- The values of the expected result separated by ',' and rows by |.
    DECLARE expected_result TEXT DEFAULT '1,test1|3,test3';
    DECLARE actual_result TEXT;

    -- Get the actual result by calling the example_multi_procedure
    CALL example_multi_procedure();

    SELECT GROUP_CONCAT(CONCAT(id, ',', name_value) ORDER BY id SEPARATOR '|')
    INTO actual_result
    FROM table_example_multi_procedure
    ORDER BY id;

    DROP TABLE IF EXISTS table_example_multi_procedure;

    -- Compare the expected and actual results and return 1 if they match, 0 otherwise
    SELECT IF(actual_result != expected_result OR actual_result IS NULL, 0, 1) AS test_result;
END;

-- CALL test_example_multi_procedure();
