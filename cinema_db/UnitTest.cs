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
            sqlHelper.ExecuteSqlFile("data.sql");
            sqlHelper.ExecuteSqlFile("procedures.sql");
            sqlHelper.ExecuteSqlFile("test_procedures.sql");
        }

        [TestCleanup]
        public void TearDown()
        {
            sqlHelper.CloseDatabaseConnection();
        }

        private void RunTest(string fileName, string procedureName)
        {
            sqlHelper.ExecuteSqlFile(fileName);
            bool result = sqlHelper.ExecuteProcedureTest(procedureName);
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
            RunTest("example_test_procedures.sql", "test_example_scalar_procedure");
        }

        [TestMethod]
        public void TestExampleListProcedure()
        {
            RunTest("example_test_procedures.sql", "test_example_list_procedure");
        }

        [TestMethod]
        public void TestExampleMultiProcedure()
        {
            RunTest("example_test_procedures.sql", "test_example_multi_procedure");
        }

        [TestMethod]
        public void TestCountTablesInDatabase()
        {
            Assert.IsTrue(sqlHelper.ExecuteProcedureTest("test_count_tables_in_database"));
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
