using cinemaDB;
using MySql.Data.MySqlClient;
using System;
using System.Collections.Generic;
using System.Collections.ObjectModel;
using System.Globalization;
using System.Windows;
using System.Windows.Controls;

namespace gui.sub_windows
{
    public partial class BuyWindow : Window
    {
        #region binding
        /* For movie details text box. */
        public string movieOfToday
        {
            get { return (string)GetValue(nameProperty); }
            set { SetValue(nameProperty, value); }
        }

        public static readonly DependencyProperty nameProperty = DependencyProperty.Register("movie_of_today", typeof(string), typeof(BuyWindow));

        /* For seats list box. */
        public ObservableCollection<GenericClass> seats
        {
            get { return (ObservableCollection<GenericClass>)GetValue(seatsProperty); }
            set { SetValue(seatsProperty, value); }
        }

        public static readonly DependencyProperty seatsProperty = DependencyProperty.Register("seats", typeof(ObservableCollection<GenericClass>), typeof(BuyWindow));

        /* For food list box. */
        public ObservableCollection<GenericClass> food
        {
            get { return (ObservableCollection<GenericClass>)GetValue(foodProperty); }
            set { SetValue(foodProperty, value); }
        }

        public static readonly DependencyProperty foodProperty = DependencyProperty.Register("food", typeof(ObservableCollection<GenericClass>), typeof(BuyWindow));
        #endregion

        #region variables
        private GenericClass? choosenSeat = null;

        private GenericClass? choosenFood = null;
        private SqlHelper sqlHelper;
        #endregion

        public BuyWindow(GenericClass movie, ref SqlHelper sqlHelper)
        {
            this.sqlHelper = sqlHelper;
            InitializeComponent();
            try
            {
                InitFreeSeats();
                InitFoodList();
                InitMovieDetails(movie);
            }
            catch (Exception exception)
            {
                string error = $"Error: {exception.Message}";
                Console.WriteLine(error);
                MessageBox.Show(error);
            }
        }

        private void InitMovieDetails(GenericClass movie)
        {

            Dictionary<string, object> parameters = new Dictionary<string, object>
            {
                { "param_id", movie.getValue("ID") }
            };

            string procedureName = "get_movie_by_id";

            using (MySqlDataReader reader = sqlHelper.ExecuteSelectProcedure(procedureName, parameters))
            {

                while (reader.Read())
                {
                    GenericClass data = new GenericClass();
                    data.addItem("ID", reader.GetString(0));
                    data.addItem("Movie Name", reader.GetString(1));
                    data.addItem("Rating", reader.GetString(2));
                    data.addItem("Duration", reader.GetString(3) + " min.");
                    data.addItem("Screen Time", reader.GetString(4));
                    data.addItem("Theater number", reader.GetString(5));
                    movieOfToday = data.ToString();
                }
            }
        }

        private void InitFoodList()
        {
            List<GenericClass> foodList = new List<GenericClass>();
            string query = "SELECT product.id, product_name, product.price FROM food INNER JOIN product ON food.id = product.id";

            using (MySqlDataReader reader = sqlHelper.ExecuteSqlCode(query))
            {
                while (reader.Read())
                {
                    GenericClass row = new GenericClass();

                    /* Map the column values from the reader to the properties of YourModelClass. */
                    row.addItem("ID", reader.GetString(0));
                    row.addItem("Name", reader.GetString(1));
                    row.addItem("Price", reader.GetString(2) + "$");
                    foodList.Add(row);
                }

                /* The list 'tableData' is now contains the content of the table. */
            }

            food = new ObservableCollection<GenericClass>(foodList);
        }

        private void InitFreeSeats()
        {
            ;
            List<GenericClass> tickets = new List<GenericClass>();
            using (MySqlDataReader reader = sqlHelper.ExecuteSelectProcedure("select_free_tickets", null))
            {
                while (reader.Read())
                {
                    GenericClass row = new GenericClass();

                    /* Map the column values from the reader to the properties of YourModelClass. */
                    row.addItem("ID", reader.GetString(0));
                    row.addItem("Product id", reader.GetString(1));
                    row.addItem("Seat Number", reader.GetString(2));
                    row.addItem("Screen Time", reader.GetString(3));
                    row.addItem("Room Number", reader.GetString(4));
                    tickets.Add(row);
                }

                /* The list 'tableData' is now contains the content of the table. */
            }
            seats = new ObservableCollection<GenericClass>(tickets);
        }

        private void BuyTicketClick(object sender, RoutedEventArgs routedEvent)
        {

            if (choosenSeat == null)
            {
                MessageBox.Show("You need select a seat first.");
                return;
            }

            string procedureName = "add_sell";
            int consumerId;
            int employeeId;
            int ticketId;
            DateTime dateOfBirth = new DateTime();

            DateTime.TryParseExact(dateOfBirthBox.Text, "yyyy-MM-dd", CultureInfo.InvariantCulture, DateTimeStyles.None, out dateOfBirth);
            consumerId = int.Parse(customerIdBox.Text);
            employeeId = int.Parse(employeeIdBox.Text);
            int.TryParse(choosenSeat.getValue("ID").ToString(), out ticketId);



            Dictionary<string, object> parameters = new Dictionary<string, object>
                {
                    { "param_customer_id", consumerId },
                    { "param_customer_name", nameBox.Text },
                    { "param_date_of_birth", dateOfBirth.Date },
                    { "param_employee_id", employeeId },
                    { "param_product_id", (int)choosenSeat.getValue("Seat Number") },
                    { "param_ticket_id", ticketId }
                };

            bool succeed = sqlHelper.ExecuteDMLProcedure(procedureName, parameters);
            string message = succeed ? "Accepted Transaction!" : "Something went wrong!";
            MessageBox.Show(message);
        }

        private void BuyFoodClick(object sender, RoutedEventArgs routedEvent)
        {

            if (choosenFood == null)
            {
                MessageBox.Show("You must to select food first.");
                return;
            }

            string procedureName = "add_sell";
            int consumerId;
            int employeeId;
            DateTime dateOfBirth = new DateTime();

            DateTime.TryParseExact(dateOfBirthBox.Text, "yyyy-MM-dd", CultureInfo.InvariantCulture, DateTimeStyles.None, out dateOfBirth);
            consumerId = int.Parse(customerIdBox.Text);
            employeeId = int.Parse(employeeIdBox.Text);
            

            Dictionary<string, object> parameters = new Dictionary<string, object>
                {
                    { "param_customer_id", consumerId },
                    { "param_customer_name", nameBox.Text },
                    { "param_date_of_birth", dateOfBirth.Date },
                    { "param_employee_id", employeeId },
                    { "param_product_id", (int)choosenFood.getValue("ID") },
                    /* When buy a food no need to ticket. */
                    { "param_ticket_id", -1 }
                };

            bool succeed = sqlHelper.ExecuteDMLProcedure(procedureName, parameters);
            string message = succeed ? "Accepted Transaction!" : "Something went wrong!";
            MessageBox.Show(message);
        }

        private void FoodSelectionChanged(object sender, SelectionChangedEventArgs selectionChangedEvent)
        {
            var selectedItem = ((ListBox)sender).SelectedItem;
            if (selectedItem != null)
            {
                choosenFood = new GenericClass(selectedItem.ToString());
            }
            
        }

        private void AvailableSeatsSelectionChanged(object sender, SelectionChangedEventArgs selectionChangedEvent)
        {
            var selectedItem = ((ListBox)sender).SelectedItem;
            if (selectedItem != null)
            {
                choosenSeat = new GenericClass(selectedItem.ToString());
            }
        }

    }
}