using System.Data;
using System.Globalization;
using MySql.Data.MySqlClient;

#pragma warning disable CA2100, CA1303

namespace cinemaDB
{
    public class SqlHelper : IDisposable
    {
        private MySqlConnection? connection;
        private const string secret_file_name = "secret_mysql_login.txt";

        public static string GetConnectionFromSecretFile(string? databaseName)
        {
            string[]? lines = null;

            /* Read the server details using Github secrets */
            string fullSecretFileLocation = FileFinder.FindFile(FileFinder.FindSqlParentDirectoryLocation(), secret_file_name);
            if (string.IsNullOrEmpty(fullSecretFileLocation))
            {
                Console.WriteLine(secret_file_name + " file is missing.");
                Console.WriteLine("The file should contain the user name and the password.");
                Console.WriteLine("The pattern is: '<ip>,<user_name>,<password>' for example: 0.0.0.0,admin,admin123.");
                return "";
            }
            using (var streamReader = File.OpenText(fullSecretFileLocation))
            {
                lines = streamReader.ReadToEnd().Split(",".ToCharArray(), StringSplitOptions.RemoveEmptyEntries);
            }
            if (lines == null || lines.Length != 3)
            {
                throw new FormatException("The secret file should contain the user name and the password, separated by commas. " +
                                          "The pattern is: '<ip>,<user_name>,<password>' for example: 0.0.0.0,admin,admin123.");
            }
            return GetMySqlConnectionString(host: lines![0], username: lines![1], password: lines![2], databaseName);
        }

        public static string GetMySqlConnectionString(string host, string username, string password, string? databaseName)
        {
            string databaseString = string.IsNullOrEmpty(databaseName) ? string.Empty : $"database={databaseName};";
            string connectionString = $"server={host};user={username};{databaseString}password={password};";
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

        public void InitDatabaseAndLoadSqlFiles()
        {
            var reader = ExecuteSqlCode("DROP DATABASE IF EXISTS db_cinema;");
            reader.Close();
            ExecuteSqlFile("scheme.sql");
            ExecuteSqlFile("views.sql");
            ExecuteSqlFile("data.sql");
            ExecuteSqlFile("additional_data.sql");
            ExecuteSqlFile("procedures.sql");
            ExecuteSqlFile("functions.sql");
        }

        public bool ExecuteFunctionTest(string functionName)
        {
            bool result = false;
            string activeFunctionTestName = $"SELECT {functionName}() AS test_result;";
            var reader = ExecuteSqlCode(activeFunctionTestName);
            if (reader != null)
            {
                if (reader.HasRows && reader.FieldCount > 0 && reader.GetName(0) == "test_result")
                {
                    if (reader.Read())
                    {
                        int intResult = Convert.ToInt32(reader["test_result"], CultureInfo.CurrentCulture);
                        result = intResult == 1;
                    }
                }
                reader.Close();
            }
            return result;
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

