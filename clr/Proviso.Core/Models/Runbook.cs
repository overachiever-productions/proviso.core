using System.Collections.Generic;
using System.Management.Automation;

namespace Proviso.Core.Models
{
    public class Runbook
    {
        private List<Assert> _assertions = new List<Assert>();

        public string RunbookName { get; set; }
        public ScriptBlock Setup { get; set; }
        public ScriptBlock Cleanup { get; set; }     

        public List<Assert> Asserts => this._assertions;

        public Runbook(string name, ScriptBlock setup, ScriptBlock cleanup)
        {
            this.RunbookName = name;
            this.Setup = setup;
            this.Cleanup = cleanup;
        }

        internal void AddAssert(Assert added)
        {

        }

        internal void AddFacet(Facet added)
        {

        }
    }
}