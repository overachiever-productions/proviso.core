using Proviso.Core.Definitions;
using Proviso.Core.Models;

namespace Proviso.Core
{
    public static class Mapper
    {
        public static Property ToProperty(this PropertyDefinition definition)
        {
            return new Property
            {
                Name = "hmmmmm", //definition.Name,
                ParentName = definition.ParentName
            };
        }

        public static Facet ToFacet(FacetDefinition definition)
        {
            return new Facet
            {
                FacetName = definition.Name, 
                FacetType = definition.FacetType, 
                Id = definition.Id
            };
        }
    }
}