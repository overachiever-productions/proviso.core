using System;
using System.Collections.Generic;
using Proviso.Core.Definitions;
using Proviso.Core.Models;

namespace Proviso.Core
{
    public class ProvisoCatalog
    {
        private Dictionary<string, FacetDefinition> _totallyCrappyFacetDictionaryImplementation = new Dictionary<string, FacetDefinition>();
        // implement as this: https://learn.microsoft.com/en-us/dotnet/api/system.collections.generic.list-1.find?view=net-7.0 

        public static ProvisoCatalog Instance => new ProvisoCatalog();

        private ProvisoCatalog() { }

        public void AddFacet(FacetDefinition added)
        {
            // add if it doesn't exist. 
            //  if it does exist, check for different parent... 

            // MVP implementation:
            this._totallyCrappyFacetDictionaryImplementation.Add(added.Name, added);
        }

        public FacetDefinition GetFacetByName(string name)
        {
            return this._totallyCrappyFacetDictionaryImplementation[name];
        }
    }
}