using Google.Protobuf;
using MySql.Data.MySqlClient;
using nsGenericClass;
using System;
using System.Collections.Generic;
using System.Collections.ObjectModel;
using System.Data;
using System.Globalization;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using System.Windows;
using System.Windows.Controls;
using System.Windows.Data;
using System.Windows.Documents;
using System.Windows.Input;
using System.Windows.Media;
using System.Windows.Media.Imaging;
using System.Windows.Shapes;

namespace PF.sub_windows
{
    public partial class BuyWin : Window
    {
        #region binding
        //for movie details text box.
        public string movie_of_today
        {
            get { return (string)GetValue(NameProperty); }
            set { SetValue(NameProperty, value); }
        }
        public static readonly DependencyProperty NameProperty =
        DependencyProperty.Register("movie_of_today", typeof(string), typeof(BuyWin));
        //for seats list box
        public ObservableCollection<GenericClass> seats
        {
            get { return (ObservableCollection<GenericClass>)GetValue(seatsProperty); }
            set { SetValue(seatsProperty, value); }
        }
        public static readonly DependencyProperty seatsProperty =
                DependencyProperty.Register("seats", typeof(ObservableCollection<GenericClass>), typeof(BuyWin));
        //for food list box
        public ObservableCollection<GenericClass> food
        {
            get { return (ObservableCollection<GenericClass>)GetValue(foodProperty); }
            set { SetValue(foodProperty, value); }
        }
        public static readonly DependencyProperty foodProperty =
                DependencyProperty.Register("food", typeof(ObservableCollection<GenericClass>), typeof(BuyWin));
        #endregion
        #region variables
        string choosenSeat = "";
        string choosenFood = "";
        #endregion
        MySqlConnection connection;
        public BuyWin(GenericClass movie, ref MySqlConnection _connection)
        {
            InitializeComponent();
            connection = _connection;
            string query = " SELECT * FROM ticket WHERE ticket.id NOT IN (SELECT sell.ticket_id FROM sell WHERE ticket_id IS NOT  NULL );";
            List<GenericClass> tickets = new List<GenericClass>();
            List<GenericClass> foodlist = new List<GenericClass>();
            #region init all seats.
            using (MySqlCommand command = new MySqlCommand(query, connection))
            {
                if (connection.State==ConnectionState.Closed)
                {
                    connection.Open();
                }
                using (MySqlDataReader reader = command.ExecuteReader())
                {
                    while (reader.Read())
                    {
                        GenericClass row = new GenericClass();

                        // Map the column values from the reader to the properties of YourModelClass
                        row.addValue("ID: " + reader.GetString(0));
                        row.addValue("Product id: " + reader.GetString(1));
                        row.addValue("Seat Number: " + reader.GetString(2));
                        row.addValue("Screen Time: " + reader.GetString(3));
                        row.addValue("Room Number: " + reader.GetString(4));
                        row.addValue("--------------------");
                        tickets.Add(row);
                    }

                    // 'tableData' list now contains the content of the table
                }
            }
            #endregion
            #region init all food.
            query = "SELECT product.id, product_name, product.price FROM food INNER JOIN product ON food.id = product.id";

            using (MySqlCommand command = new MySqlCommand(query, connection))
            {
                using (MySqlDataReader reader = command.ExecuteReader())
                {
                    while (reader.Read())
                    {
                        GenericClass row = new GenericClass();

                        // Map the column values from the reader to the properties of YourModelClass
                        row.addValue("ID: " + reader.GetString(0));
                        row.addValue("Name " + reader.GetString(1));
                        row.addValue("Price: " + reader.GetString(2) + "$");
                        row.addValue("--------------------");
                        foodlist.Add(row);
                    }

                    // 'tableData' list now contains the content of the table
                }
            }
            #endregion
            food = new ObservableCollection<GenericClass>(foodlist);
            seats = new ObservableCollection<GenericClass>(tickets);
            #region init movie details
            try
            {
                // Create the MySqlCommand object to execute the stored procedure
                MySqlCommand command = new MySqlCommand("get_movie_by_id", connection);
                command.CommandType = CommandType.StoredProcedure;

                // Add input parameter for the date
                command.Parameters.AddWithValue("@param_id", Int32.Parse(movie.ToString()[4..6].ToString()));

                // Execute the stored procedure
                command.ExecuteNonQuery();

                // Create a new MySqlCommand object to retrieve the result from the temporary table
                MySqlCommand selectCommand = new MySqlCommand("SELECT * FROM temporary_table_movie", connection);

                // Execute the select query and retrieve the data into a DataTable
                DataTable resultTable = new DataTable();
                using (MySqlDataAdapter adapter = new MySqlDataAdapter(selectCommand))
                {
                    adapter.Fill(resultTable);
                }
                foreach (DataRow row in resultTable.Rows)
                {
                    GenericClass tmp = new GenericClass();
                    tmp.addValue("ID: " + row["id"].ToString());
                    tmp.addValue("Movie Name: " + row["movie_name"].ToString());
                    tmp.addValue("Rating: " + row["rating"].ToString());
                    tmp.addValue("Duration: " + row["duration_in_minutes"].ToString()+" min.");
                    tmp.addValue("Screen Time: " + row["screen_time"].ToString());
                    tmp.addValue("Theater number: " + row["room_number"].ToString());
                    tmp.addValue("--------------------");
                    movie_of_today = tmp.ToString();
                }
            }
            catch (Exception ex)
            {
                // Handle any exceptions
                MessageBox.Show("Error: " + ex.Message);
            }
            #endregion
        }

