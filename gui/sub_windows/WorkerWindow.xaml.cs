using MySql.Data.MySqlClient;
using System;
using System.Windows;
using cinemaDB;
using System.Collections.Generic;

namespace gui.sub_windows
{
    /// <summary>
    /// Interaction logic for WorkerWindow.xaml
    /// </summary>
    public partial class WorkerWindow : Window
    {
        public string worker
        {
            get { return (string)GetValue(workerProperty); }
            set { SetValue(workerProperty, value); }
        }

        public static readonly DependencyProperty workerProperty = DependencyProperty.Register("worker", typeof(string), typeof(WorkerWindow));

        private GenericClass? employeeData;

        private SqlHelper sqlHelper;

        public WorkerWindow(GenericClass workerData, ref SqlHelper sqlHelper)
        {
            this.sqlHelper = sqlHelper;
            InitializeComponent();

            try
            {
                int.TryParse(workerData.getValue("ID").ToString(), out int workerId);
                InitWorkerDetails(workerId);
            }
            catch (Exception exception)
            {
                string error = $"Error: {exception.Message}";
                Console.WriteLine(error);
                MessageBox.Show(error);
            }
        }

        private void InitWorkerDetails(int workerId)
        {

            string procedureName = "get_employee";
            Dictionary<string, object> parameters = new Dictionary<string, object>
                {
                    { "employee_id", workerId },
                };

            using (MySqlDataReader reader = sqlHelper.ExecuteSelectProcedure(procedureName, parameters))
            {
                // Process the retrieved data
                while (reader.Read())
                {
                    employeeData = new GenericClass();

                    employeeData.addItem("ID", reader.GetString(0));
                    employeeData.addItem("First name", reader.GetString(1));
                    employeeData.addItem("Last Name", reader.GetString(2));
                    employeeData.addItem("Date Of Birth", reader.GetString(3));
                    employeeData.addItem("Department NO.", reader.GetString(4));
                    employeeData.addItem("Still Active?", reader.GetString(5));
                    employeeData.addItem("Date Of Hiring", reader.GetString(6));
                    employeeData.addItem("Salary", reader.GetString(7));
                    employeeData.addItem("Rating", reader.GetString(8));
                }
            }
            worker = employeeData.ToString();
        }


        private void ButtonClick(object sender, RoutedEventArgs routedEvent)
        {
            try
            {
                int.TryParse(employeeData.getValue("ID").ToString(), out int employeeId);

                string procedureName = "delete_employee";
                Dictionary<string, object> parameters = new Dictionary<string, object>
                {
                    { "param_id", employeeId },
                };

                bool succeed = sqlHelper.ExecuteDMLProcedure(procedureName, parameters);
                string message = succeed ? "Worker still active value set to 0 !" : "Something went wrong!";
                MessageBox.Show(message);
                InitWorkerDetails(employeeId);
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
