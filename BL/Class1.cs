namespace BL
{

    /// <summary>
    /// this class will be resposiblle for all logic in app.
    /// every query from daata base will go throw this part and will be checked.
    /// should create an exception class.
    /// </summary>
    public class BL
    {

    }
    /// <summary>
    /// for any exception that we want, we can print the msg in a message box.
    /// </summary>
    public class BLexception: Exception
    {
        BLexception()
        {

        }
        BLexception(string msg) :base(msg)
        {
            
        }
    }
}