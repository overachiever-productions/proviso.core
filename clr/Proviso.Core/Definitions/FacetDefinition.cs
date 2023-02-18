using System;

namespace Proviso.Core.Definitions
{
    public class FacetDefinition
    {
        public string SurfaceName { get; set; }
        public string AspectName { get; set; }

        public string Name { get; private set; }
        public string Id { get; set; }
        public string ModelPath { get; private set; }
        public string TargetPath { get; private set; }
        public bool Skip { get; private set; }
        public string SkipReason { get; private set; }
        public Impact Impact { get; set; }

        public FacetDefinition(string name, string id, string modelPath, string targetPath, bool skip, string skipReason)
        {
            if (string.IsNullOrEmpty(id))
                id = Guid.NewGuid().ToString();

            this.Name = name;
            this.Id = id;

            this.Impact = Impact.None;
            this.ModelPath = modelPath;
            this.TargetPath = targetPath;
            this.Skip = skip;
            this.SkipReason = skipReason;
        }

        public void SetExpectFromParameter()
        {

        }

        public void SetExtractFromParameter()
        {

        }

        public void SetThrowOnConfig()
        {

        }
    }
}