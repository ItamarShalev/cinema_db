using nsGenericClass;
using System;
using System.Collections.Generic;
using System.Collections.ObjectModel;
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

namespace tmp.sub_windows
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
        public BuyWin(GenericClass movie)
        {
            InitializeComponent();
            List<GenericClass> list = new List<GenericClass>();
            for (int i = 0; i < 10; i++)
            {
                list.Add(new GenericClass().addValue("hello i am object number :").addValue(i.ToString()));
            }
            List<GenericClass> list2 = new List<GenericClass>();
            list2.Add(movie);
            movie_of_today = movie.ToString();
            food = new ObservableCollection<GenericClass>(list);
            seats = new ObservableCollection<GenericClass>(list);
        }

        private void BuyTicket_Click(object sender, RoutedEventArgs e)
        {
            if (choosenSeat!="")
            {
                MessageBox.Show(choosenSeat);
            }
        }

        private void BuyFood_Click(object sender, RoutedEventArgs e)
        {
            if (choosenFood!="")
            {
                MessageBox.Show(choosenFood);
            }
        }

        private void Food_SelectionChanged(object sender, SelectionChangedEventArgs e)
        {
            choosenFood= ((ListBox)sender).SelectedItem.ToString();
        }

        private void Available_seats_SelectionChanged(object sender, SelectionChangedEventArgs e)
        {
            choosenSeat = ((ListBox)sender).SelectedItem.ToString();
        }

      
    }
}
