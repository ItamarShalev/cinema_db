namespace cinemaDB
{
    public static class FileFinder
    {
        public static readonly string sqlDirectory = FindSqlDirectoryLocation();

        public static string FindSqlParentDirectoryLocation()
        {
            var parentDirectory = Directory.GetParent(sqlDirectory);
            return parentDirectory == null ? "": parentDirectory.FullName;
        }

        public static string FindSqlDirectoryLocation()
        {
            string? currentDirectory = Directory.GetCurrentDirectory();
            string directoryResult = "";

            while (currentDirectory != null)
            {
                string[] directories = Directory.GetDirectories(currentDirectory, "sql");
                if (directories.Length == 1)
                {
                    directoryResult = directories[0];
                    break;
                }
                currentDirectory = Directory.GetParent(currentDirectory)?.FullName;
            }
            if (string.IsNullOrEmpty(directoryResult))
            {
                throw new DirectoryNotFoundException("Directory of sql files doesn't found.");
            }
            return directoryResult;
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
