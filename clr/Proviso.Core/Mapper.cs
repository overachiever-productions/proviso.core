using Proviso.Core.Definitions;
using Proviso.Core.Models;

namespace Proviso.Core
{
    public static class Mapper
    {
        //public static Property ToProperty(this PropertyDefinition definition)
        //{
        //    return new Property
        //    {
        //        Name = definition.Name,
        //        ParentName = definition.ParentName
        //    };
        //}

        public static Facet ToFacet(FacetDefinition definition)
        {
            var output = new Facet
            {
                FacetName = definition.Name, 
                FacetType = definition.FacetType, 
                Id = definition.Id, 
                ParentType = definition.ParentType, 
                ParentName = definition.ParentName, 
                MembershipType = definition.MembershipType
            };

            foreach (var prop in definition.Properties)
            {
                if (prop.PropertyType == PropertyType.Cohort)
                {

                }
                else
                {

                }
            }

            return output;
        }
    }
}