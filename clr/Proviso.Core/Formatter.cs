using System;
using System.Management.Automation;
using System.Text.RegularExpressions;

namespace Proviso.Core
{
    public class Formatter
    {
        private Formatter() { }

        public bool HostSupportsColor { get; set; } // exposing this as a PUBLIC prop - not sure I'm going to use it much from 'outside' this class though.
        public static Formatter Instance => new Formatter();

        public void SetCurrentHostInfo(string name)
        {
            if (name.ToLowerInvariant() == "consolehost")
                this.HostSupportsColor = true;
            else
            {
                var regex = new Regex("console|code|remotehost");
                if(regex.IsMatch(name))
                    this.HostSupportsColor = true;
            }
        }

        public string SizedDash(int length)
        {
            string output = new String('-', length);

            if (this.HostSupportsColor)
                //output = $"\u001b[36;1m{output}\u001b[0m";
                output = $"{PSStyle.Instance.Foreground.BrightCyan}{output}{PSStyle.Instance.Reset}";

            return output;
        }

        public string ColumnHeading(int leftPadding, string name, int length)
        {
            string padding = new String(' ', length);
            string output = $"{name}{padding}".Substring(0, length);

            if (leftPadding > 0)
                output = new String(' ', leftPadding) + output;

            if (this.HostSupportsColor)
                output = $"{PSStyle.Instance.Foreground.BrightCyan}{output}{PSStyle.Instance.Reset}";

            return output;
        }

        public string ColumnDivider(int leftPadding, int length)
        {
            string output = new String(' ', leftPadding) + this.SizedDash(length);

            if(this.HostSupportsColor)
                output = $"{PSStyle.Instance.Foreground.BrightCyan}{output}{PSStyle.Instance.Reset}";

            return output;
        }

        public string BoundedString(string input, int length)
        {
            if (input == "$null")
                return this.GetBoundedPowerShellNull(length);

            string cleaned = input.Trim();
            if (cleaned.Length > length)
                cleaned = cleaned.Substring(0, length - 1) + '…';

            string padding = new String(' ', length);

            return $"{cleaned}{padding}".Substring(0, length);
        }

        private string GetBoundedPowerShellNull(int length)
        {
            string output = "$null";
            string padding = new String(' ', length);

            if (this.HostSupportsColor)
                output = $"{PSStyle.Instance.Foreground.BrightCyan}$null{PSStyle.Instance.Reset}";

            return $"{output}{padding}".Substring(0, length);
        }

        //public string ToEmpty(string input)
        //{
        //    if (string.IsNullOrEmpty(input))
        //        return "<EMPTY>";

        //    return input;
        //}

        //public string ToHeading(string input)
        //{
        //    return System.Text.RegularExpressions.Regex.Replace(input.ToUpper(), ".{1}", "$0 ");
        //}
    }
}