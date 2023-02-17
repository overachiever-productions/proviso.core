namespace Proviso.Core
{
    public class Formatter
    {
        public static Formatter Instance => new Formatter();

        private Formatter() { }

        public string ToEmpty(string input)
        {
            if (string.IsNullOrEmpty(input))
                return "<EMPTY>";

            return input;
        }

        public string ToHeading(string input)
        {
            return System.Text.RegularExpressions.Regex.Replace(input.ToUpper(), ".{1}", "$0 ");
        }
    }
}