using System.Data;
using System.Globalization;
using System.Data;
using System.Globalization;
using MySql.Data.MySqlClient;

#pragma warning disable CA2100
namespace nsGenericClass
{
    /// <summary>
    /// this calss would serve us when we want to print different types of objects from our data base,
    /// instead of creating a unique DAL object for each of our data base objects we simply would add 
    /// a string representing its name and value, e.g addValues("ID:".conact(workerID))
    /// </summary>
    public class GenericClass
    {
        List<string?> list=new List<string?>();

        public GenericClass addValue(string val)
        {
            list.Add(val);
            return this;
        }
        public override string ToString()
        {
            return string.Join("\n",list.Where(x => x != null));
        }
    }

    public class SqlHelper : IDisposable
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

    public static class FileFinder
    {
        public static readonly string sqlDirectory = Path.Combine(FindSlnDirectoryLocation(), "sql");

        public static string FindSlnDirectoryLocation()
        {
            string? currentDirectory = Directory.GetCurrentDirectory();
            string? solutionDirectory = null;
            while (currentDirectory != null)
            {
                string[] solutionFiles = Directory.GetFiles(currentDirectory, "*.sln");
                if (solutionFiles.Length > 0)
                {
                    solutionDirectory = Path.GetDirectoryName(solutionFiles[0]);
                    break;
                }
                currentDirectory = Directory.GetParent(currentDirectory)?.FullName;
            }
            if (solutionDirectory == null)
            {
                throw new DirectoryNotFoundException("Directory of sln file doesn't found.");
            }
            return solutionDirectory;
        }

        public static string FindSqlFile(string sqlFile)
        {
            return FindFile(sqlDirectory, sqlFile);
        }

        public static string FindFile(string directoryPath, string fileName)
        {
            if (!Directory.Exists(directoryPath))
            {
                throw new DirectoryNotFoundException("Directory not found: " + directoryPath);
            }

            var files = Directory.GetFiles(directoryPath, fileName, SearchOption.AllDirectories);

            if (files.Length == 0)
            {
                throw new FileNotFoundException("File not found: " + fileName);
            }

            if (files.Length > 1)
            {
                throw new FileNotFoundException("Duplicate file name found and can't decide which is the correct: " + fileName);
            }

            return files[0];

        }
    }

}