using MySql.Data.MySqlClient;
using nsGenericClass;
using System;
using System.Collections.Generic;
using System.Collections.ObjectModel;
using System.Text.RegularExpressions;
using System.Data;
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
    /// <summary>
    /// Interaction logic for worker.xaml
    /// </summary>
    public partial class Worker : Window
    {
        public string worker
        {
            get { return (string)GetValue(workerProperty); }
            set { SetValue(workerProperty, value); }
        }
        public static readonly DependencyProperty workerProperty =
        DependencyProperty.Register("worker", typeof(string), typeof(Worker));

        MySqlConnection connection;
        GenericClass employee=new GenericClass();
        public Worker(GenericClass p, ref MySqlConnection _connection)
        {
            InitializeComponent();
            connection = _connection;
            try
            {
                // Create the MySqlCommand object to execute the stored procedure
                MySqlCommand command = new MySqlCommand("get_employee", connection);
                command.CommandType = CommandType.StoredProcedure;

                // Add input parameter for the date
                int id = 0;
                Int32.TryParse(Regex.Match(p.ToString(), @"ID: (\d+)").Groups[1].Value, out id);
                command.Parameters.AddWithValue("@employee_id", id);

                // Execute the stored procedure
                command.ExecuteNonQuery();

                using (MySqlDataReader reader = command.ExecuteReader())
                {
                    // Process the retrieved data
                    while (reader.Read())
                    {
                        employee.addValue("ID: "+reader.GetString(0));
                        employee.addValue("First name: "+reader.GetString(1));
                        employee.addValue("Last Name: " + reader.GetString(2));
                        employee.addValue("Date Of Birth: " + reader.GetString(3));
                        employee.addValue("Department NO.: " + reader.GetString(4));
                        employee.addValue("Still Active?: " + reader.GetString(5));
                        employee.addValue("Date Of Hiring: " + reader.GetString(6));
                        employee.addValue("Salary: " + reader.GetString(7));
                        employee.addValue("Rating: " + reader.GetString(8));
                    }
                }
            }
            catch (Exception ex)
            {
                // Handle any exceptions
                MessageBox.Show("Error: " + ex.Message);
            }
            worker = employee.ToString();
        }

        private void Button_Click(object sender, RoutedEventArgs e)
        {
            try
            {
                // Create the MySqlCommand object to execute the stored procedure
                MySqlCommand command = new MySqlCommand("delete_employee", connection);
                command.CommandType = CommandType.StoredProcedure;

                // Add input parameter for the date
                command.Parameters.AddWithValue("@param_id", int.Parse(worker[3..6]));
                
                // Add output parameter for "succeed"
                command.Parameters.Add(new MySqlParameter("@succeed", MySqlDbType.Bit));
                command.Parameters["@succeed"].Direction = ParameterDirection.Output;

                // Execute the stored procedure
                command.ExecuteNonQuery();

                // Get the value of "succeed" output parameter
                UInt64 succeedValue = (UInt64)command.Parameters["@succeed"].Value;
                bool succeed = (int)succeedValue != 0;
                if (succeed)
                {
                    MessageBox.Show("Worker still active value set to 0.!");
                }
                else
                {
                    MessageBox.Show("Something went wrong!");
                }
                try
                {
                    employee = new GenericClass();
                    // Create the MySqlCommand object to execute the stored procedure
                    command = new MySqlCommand("get_employee", connection);
                    command.CommandType = CommandType.StoredProcedure;

                    // Add input parameter for the date
                    int id = 0;
                    Int32.TryParse((worker.ToString()[4..6]).ToString(), out id);
                    command.Parameters.AddWithValue("@employee_id", id);

                    // Execute the stored procedure
                    command.ExecuteNonQuery();

                    using (MySqlDataReader reader = command.ExecuteReader())
                    {
                        // Process the retrieved data
                        while (reader.Read())
                        {
                            employee.addValue("ID: " + reader.GetString(0));
                            employee.addValue("First name: " + reader.GetString(1));
                            employee.addValue("Last Name: " + reader.GetString(2));
                            employee.addValue("Date Of Birth: " + reader.GetString(3));
                            employee.addValue("Department NO.: " + reader.GetString(4));
                            employee.addValue("Still Active?: " + reader.GetString(5));
                            employee.addValue("Date Of Hiring: " + reader.GetString(6));
                            employee.addValue("Salary: " + reader.GetString(7));
                            employee.addValue("Rating: " + reader.GetString(8));
                        }
                    }
                }
                catch (Exception ex)
                {
                    // Handle any exceptions
                    MessageBox.Show("Error: " + ex.Message);
                }
                worker = employee.ToString();
            }
            catch (Exception ex)
            {
                // Handle any exceptions
                MessageBox.Show("Error: " + ex.Message);
            }
        }
    }
}
