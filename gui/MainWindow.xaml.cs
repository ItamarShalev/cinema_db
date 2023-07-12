using System;
using System.Collections.Generic;
using System.Collections.ObjectModel;
using System.Windows;
using System.Windows.Controls;
using System.Windows.Input;
using cinemaDB;
using gui.sub_windows;
using MySql.Data.MySqlClient;

namespace gui
{
    /// <summary>
    /// Interaction logic for MainWindow.xaml
    /// </summary>
    public partial class MainWindow : Window
    {
        #region data binding

        public ObservableCollection<GenericClass> moviesOfToday
        {
            get { return (ObservableCollection<GenericClass>)GetValue(moviesProperty); }
            set { SetValue(moviesProperty, value); }
        }

        public static readonly DependencyProperty moviesProperty = DependencyProperty.Register("moviesOfToday", typeof(ObservableCollection<GenericClass>), typeof(MainWindow));

        public ObservableCollection<GenericClass> allMovies
        {
            get { return (ObservableCollection<GenericClass>)GetValue(allmoviesProperty); }
            set { SetValue(allmoviesProperty, value); }
        }

        public static readonly DependencyProperty allmoviesProperty = DependencyProperty.Register("allMovies", typeof(ObservableCollection<GenericClass>), typeof(MainWindow));
        #endregion

        private SqlHelper sqlHelper;


        public MainWindow()
        {
            InitializeComponent();
            sqlHelper = new SqlHelper();
            string connectionString = SqlHelper.GetConnectionFromSecretFile("db_cinema");
            try
            {
                sqlHelper.OpenDatabaseConnection(connectionString);
                MessageBox.Show("Connecion established.");

            }catch(Exception)
            {
                /* First database creation. */
                connectionString = SqlHelper.GetConnectionFromSecretFile(null);
                sqlHelper.OpenDatabaseConnection(connectionString);
                sqlHelper.InitDatabaseAndLoadSqlFiles();
                sqlHelper.CloseDatabaseConnection();
                connectionString = SqlHelper.GetConnectionFromSecretFile("db_cinema");
                sqlHelper.OpenDatabaseConnection(connectionString);
                MessageBox.Show("Connecion established.");
            }


            try
            {
                InitAllMoviesList();
                InitTodayMovies();
            }
            catch (Exception exception)
            {
                string error = $"Error: {exception.Message}";
                Console.WriteLine(error);
                MessageBox.Show(error);
            }

        }

        private void InitTodayMovies()
        {
            List<GenericClass> moviesOfTodayList = new List<GenericClass>();
            string procedureName = "movies_of_date";

            Dictionary<string, object> parameters = new Dictionary<string, object>
                {
                    { "param_date", new DateTime(2023, 03, 10) }
                };

            using (MySqlDataReader reader = sqlHelper.ExecuteSelectProcedure(procedureName, parameters))
            {
                while (reader.Read()) 
                {
                    GenericClass movieData = new GenericClass();
                    movieData.addItem("ID", reader.GetString(0));
                    movieData.addItem("Movie Name", reader.GetString(1));
                    movieData.addItem("Screen Time", reader.GetString(2));
                    moviesOfTodayList.Add(movieData);
                }
            }
            moviesOfToday = new ObservableCollection<GenericClass>(moviesOfTodayList);
        }

        private void InitAllMoviesList()
        {
            List<GenericClass> allMoviesTable = new List<GenericClass>();
            using (MySqlDataReader reader = sqlHelper.ExecuteSqlCode("SELECT * FROM movie ORDER BY movie_name;"))
            {
                while (reader.Read())
                {
                    GenericClass row = new GenericClass();

                    /* Map the column values from the reader to the properties of YourModelClass. */
                    row.addItem("ID", reader.GetString(0));
                    row.addItem("Name", reader.GetString(1));
                    row.addItem("Rating", reader.GetString(2));
                    row.addItem("duration", reader.GetString(3));
                    allMoviesTable.Add(row);
                }
                /* The list 'tableData' is now contains the content of the table. */
            }
            allMovies = new ObservableCollection<GenericClass>(allMoviesTable);
        }

        private void AdminClick(object sender, RoutedEventArgs routedEvent)
        {
            AdminWindow adminWindow = new AdminWindow(ref sqlHelper);
            adminWindow.ShowDialog();
        }

        private void MoviesOfTodayDoubleClick(object sender, MouseButtonEventArgs buttonEvent)
        {
            GenericClass dataItem = (GenericClass)(((ListView)sender).SelectedItem);
            if (dataItem == null)
            {
                return;
            }

            BuyWindow buyWindow = new BuyWindow(dataItem, ref sqlHelper);
            buyWindow.ShowDialog();

        }
    }
}
