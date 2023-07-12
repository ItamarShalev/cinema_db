using cinemaDB;
using MySql.Data.MySqlClient;
using System;
using System.Collections.Generic;
using System.Collections.ObjectModel;
using System.Globalization;
using System.Windows;
using System.Windows.Controls;
using System.Windows.Input;

namespace gui.sub_windows
{
    /// <summary>
    /// Interaction logic for AdminWindow.xaml
    /// </summary>
    public partial class AdminWindow : Window
    {
        #region data binding
        public ObservableCollection<GenericClass> workers
        {
            get { return (ObservableCollection<GenericClass>)GetValue(workersProperty); }
            set { SetValue(workersProperty, value); }
        }

        public static readonly DependencyProperty workersProperty = DependencyProperty.Register("workers", typeof(ObservableCollection<GenericClass>), typeof(AdminWindow));
        public ObservableCollection<GenericClass> shifts
        {
            get { return (ObservableCollection<GenericClass>)GetValue(shiftsProperty); }
            set { SetValue(shiftsProperty, value); }
        }

        public static readonly DependencyProperty shiftsProperty = DependencyProperty.Register("shifts", typeof(ObservableCollection<GenericClass>), typeof(AdminWindow));

        private SqlHelper sqlHelper;
        #endregion

        public AdminWindow(ref SqlHelper sqlHelper)
        {
            this.sqlHelper = sqlHelper;

            InitializeComponent();
            try
            {
                InitAllWorkersData();
                InitAllShiftsData();
            }
            catch(Exception exception)
            {
                string error = $"Error: {exception.Message}";
                Console.WriteLine(error);
                MessageBox.Show(error);
            }

        }

        private void InitAllShiftsData()
        {
            List<GenericClass> shiftslist = new List<GenericClass>();
            using (MySqlDataReader reader = sqlHelper.ExecuteSqlCode("SELECT * FROM shift;"))
            {
                while (reader.Read())
                {
                    GenericClass row = new GenericClass();

                    /* Map the column values from the reader to the properties of YourModelClass. */
                    row.addItem("ID", reader.GetString(0));
                    row.addItem("Date", reader.GetString(5));
                    row.addItem("Start", reader.GetString(1) + " End: " + reader.GetString(2));
                    row.addItem("Department", reader.GetString(3));
                    row.addItem("Branch", reader.GetString(4));
                    shiftslist.Add(row);
                }

                // The list 'tableData' is now contains the content of the table */
            }
            shifts = new ObservableCollection<GenericClass>(shiftslist);
        }

        private void InitAllWorkersData()
        {
            List<GenericClass> workerslist = new List<GenericClass>();

            using (MySqlDataReader reader = sqlHelper.ExecuteSqlCode("SELECT * FROM employee;"))
            {
                while (reader.Read())
                {
                    GenericClass row = new GenericClass();

                    /* Map the column values from the reader to the properties of YourModelClass. */
                    row.addItem("ID", reader.GetString(0));
                    row.addItem("Name", reader.GetString(1) + " " + reader.GetString(2));
                    row.addItem("Department", reader.GetString(4));
                    workerslist.Add(row);
                }

                /* The list 'tableData' is now contains the content of the table */
            }

            workers = new ObservableCollection<GenericClass>(workerslist);
        }

        private void WorkersMouseDoubleClick(object sender, MouseButtonEventArgs mouseButtonEvent)
        {

            GenericClass selectedData = (GenericClass)(((ListView)sender).SelectedItem);
            if (selectedData == null)
            {
                return;
            }

            WorkerWindow workerWindow = new WorkerWindow(selectedData, ref sqlHelper);
            workerWindow.ShowDialog();
            InitAllWorkersData();
        }

        private void AddWorkerButtonClick(object sender, RoutedEventArgs routedEvent)
        {
            try
            {
                if (firstName.Text == "" || lastName.Text == "" || dateOfBirth.Text == "" || departmentId.Text == "" || salary.Text == "")
                {
                    MessageBox.Show("One or more fields are missing!");
                    return;
                }

                string procedureName = "add_employee";

                DateTime dateValue = new DateTime();
                DateTime.TryParseExact(dateOfBirth.Text, "yyyy-MM-dd", CultureInfo.InvariantCulture, DateTimeStyles.None, out dateValue);

                Dictionary<string, object> parameters = new Dictionary<string, object>
                {
                    { "param_first_name", firstName.Text },
                    { "param_last_name", lastName.Text },
                    { "param_date_of_birth", dateValue.Date },
                    { "param_department", int.Parse(departmentId.Text) },
                    { "param_date_of_hiring", DateTime.Now },
                    { "param_salary", float.Parse(salary.Text) },
                    { "param_rating", 1 }
                };

                bool succeed = sqlHelper.ExecuteDMLProcedure(procedureName, parameters);
                string message = succeed ? "Worker was added to database!" : "Unable to add worker to database";
                MessageBox.Show(message);
                InitAllWorkersData();
            }
            catch (Exception exception)
            {
                string error = $"Error: {exception.Message}";
                Console.WriteLine(error);
                MessageBox.Show(error);
            }

        }
    }
}