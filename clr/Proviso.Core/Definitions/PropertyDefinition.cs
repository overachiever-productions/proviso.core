using System;
using Proviso.Core.Interfaces;

namespace Proviso.Core.Definitions
{
    public class PropertyDefinition : DefinitionBase, IValidated
    {
        public string FacetName { get; set; }
        public string CohortName { get; set; }

        public PropertyDefinition(string name, string modelPath, string targetPath, bool skip, string skipReason) 
            : base(name, modelPath, targetPath, skip, skipReason)
        {
        }

        public void Validate(object validationContext)
        {
            if (string.IsNullOrWhiteSpace(this.Name))
                throw new Exception("Proviso Validation Error. [Property] -Name can NOT be null/empty.");

            if(string.IsNullOrWhiteSpace(this.FacetName) & string.IsNullOrWhiteSpace(this.CohortName))
                throw new Exception("Proviso Validation Error. [Property] blocks must be within a Parent [Facet] or [Cohort] block.");
        }
    }
}