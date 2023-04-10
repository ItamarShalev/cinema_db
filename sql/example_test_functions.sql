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

DROP FUNCTION IF EXISTS example_scalar_function;
CREATE FUNCTION example_scalar_function(param_name_value TEXT)
    RETURNS INT
    DETERMINISTIC
BEGIN
    DECLARE result INT;

    SELECT id
    INTO result
    FROM test_table
    WHERE name_value = param_name_value;

    RETURN result;
END;

-- SELECT example_scalar_function('test1') AS result;

CREATE OR REPLACE VIEW view_example_list AS
(
    SELECT name_value
    FROM test_table
    ORDER BY name_value DESC
);

-- SELECT * FROM view_example_list;

CREATE OR REPLACE VIEW view_example_multi AS
(
    SELECT id, name_value
    FROM test_table
    WHERE id != 2
    ORDER BY id DESC
);

-- SELECT * FROM view_example_multi;

DROP FUNCTION IF EXISTS test_example_scalar_function;
CREATE FUNCTION test_example_scalar_function()
    RETURNS INT
    DETERMINISTIC
BEGIN
    DECLARE excepted_result INT DEFAULT 1;
    DECLARE actual_result INT;
    DECLARE test_result INT;

    SELECT example_scalar_function('test1') INTO actual_result;

    SET test_result = IF((actual_result != excepted_result OR actual_result IS NULL), 0, 1);

    RETURN test_result;
END;

-- SELECT test_example_scalar_function() AS test_result;

DROP FUNCTION IF EXISTS test_example_list_function;
CREATE FUNCTION test_example_list_function()
    RETURNS INT
    DETERMINISTIC
BEGIN
    -- Declare the expected result and the actual result
    -- The values of the expected result separated by ','.
    DECLARE expected_result TEXT DEFAULT 'test1,test2,test3';
    DECLARE actual_result TEXT;
    DECLARE test_result INT;

    -- Get the actual result by selecting the result from the temporary table
    SELECT GROUP_CONCAT(name_value ORDER BY name_value SEPARATOR ',')
    INTO actual_result
    FROM view_example_list;

    -- Compare the expected and actual results and return 1 if they match, 0 otherwise
    SET test_result =  IF(actual_result != expected_result OR actual_result IS NULL, 0, 1);

    RETURN test_result;
END;

-- SELECT test_example_list_function() AS test_result;

DROP FUNCTION IF EXISTS test_example_multi_function;
CREATE FUNCTION test_example_multi_function()
    RETURNS INT
    DETERMINISTIC
BEGIN
    -- Declare the expected result and the actual result
    -- The values of the expected result separated by ',' and rows by |.
    DECLARE expected_result TEXT DEFAULT '1,test1|3,test3';
    DECLARE actual_result TEXT;
    DECLARE test_result INT;

    SELECT GROUP_CONCAT(CONCAT(id, ',', name_value) ORDER BY id SEPARATOR '|')
    INTO actual_result
    FROM view_example_multi
    ORDER BY id;

    -- Compare the expected and actual results and return 1 if they match, 0 otherwise
    SET test_result =  IF(actual_result != expected_result OR actual_result IS NULL, 0, 1);

    RETURN test_result;
END;

-- SELECT test_example_multi_function() AS test_result;
