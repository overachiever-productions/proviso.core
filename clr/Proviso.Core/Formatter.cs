using System;
using System.Management.Automation;

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

        public static void WriteVerbose(string message)
        {
            // TODO: https://stackoverflow.com/questions/51662588/is-there-a-way-to-write-to-powershell-verbose-stream-from-c-sharp-static-non-ps 
            //      i've also seen stuff on how to do this in ... a book somewhere. 
            // maybe? https://stackoverflow.com/questions/54107825/how-to-pass-warning-and-verbose-streams-from-a-remote-command-when-calling-power

            using (PowerShell ps = PowerShell.Create(RunspaceMode.CurrentRunspace))
            {
                VerboseRecord verbose = new VerboseRecord(message);

                ps.Streams.Verbose.Add(verbose);
            }

            Console.WriteLine(message);
        }
    }
}