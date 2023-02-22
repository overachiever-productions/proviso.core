using System.Management.Automation;

namespace Proviso.Core.Definitions
{
    public class AssertDefinition
    {
        public string Name { get; private set; }
        public string FailureMessage { get; private set; }
        public bool IsNegated { get; private set; }
        public bool ConfigureOnly { get; private set; }

        public ScriptBlock ScriptBlock { get; set; }
        public bool IsIgnored { get; private set; }
        public string IgnoredReason { get; private set; }

        public AssertDefinition(string name, string failureMessage, bool negated, bool configureOnly)
        {
            this.Name = name;
            this.FailureMessage = failureMessage;
            this.IsNegated = negated;
            this.ConfigureOnly = configureOnly;
        }

        public void SetIgnored(string reason)
        {
            this.IsIgnored = true;
            this.IgnoredReason = reason; // this can totally be blank/null at this point... 
        }
    }
}