using System.Text.RegularExpressions;

#pragma warning disable SYSLIB1045


namespace cinemaDB
{
    public class GenericClass
    {
        private Dictionary<string, object> keyValues = new Dictionary<string, object>();


        public GenericClass()
        {
        }

        public GenericClass(string data)
        {
            if (string.IsNullOrEmpty(data))
            {
                return;
            }

            /* Remove trailing separator if exists. */
            string pattern = "---------------------$";
            data = Regex.Replace(data, pattern, string.Empty);
            data = Regex.Replace(data, "\\$", string.Empty);

            /* Split string into pairs. */
            string[] pairs = data.Split(new[] { "\r\n", "\r", "\n" }, StringSplitOptions.None);

            foreach (var pair in pairs)
            {
                if (string.IsNullOrEmpty(pair))
                {
                    continue;
                }
                /* Split pair into key and value. */
                string[] keyValue = pair.Split(new[] { ':' }, 2);
                if (keyValue.Length == 2)
                {
                    keyValues.Add(keyValue[0].Trim(), keyValue[1].Trim());
                }
                else
                {
                    throw new ArgumentException($"Invalid input data: {pair}");
                }
            }
        }

        public GenericClass addItem(string key, object value)
        {
            keyValues.Add(key, value);
            return this;
        }

        public object getValue(string key)
        {
            return keyValues[key];
        }
        public override string ToString()
        {
            string data = string.Empty;
            foreach (var item in keyValues)
            {
                data += $"{item.Key}: {item.Value}\n";
            }

            if (data.Length > 0)
            {
                data += "---------------------";
            }

            return data;
        }
    }
}
