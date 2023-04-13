using Microsoft.VisualStudio.TestTools.UnitTesting;

namespace cinemaDB
{
    [TestClass]
    public class UnitTest: IDisposable
    {
        private SqlHelper sqlHelper;

        public UnitTest() {
            sqlHelper = new SqlHelper();
        } 

        [TestInitialize]
        public void SetUp()
        {
            string connectionString = "";

            /* Read the server details using Github secrets */
            string fullSecretFileLocation = FileFinder.FindFile(FileFinder.FindSlnDirectoryLocation(), "secret_mysql_login.txt");
            using (var streamReader = File.OpenText(fullSecretFileLocation))
            {
                string[] lines = streamReader.ReadToEnd().Split(",".ToCharArray(), StringSplitOptions.RemoveEmptyEntries);
                Assert.IsNotNull(lines);
                Assert.AreEqual(lines.Length, 3);
                connectionString = SqlHelper.GetMySqlConnectionString(host: lines[0], username: lines[1], password: lines[2]);
            }

            sqlHelper.OpenDatabaseConnection(connectionString);
            var reader = sqlHelper.ExecuteSqlCode("DROP DATABASE IF EXISTS db_cinema;");
            reader.Close();
            sqlHelper.ExecuteSqlFile("scheme.sql");
            sqlHelper.ExecuteSqlFile("views.sql");
            sqlHelper.ExecuteSqlFile("data.sql");
            sqlHelper.ExecuteSqlFile("procedures.sql");
            sqlHelper.ExecuteSqlFile("functions.sql");
            sqlHelper.ExecuteSqlFile("test_procedures.sql");
            sqlHelper.ExecuteSqlFile("test_functions.sql");
        }

        [TestCleanup]
        public void TearDown()
        {
            sqlHelper.CloseDatabaseConnection();
        }

        private void RunExampleProcedureTest(string fileName, string procedureName)
        {
            sqlHelper.ExecuteSqlFile(fileName);
            bool result = sqlHelper.ExecuteProcedureTest(procedureName);
            Assert.IsTrue(result);
        }

        private void RunExampleFunctionTest(string fileName, string functionName)
        {
            sqlHelper.ExecuteSqlFile(fileName);
            bool result = sqlHelper.ExecuteFunctionTest(functionName);
            Assert.IsTrue(result);
        }

        [TestMethod]
        public void TestCheckConnection()
        {
            var reader = sqlHelper.ExecuteSqlCode("SELECT 1;");
            if (reader != null)
            {
                reader.Close();
            }
            Assert.IsNotNull(reader);
        }

        [TestMethod]
        public void TestExampleScalarProcedure()
        {
            RunExampleProcedureTest("example_test_procedures.sql", "test_example_scalar_procedure");
        }

        [TestMethod]
        public void TestExampleListProcedure()
        {
            RunExampleProcedureTest("example_test_procedures.sql", "test_example_list_procedure");
        }

        [TestMethod]
        public void TestExampleMultiProcedure()
        {
            RunExampleProcedureTest("example_test_procedures.sql", "test_example_multi_procedure");
        }

        [TestMethod]
        public void TestExampleScalarFunction()
        {
            RunExampleFunctionTest("example_test_functions.sql", "test_example_scalar_function");
        }

        [TestMethod]
        public void TestExampleListFunction()
        {
            RunExampleFunctionTest("example_test_functions.sql", "test_example_list_function");
        }

        [TestMethod]
        public void TestExampleMultiFunction()
        {
            RunExampleFunctionTest("example_test_functions.sql", "test_example_multi_function");
        }

        [TestMethod]
        public void TestCountTablesInDatabase()
        {
            Assert.IsTrue(sqlHelper.ExecuteFunctionTest("test_count_tables_in_database"));
        }

        [TestMethod]
        public void TestMoviesNotForAdult()
        {
            Assert.IsTrue(sqlHelper.ExecuteFunctionTest("test_movies_not_for_adults"));
        }

        [TestMethod]
        public void TestEmployeeEarnPerMonth()
        {
            Assert.IsTrue(sqlHelper.ExecuteFunctionTest("test_employee_earn_per_month"));
        }

        [TestMethod]
        public void TestEarnPerMonth()
        {
            Assert.IsTrue(sqlHelper.ExecuteFunctionTest("test_earn_per_month"));
        }

        [TestMethod]
        public void TestEmployeeWithSalesMoney()
        {
            Assert.IsTrue(sqlHelper.ExecuteFunctionTest("test_employee_with_sales_money"));
        }

        [TestMethod]
        public void TestGetProductsUnderPrice()
        {
            Assert.IsTrue(sqlHelper.ExecuteProcedureTest("test_get_products_under_price"));
        }

        [TestMethod]
        public void TestGetEmployeeBirthdayInMonth()
        {
            Assert.IsTrue(sqlHelper.ExecuteProcedureTest("test_get_employee_birthday_in_month"));
        }

        [TestMethod]
        public void TestGetFoodThatNeedCooling()
        {
            Assert.IsTrue(sqlHelper.ExecuteProcedureTest("test_get_food_that_need_cooling"));
        }

        [TestMethod]
        public void TestGetMoviesScreenInTheater()
        {
            Assert.IsTrue(sqlHelper.ExecuteProcedureTest("test_get_movies_screen_in_theater"));
        }

        [TestMethod]
        public void TestGetTicketsSoldInScreen()
        {
            Assert.IsTrue(sqlHelper.ExecuteProcedureTest("test_get_tickets_sold_in_screen"));
        }

        [TestMethod]
        public void TestGetEmployeeWithMostProducts()
        {
            Assert.IsTrue(sqlHelper.ExecuteProcedureTest("test_get_employee_with_most_products"));
        }

        [TestMethod]
        public void TestGetEmployeeEarnedMostMoney()
        {
            Assert.IsTrue(sqlHelper.ExecuteProcedureTest("test_get_employee_earned_most_money"));
        }

        [TestMethod]
        public void TestEmployeeWithAmountProducts()
        {
            Assert.IsTrue(sqlHelper.ExecuteFunctionTest("test_employee_with_amount_products"));
        }

        [TestMethod]
        public void TestGetMoneyEarnedInMonth()
        {
            Assert.IsTrue(sqlHelper.ExecuteFunctionTest("test_get_money_earned_in_month"));
        }

        [TestMethod]
        public void TestGetMoneyEarnedInYear()
        {
            Assert.IsTrue(sqlHelper.ExecuteFunctionTest("test_get_money_earned_in_year"));
        }

        [TestMethod]
        public void TestVipMoviesWithFreeSeats()
        {
            Assert.IsTrue(sqlHelper.ExecuteFunctionTest("test_vip_movies_with_free_seats"));
        }

        [TestMethod]
        public void TestRemoveScreenIfNoTickets()
        {
            Assert.IsTrue(sqlHelper.ExecuteProcedureTest("test_remove_screen_if_no_tickets"));
        }

        [TestMethod]
        public void TestUpdateManagerToDepartment()
        {
            Assert.IsTrue(sqlHelper.ExecuteProcedureTest("test_update_manager_to_department"));
        }

        [TestMethod]
        public void TestDeleteUselessEmployees()
        {
            Assert.IsTrue(sqlHelper.ExecuteProcedureTest("test_delete_useless_employees"));
        }

        protected virtual void Dispose(bool disposing)
        {
            if (disposing)
            {
                sqlHelper.Dispose();
            }
        }

        public void Dispose()
        {
            Dispose(true);
            GC.SuppressFinalize(this);
        }
    }
}
