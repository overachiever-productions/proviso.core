namespace Proviso.Core.Models
{
    public class Facet
    {
        public string FacetName { get; internal set; }
        public string Id { get; internal set; }
        public FacetType FacetType { get; internal set; }

        public string ParentName { get; internal set; }
        public FacetParentType ParentType { get; internal set; }
        public Membership MembershipType { get; internal set; }
    }
}