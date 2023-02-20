using System;
using Proviso.Core.Interfaces;

namespace Proviso.Core.Definitions
{
    public class FacetDefinition : DefinitionBase, IValidated
    {
        public string SurfaceName { get; set; }
        public string AspectName { get; set; }

        public string Id { get; set; }
        public FacetType FacetType { get; private set; }

        public FacetDefinition(string name, string id, string modelPath, string targetPath, bool skip, string skipReason, FacetType type) 
            : base(name, modelPath, targetPath, skip, skipReason)
        {
            this.Id = id;
            this.FacetType = type;
        }

        public void Validate(object validationContext)
        {
            if (string.IsNullOrWhiteSpace(this.Name))
                throw new Exception("Proviso Validation Error. [Facet] -Name can NOT be null/empty.");

            // TODO: if there's an Aspect, there MUST also be a Surface. (But the inverse is not true/required.)
        }
    }
}