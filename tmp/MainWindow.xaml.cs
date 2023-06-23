using System;
using System.Collections.Generic;
using System.Collections.ObjectModel;
using System.Data;
using System.IO;
using System.Linq;
using System.Reflection.PortableExecutable;
using System.Text;
using System.Threading.Tasks;
using System.Windows;
using System.Windows.Controls;
using System.Windows.Data;
using System.Windows.Documents;
using System.Windows.Input;
using System.Windows.Media;
using System.Windows.Media.Imaging;
using System.Windows.Navigation;
using System.Windows.Shapes;
using Google.Protobuf.WellKnownTypes;
using MySql.Data.MySqlClient;
using nsGenericClass;
using PF.sub_windows;

namespace PF
{
    /// <summary>
    /// Interaction logic for MainWindow.xaml
    /// </summary>
    public partial class MainWindow : Window
    {
        #region data binding
        public ObservableCollection<GenericClass> movies_of_today
        {
            get { return (ObservableCollection<GenericClass>)GetValue(moviesProperty); }
            set { SetValue(moviesProperty, value); }
        }
        public static readonly DependencyProperty moviesProperty =
                DependencyProperty.Register("movies_of_today", typeof(ObservableCollection<GenericClass>), typeof(MainWindow));

        public ObservableCollection<GenericClass> allmovies
        {
            get { return (ObservableCollection<GenericClass>)GetValue(allmoviesProperty); }
            set { SetValue(allmoviesProperty, value); }
        }
        public static readonly DependencyProperty allmoviesProperty =
                DependencyProperty.Register("allmovies", typeof(ObservableCollection<GenericClass>), typeof(MainWindow));
        #endregion
        MySqlConnection connection;
        public MainWindow()
        {
            InitializeComponent();
            string password = ""; //Enter your local host password here!
            string connectionString = "server=localhost;user=admin;database=db_cinema;port=3306;password="+password;
            //MySqlConnection connection = new MySqlConnection(connectionString);
            connection = new MySqlConnection(connectionString);
            connection.Open();
            MessageBox.Show("connecion established");
            string query = "SELECT * FROM movie;";
            List<GenericClass> allMoviesTable = new List<GenericClass>();
            List<GenericClass> moviesOfToday = new List<GenericClass>();
            #region init all movies.
            using (MySqlCommand command = new MySqlCommand(query, connection))
            {
                using (MySqlDataReader reader = command.ExecuteReader())
                {
                    while (reader.Read())
                    {
                        GenericClass row = new GenericClass();

                        // Map the column values from the reader to the properties of YourModelClass
                        row.addValue("ID: " + reader.GetString(0));
                        row.addValue("Name: " + reader.GetString(1));
                        row.addValue("Rating: " + reader.GetString(2));
                        row.addValue("duration: " + reader.GetString(3));
                        row.addValue("--------------------");
                        allMoviesTable.Add(row);
                    }

                    // 'tableData' list now contains the content of the table
                }
            }
            #endregion
            #region init todays movies.
            using (connection = new MySqlConnection(connectionString))
            {
                try
                {
                    connection.Open();

                    // Create the MySqlCommand object to execute the stored procedure
                    MySqlCommand command = new MySqlCommand("movies_of_date", connection);
                    command.CommandType = CommandType.StoredProcedure;

                    // Add input parameter for the date
                    command.Parameters.AddWithValue("@param_date", new DateTime(2023,03,10));

                    // Execute the stored procedure
                    command.ExecuteNonQuery();

                    // Create a new MySqlCommand object to retrieve the result from the temporary table
                    MySqlCommand selectCommand = new MySqlCommand("SELECT * FROM temporary_table_movies_of_today", connection);

                    // Execute the select query and retrieve the data into a DataTable
                    DataTable resultTable = new DataTable();
                    using (MySqlDataAdapter adapter = new MySqlDataAdapter(selectCommand))
                    {
                        adapter.Fill(resultTable);
                    }
                    foreach (DataRow  row in resultTable.Rows)
                    {
                        GenericClass tmp=new GenericClass();
                        tmp.addValue("ID: " + row["id"].ToString()+" ");
                        tmp.addValue("Movie Name: " + (string)row["movie_name"]);
                        tmp.addValue("Screen Time: " + row["screen_time"].ToString());
                        tmp.addValue("--------------------");
                        moviesOfToday.Add(tmp);
                    }
                }
                catch (Exception ex)
                {
                    // Handle any exceptions
                    Console.WriteLine("Error: " + ex.Message);
                }
            }
            #endregion
            allmovies = new ObservableCollection<GenericClass>(allMoviesTable);
            movies_of_today = new ObservableCollection<GenericClass>(moviesOfToday);
        }

        /// <summary>
        /// buuuton click for admin buttomn to go to workers window.
        /// </summary>
        /// <param name="sender"></param>
        /// <param name="e"></param>
        private void Admin_Click(object sender, RoutedEventArgs e)
        {
            //TODO: send database object as argument.
            WorkersWin workerwindow = new WorkersWin(ref connection);
            workerwindow.ShowDialog();
        }

        private void Movies_of_today_DoubleClick(object sender, MouseButtonEventArgs e)
        {
            //TODO: create an object for printing all object members of data base.

            GenericClass p = (GenericClass)(((ListView)sender).SelectedItem);
            if (p == null)
            {
                return;
            }
            else
            {
                BuyWin buywin = new BuyWin(p, ref connection);
                buywin.ShowDialog();
            }

        }
    }
}
