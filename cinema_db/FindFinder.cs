namespace cinemaDB
{
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
