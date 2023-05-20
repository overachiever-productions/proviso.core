using System;
using System.Linq;
using System.Collections.Generic;
using System.Management.Automation;
using Proviso.Core.Models;

namespace Proviso.Core
{
    public class Catalog
    {
        private List<Facet> _facets = new List<Facet>();

        public static Catalog Instance => new Catalog();

        private Catalog() { }

        public void AddFacet(Facet added)
        {
            // TODO: how are these stored/evaluated? in terms of duplicates? 
            this._facets.Add(added);
        }

        public Facet GetFacetById(string id)
        {
            return this._facets.SingleOrDefault(x => x.Id == id);
        }

        public Facet GetFacetByName(string name, string parentName)
        {
            if (string.IsNullOrWhiteSpace(parentName))
            {
                var facets = this._facets.Where(x => x.Name == name);
                if (facets.Count() == 1)
                    return facets.First();

                if(facets.Count() > 1)
                    throw new InvalidOperationException($"Multiple Facets named: [{name}] exist - specify the ParentName or Execute Lookup by Facet.Id instead.");
            }

            return this._facets.FirstOrDefault(x => x.Name == name && x.ParentName == parentName);
        }
    }
}