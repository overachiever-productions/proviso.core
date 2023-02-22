namespace Proviso.Core.Models
{
    public class Facet
    {
        public string FacetName { get; private set; }
        public string Id { get; private set; }
        public FacetType FacetType { get; private set; }

        public string ParentAspectName { get; set; }
        public string ParentSurfaceName { get; set; }
        public string ParentRunbookName { get; set; }

        public Facet(string name, string id, FacetType type, string aspectName, string surfaceName, string runbookName)
        {
            this.FacetName = name;
            this.Id = id;
            this.FacetType = type;

            this.ParentAspectName = aspectName;
            this.ParentSurfaceName = surfaceName;
            this.ParentRunbookName = runbookName;
        }
    }
}