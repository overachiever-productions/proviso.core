namespace Proviso.Core.Definitions
{
    public class PropertyDefinition
    {
        public string FacetName { get; set; }

        public string Name { get; private set; }
        public string ModelPath { get; private set; }
        public string TargetPath { get; private set; }
        public bool Skip { get; private set; }
        public string SkipReason { get; private set; }
        public Impact Impact { get; set; }

        public PropertyDefinition(string name, string modelPath, string targetPath, bool skip, string skipReason)
        {
            this.Name = name;

            this.Impact = Impact.None;
            this.ModelPath = modelPath;
            this.TargetPath = targetPath;
            this.Skip = skip;
            this.SkipReason = skipReason;
        }
    }
}