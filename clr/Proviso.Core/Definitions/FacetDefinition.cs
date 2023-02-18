using System;

namespace Proviso.Core.Definitions
{
    public class FacetDefinition : DefinitionBase
    {
        public string SurfaceName { get; set; }
        public string AspectName { get; set; }

        public string Id { get; set; }

        public FacetDefinition(string name, string id, string modelPath, string targetPath, bool skip, string skipReason) 
            : base(name, modelPath, targetPath, skip, skipReason)
        {
            this.Id = id;
        }
    }
}