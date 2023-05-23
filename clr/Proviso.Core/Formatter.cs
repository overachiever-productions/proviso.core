using System;
using System.Management.Automation;

namespace Proviso.Core
{
    public class Formatter
    {
        public static Formatter Instance => new Formatter();

        private Formatter() { }

        public string ColumnHeading(int leftPadding, string name, int length)
        {
            string padding = new String(' ', length);
            string padded = $"{name}{padding}".Substring(0, length);

            if (leftPadding > 0)
                padded = new String(' ', leftPadding) + padded;

            // TODO: check for whether current host supports colorization or not: 
            string output = $"\u001b[36;1m{padded}\u001b[0m";

            return output;
        }

        public string ColumnUnderline(int leftPadding, int length)
        {
            string dashed = new String('-', length);
            if (leftPadding > 0)
            {
                dashed = new String(' ', leftPadding) + dashed;
            }

            // TODO: check for colors/etc. 
            string output = $"\u001b[36;1m{dashed}\u001b[0m";

            return output;
        }


        public string SizedDash(int length)
        {
            string dashed = new String('-', length);

            return dashed;
        }

        public string LeftPaddedSizedDash(int leftPadding, int length)
        {
            string padded = new String(' ', leftPadding) + this.SizedDash(length);
            return padded;
        }

        public string PaddedString(string input, int length)
        {
            bool colored = false;
            if (input == "11")
            {
                colored = true;
            }

            string padded = $"{input}..................................................................".Replace(".", " ");

            if (colored)
            {
                //return "\u001b[4;40m" + padded.Substring(0, length) + "\u001b[0m";
                return "\u001b[31;1m" + padded.Substring(0, length) + "\u001b[0m";
            }

            
            return padded.Substring(0, length);
        }

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

        //public static void WriteVerbose(string message)
        //{
        //    // TODO: https://stackoverflow.com/questions/51662588/is-there-a-way-to-write-to-powershell-verbose-stream-from-c-sharp-static-non-ps 
        //    //      i've also seen stuff on how to do this in ... a book somewhere. 
        //    // maybe? https://stackoverflow.com/questions/54107825/how-to-pass-warning-and-verbose-streams-from-a-remote-command-when-calling-power

        //    using (PowerShell ps = PowerShell.Create(RunspaceMode.CurrentRunspace))
        //    {
        //        VerboseRecord verbose = new VerboseRecord(message);

        //        ps.Streams.Verbose.Add(verbose);
        //    }

        //    Console.WriteLine(message);
        //}
    }
}