using System;
using System.Management.Automation;
using Proviso.Core.Interfaces;

namespace Proviso.Core.Definitions
{
    public class EnumeratorDefinition : IValidated
    {
        public DateTime Created { get; set; }  
        public string FacetName { get; set; }
        public string CohortName { get; set; }

        public string Name { get; private set; }
        public bool IsGlobal { get; private set; }
        public ScriptBlock Enumerate { get; set; }
        public string OrderBy { get; set; }

        public EnumeratorDefinition(string name, bool isGlobal)
        {
            this.Created = DateTime.UtcNow;
            
            this.Name = name;
            this.IsGlobal = isGlobal;
        }

        public void Validate(object validationContext)
        {
            if (string.IsNullOrWhiteSpace(this.Name))
                throw new Exception("Proviso Validation Error. [Enumerator] -Name can NOT be null/empty.");

            if (IsGlobal)
            {
                // TODO: Implement AND set up some rudimentar unit tests..
                //  e.g., globals can't have facet/cohort names
            }
            else
            {
                // TODO: Implement AND set up some rudimentar unit tests..
                //  on the other hand... anonymous ... must have cohort AND facet names
            }


        }
    }
}