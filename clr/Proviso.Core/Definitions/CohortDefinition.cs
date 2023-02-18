namespace Proviso.Core.Definitions
{
    public class CohortDefinition : DefinitionBase
    {
        public string FacetName { get; set; }

        public CohortDefinition(string name, string modelPath, string targetPath, bool skip, string skipReason) 
            : base(name, modelPath, targetPath, skip, skipReason)
        {
        }
    }
}