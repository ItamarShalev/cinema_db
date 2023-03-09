using System.Data;
using System.Globalization;
using MySql.Data.MySqlClient;

#pragma warning disable CA2100

namespace cinemaDB
{
    public class SqlHelper: IDisposable
    {
        private MySqlConnection? connection;

        public static string GetMySqlConnectionString(string host, string username, string password)
        {
            string connectionString = $"server={host};user={username};password={password};";
            return connectionString;
        }

        public void OpenDatabaseConnection(string connectionString)
        {
            connection = new MySqlConnection(connectionString);
            connection.Open();
        }

        public void CloseDatabaseConnection()
        {
            if (connection != null && connection.State == ConnectionState.Open)
            {
                connection.Close();
                connection.Dispose();
                connection = null;
            }
        }

        public bool ExecuteProcedureTest(string procedureName)
        {
            bool result = false;
            string activeProcedureTestName = $"CALL {procedureName}();";
            var reader = ExecuteSqlCode(activeProcedureTestName);
            if (reader != null)
            {
                do
                {
                    if (reader.HasRows && reader.FieldCount > 0 && reader.GetName(0) == "test_result")
                    {
                        if (reader.Read())
                        {
                            int intResult = Convert.ToInt32(reader["test_result"], CultureInfo.CurrentCulture);
                            result = intResult == 1;
                            break;
                        }
                    }
                } while (reader.NextResult());

                reader.Close();
            }
            return result;
        }

        public MySqlDataReader ExecuteSqlCode(string sqlCode)
        {
            if (string.IsNullOrEmpty(sqlCode))
            {
                throw new ArgumentException("Sql code cannot be empty or null");
            }

            using (var command = new MySqlCommand(sqlCode, connection))
            {
                return command.ExecuteReader();
            }
        }

        public void ExecuteSqlFile(string fileName)
        {
            string filePath = FileFinder.FindSqlFile(fileName);
            Console.WriteLine(filePath);   

            if (string.IsNullOrEmpty(filePath))
            {
                throw new ArgumentException("File name cannot be empty or null");
            }

            string sqlCode = File.ReadAllText(filePath);
            var reader = ExecuteSqlCode(sqlCode);
            reader.Close();
        }

        protected virtual void Dispose(bool disposing)
        {
            if (disposing)
            {
                CloseDatabaseConnection();
            }
        }

        public void Dispose()
        {
            Dispose(true);
            GC.SuppressFinalize(this);
        }
    }
}

