namespace Proviso.Core.Models
{
    public class Facet
    {
        public string FacetName { get; internal set; }
        public string Id { get; internal set; }
        public FacetType FacetType { get; internal set; }

        //public string ParentAspectName { get; internal set; }
        //public string ParentSurfaceName { get; internal set; }
        //public string ParentRunbookName { get; internal set; }

        //public Facet(string name, string id, FacetType type)
        //{
        //    this.FacetName = name;
        //    this.Id = id;
        //    this.FacetType = type;

        //    //this.ParentAspectName = aspectName;
        //    //this.ParentSurfaceName = surfaceName;
        //    //this.ParentRunbookName = runbookName;
        //}
    }
}