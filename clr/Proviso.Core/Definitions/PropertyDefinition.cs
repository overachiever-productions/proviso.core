namespace Proviso.Core.Definitions
{
    public class PropertyDefinition : DefinitionBase
    {
        public string FacetName { get; set; }
        public string CohortName { get; set; }

        public PropertyDefinition(string name, string modelPath, string targetPath, bool skip, string skipReason) 
            : base(name, modelPath, targetPath, skip, skipReason)
        {
        }

    }
}