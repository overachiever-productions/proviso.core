using System;

using Proviso.Core.Interfaces;

namespace Proviso.Core.Definitions
{
    public class CohortDefinition : DefinitionBase, IValidated
    {
        public string FacetName { get; set; }

        public CohortDefinition(string name, string modelPath, string targetPath, bool skip, string skipReason) 
            : base(name, modelPath, targetPath, skip, skipReason)
        {
        }

        public void Validate(object validationContext)
        {
            if (string.IsNullOrWhiteSpace(this.Name))
                throw new Exception("Proviso Validation Error. [Cohort] -Name can NOT be null/empty.");

            if (string.IsNullOrWhiteSpace(this.FacetName))
                throw new Exception("Proviso Validation Error. [Cohort] blocks must be within a Parent [Facet] block.");
        }
    }
}