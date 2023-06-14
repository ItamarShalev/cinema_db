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


        public Worker(GenericClass p)
        {
            InitializeComponent();
            worker = p.ToString();
        }

        private void Button_Click(object sender, RoutedEventArgs e)
        {
            //TODO add deletion of this worker in data abse.
        }
    }
}
