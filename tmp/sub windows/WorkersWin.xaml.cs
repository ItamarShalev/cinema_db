using MySql.Data.MySqlClient;
using nsGenericClass;
using System;
using System.Collections;
using System.Collections.Generic;
using System.Collections.ObjectModel;
using System.Data;
using System.Globalization;
using System.Linq;
using System.Security.Cryptography;
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
    /// Interaction logic for WorkersWin.xaml
    /// </summary>
    public partial class WorkersWin : Window
    {
        #region data binding
        public ObservableCollection<GenericClass> workers
        {
            get { return (ObservableCollection<GenericClass>)GetValue(workersProperty); }
            set { SetValue(workersProperty, value); }
        }
        public static readonly DependencyProperty workersProperty =
                DependencyProperty.Register("workers", typeof(ObservableCollection<GenericClass>), typeof(WorkersWin));
        public ObservableCollection<GenericClass> shifts
        {
            get { return (ObservableCollection<GenericClass>)GetValue(shiftsProperty); }
            set { SetValue(shiftsProperty, value); }
        }
        public static readonly DependencyProperty shiftsProperty =
                DependencyProperty.Register("shifts", typeof(ObservableCollection<GenericClass>), typeof(WorkersWin));
        #endregion
        MySqlConnection connection;
        public WorkersWin(ref MySqlConnection _connection)
        {
            InitializeComponent();
            connection = _connection;
            #region init workers lists
            List<GenericClass> workerslist = new List<GenericClass>();
            string query = "SELECT * FROM employee;";
            using (MySqlCommand command = new MySqlCommand(query, connection))
            {
                connection.Open();
                using (MySqlDataReader reader = command.ExecuteReader())
                {
                    while (reader.Read())
                    {
                        GenericClass row = new GenericClass();

                        // Map the column values from the reader to the properties of YourModelClass
                        row.addValue("ID: " + reader.GetString(0));
                        row.addValue("Name: " + reader.GetString(1) + " " + reader.GetString(2));
                        row.addValue("Department: " + reader.GetString(4));
                        row.addValue("--------------------");
                        workerslist.Add(row);
                    }

                    // 'tableData' list now contains the content of the table
                }
            }
            workers = new ObservableCollection<GenericClass>(workerslist);
            #endregion
            #region init shifts list
            List<GenericClass> shiftslist = new List<GenericClass>();
            query = "SELECT * FROM shift;";
            using (MySqlCommand command = new MySqlCommand(query, connection))
            {
                using (MySqlDataReader reader = command.ExecuteReader())
                {
                    while (reader.Read())
                    {
                        GenericClass row = new GenericClass();

                        // Map the column values from the reader to the properties of YourModelClass
                        row.addValue("ID: " + reader.GetString(0));
                        row.addValue("Date: " + reader.GetString(5));
                        row.addValue("Start: " + reader.GetString(1) + " End: " + reader.GetString(2));
                        row.addValue("Department: " + reader.GetString(3));
                        row.addValue("branch: " + reader.GetString(4));
                        row.addValue("--------------------");
                        shiftslist.Add(row);
                    }

                    // 'tableData' list now contains the content of the table
                }
            }
            shifts = new ObservableCollection<GenericClass>(shiftslist);
            #endregion
        }

        private void Workers_MouseDoubleClick(object sender, MouseButtonEventArgs e)
        {

            GenericClass p = (GenericClass)(((ListView)sender).SelectedItem);
            if (p == null)
            {
                return;
            }
            else
            {
                Worker worker = new Worker(p, ref connection);
                worker.ShowDialog();
                #region init workers lists
                List<GenericClass> workerslist = new List<GenericClass>();
                string query = "SELECT * FROM employee;";
                using (MySqlCommand command2 = new MySqlCommand(query, connection))
                {
                    using (MySqlDataReader reader = command2.ExecuteReader())
                    {
                        while (reader.Read())
                        {
                            GenericClass row = new GenericClass();

                            // Map the column values from the reader to the properties of YourModelClass
                            row.addValue("ID: " + reader.GetString(0));
                            row.addValue("Name: " + reader.GetString(1) + " " + reader.GetString(2));
                            row.addValue("Department: " + reader.GetString(4));
                            row.addValue("--------------------");
                            workerslist.Add(row);
                        }

                        // 'tableData' list now contains the content of the table
                    }
                }
                workers = new ObservableCollection<GenericClass>(workerslist);
                #endregion
            }
        }

        private void AddWorker_Button_Click(object sender, RoutedEventArgs e)
        {
            try
            {
                if (fname.Text != "" && lname.Text != "" && dob.Text != "" && depid.Text != "" && salary.Text != "")
                {
                    string procedureName = "add_employee";

                    DateTime dateofbirth = new DateTime();
                    DateTime.TryParseExact(dob.Text, "yyyy-MM-dd", CultureInfo.InvariantCulture, DateTimeStyles.None, out dateofbirth);

                    using (MySqlCommand command = new MySqlCommand(procedureName, connection))
                    {
                        command.CommandType = CommandType.StoredProcedure;

                        // Set the parameter values
                        command.Parameters.AddWithValue("@param_first_name", fname.Text);
                        command.Parameters.AddWithValue("@param_last_name", lname.Text);
                        command.Parameters.AddWithValue("@param_date_of_birth", dateofbirth.Date);
                        command.Parameters.AddWithValue("@param_department", int.Parse(depid.Text));
                        command.Parameters.AddWithValue("@param_date_of_hiring", DateTime.Now);
                        command.Parameters.AddWithValue("@param_salary", float.Parse(salary.Text));
                        command.Parameters.AddWithValue("@param_rating", 1);

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
                            MessageBox.Show("Worker was added to database!");
                        }
                        else
                        {
                            MessageBox.Show("unable to add worker to database!");
                        }
                        #region init workers lists
                        List<GenericClass> workerslist = new List<GenericClass>();
                        string query = "SELECT * FROM employee;";
                        using (MySqlCommand command2 = new MySqlCommand(query, connection))
                        {
                            using (MySqlDataReader reader = command2.ExecuteReader())
                            {
                                while (reader.Read())
                                {
                                    GenericClass row = new GenericClass();

                                    // Map the column values from the reader to the properties of YourModelClass
                                    row.addValue("ID: " + reader.GetString(0));
                                    row.addValue("Name: " + reader.GetString(1) + " " + reader.GetString(2));
                                    row.addValue("Department: " + reader.GetString(4));
                                    row.addValue("--------------------");
                                    workerslist.Add(row);
                                }

                                // 'tableData' list now contains the content of the table
                            }
                        }
                        workers = new ObservableCollection<GenericClass>(workerslist);
                        #endregion
                    }
                }
                else
                {
                    MessageBox.Show("One or more fields are missing!");
                }
            }
            catch (Exception)
            {
                MessageBox.Show("Something went wrong!");
            }

        }
    }
}
