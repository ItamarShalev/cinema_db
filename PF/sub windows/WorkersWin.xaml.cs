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
    /// Interaction logic for WorkersWin.xaml
    /// </summary>
    public partial class WorkersWin : Window
    {
        public ObservableCollection<GenericClass> workers
        {
            get { return (ObservableCollection<GenericClass>)GetValue(workersProperty); }
            set { SetValue(workersProperty, value); }
        }
        public static readonly DependencyProperty workersProperty =
                DependencyProperty.Register("workers", typeof(ObservableCollection<GenericClass>), typeof(WorkersWin));
        
        public WorkersWin()
        {
            InitializeComponent();
            List<GenericClass> workers1 = new List<GenericClass>();
            for (int i = 0; i < 10; i++)
            {
                workers1.Add(new GenericClass().addValue("hello i am worker number: " + i.ToString()));
            }
            workers = new ObservableCollection<GenericClass>(workers1);

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
                Worker worker = new Worker(p);
                worker.ShowDialog();
            }
        }
    }
}