        private void BuyTicket_Click(object sender, RoutedEventArgs e)
        {
            if (choosenSeat != "")
            {
                string procedureName = "add_sell";
                int cid = 0, eid = 0, tid = 0;
                DateTime dateofbirth = new DateTime();
                DateTime.TryParseExact(dobbox.Text, "yyyy-MM-dd", CultureInfo.InvariantCulture, DateTimeStyles.None, out dateofbirth);
                cid = int.Parse(customeridbox.Text);
                eid = int.Parse(employeeidbox.Text);
                tid= int.Parse(choosenSeat[4..6]);
                using (MySqlCommand command = new MySqlCommand(procedureName, connection))
                {
                    command.CommandType = CommandType.StoredProcedure;

                    // Set the parameter values
                    command.Parameters.AddWithValue("@param_customer_id", cid);
                    command.Parameters.AddWithValue("@param_customer_name", namebox.Text);
                    command.Parameters.AddWithValue("@param_date_of_birth", dateofbirth.Date);
                    command.Parameters.AddWithValue("@param_employee_id", eid);
                    command.Parameters.AddWithValue("@param_product_id", int.Parse(choosenSeat[18..21]));
                    command.Parameters.AddWithValue("@param_ticket_id", tid);

                    // Add output parameter for "succeed"
                    command.Parameters.Add(new MySqlParameter("@succeed", MySqlDbType.Bit));
                    command.Parameters["@succeed"].Direction = ParameterDirection.Output;

                    // Execute the stored procedure
                    command.ExecuteNonQuery();

                    // Get the value of "succeed" output parameter
                    UInt64 succeedValue = (UInt64)command.Parameters["@succeed"].Value;
                    bool succeed = Convert.ToBoolean(succeedValue);
                    if (succeed)
                    {
                        MessageBox.Show("Accepted Transaction!");
                    }
                    else
                    {
                        MessageBox.Show("Something went wrong!");
                    }
                }
            }
            else
            {
                MessageBox.Show("How about you choose one ticket!");
            }
        }

        private void BuyFood_Click(object sender, RoutedEventArgs e)
        {
            if (choosenFood != "")
            {
                string procedureName = "add_sell";
                int cid = 0, eid = 0, tid = 0;
                DateTime dateofbirth = new DateTime();
                DateTime.TryParseExact(dobbox.Text, "yyyy-MM-dd", CultureInfo.InvariantCulture, DateTimeStyles.None, out dateofbirth);
                cid=int.Parse(customeridbox.Text);
                eid = int.Parse(employeeidbox.Text);
                tid = -1;
                using (MySqlCommand command = new MySqlCommand(procedureName, connection))
                {
                    command.CommandType = CommandType.StoredProcedure;

                    // Set the parameter values
                    command.Parameters.AddWithValue("@param_customer_id", cid);
                    command.Parameters.AddWithValue("@param_customer_name", namebox.Text);
                    command.Parameters.AddWithValue("@param_date_of_birth", dateofbirth.Date);
                    command.Parameters.AddWithValue("@param_employee_id", eid);
                    command.Parameters.AddWithValue("@param_product_id", int.Parse(choosenFood[4..6]));
                    command.Parameters.AddWithValue("@param_ticket_id", tid);

                    // Add output parameter for "succeed"
                    command.Parameters.Add(new MySqlParameter("@succeed", MySqlDbType.Bit));
                    command.Parameters["@succeed"].Direction = ParameterDirection.Output;

                    // Execute the stored procedure
                    command.ExecuteNonQuery();

                    // Get the value of "succeed" output parameter
                    UInt64 succeedValue = (UInt64)command.Parameters["@succeed"].Value;
                    bool succeed = Convert.ToBoolean(succeedValue);
                    if (succeed)
                    {
                        MessageBox.Show("Accepted Transaction!");
                    }
                    else
                    {
                        MessageBox.Show("Something wen wrong!");
                    }
                }
            }
            else
            {
                MessageBox.Show("How about you choose some food!");
            }
        }

        private void Food_SelectionChanged(object sender, SelectionChangedEventArgs e)
        {
            choosenFood = ((ListBox)sender).SelectedItem.ToString();
        }

        private void Available_seats_SelectionChanged(object sender, SelectionChangedEventArgs e)
        {
            choosenSeat = ((GenericClass)((ListBox)sender).SelectedItem).ToString();
        }

    }
}
