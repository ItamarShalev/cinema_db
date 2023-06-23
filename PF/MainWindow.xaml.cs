using nsGenericClass;
using PF.sub_windows;
using System;
using System.Collections.Generic;
using System.Collections.ObjectModel;
using System.Windows;
using System.Windows.Input;
using System.Data.SqlClient;
using System.Globalization;
using System.IO;
using System.Windows.Controls;
using MySql.Data.MySqlClient;


namespace PF
{
    /*
     * TODO: add semi BL layer, and a BL object to represent the DAL layer, so we could send it as an argument for each sub window.
     */

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
        #region sql helper
        //SqlHelper SqlHelper;
        #endregion
        public MainWindow()
        {
            InitializeComponent();
            string connectionString = "server=localhost;user=admin;database=db_cinema;port=3306;password=9smlDX1u";
            MySqlConnection connection = new MySqlConnection(connectionString);
            try
            {
                connection.Open();
                MessageBox.Show("connection has establshied!");
            }
            catch (Exception ex)
            {
                throw;
            }
            List<GenericClass> movies1 = new List<GenericClass>();
            GenericClass tmp = new GenericClass();
            tmp.addValue("this is tmp!");
            movies1.Add(tmp);
            
            movies_of_today = new ObservableCollection<GenericClass>(movies1);
        }

        /// <summary>
        /// buuuton click for admin buttomn to go to workers window.
        /// </summary>
        /// <param name="sender"></param>
        /// <param name="e"></param>
        private void Admin_Click(object sender, RoutedEventArgs e)
        {
            //TODO: send database object as argument.
            WorkersWin workerwindow=new WorkersWin();
            workerwindow.ShowDialog();
        }

        private void Movies_of_today_DoubleClick(object sender, MouseButtonEventArgs e)
        {
            //TODO: create an object for printing all object members of data base.
            
            GenericClass p = (GenericClass)(((ListView)sender).SelectedItem);
            if (p==null)
            {
                return;
            }
            else
            {
              BuyWin buywin = new BuyWin(p);
              buywin.ShowDialog();
            }
             
        }
    }
}
