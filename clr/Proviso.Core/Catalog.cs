using System;
using System.Collections.Generic;
using Proviso.Core.Definitions;
using Proviso.Core.Models;

namespace Proviso.Core
{
    public class Catalog
    {
        // implement as this: https://learn.microsoft.com/en-us/dotnet/api/system.collections.generic.list-1.find?view=net-7.0 
        private List<EnumeratorDefinition> _enumerators = new List<EnumeratorDefinition>();

        public static Catalog Instance => new Catalog();

        private Catalog() { }

        public void AddFacetDefinition(FacetDefinition added)
        {
            // TODO: can NOT add any kind of *Definition without it being VALIDATED first. 
        }

        public void AddPropertyDefinition(PropertyDefinition added)
        {
            // TODO: can NOT add any kind of *Definition without it being VALIDATED first. 
        }

        public void AddCohortDefinition(CohortDefinition added)
        {
            // TODO: can NOT add any kind of *Definition without it being VALIDATED first. 
        }

        public bool SetEnumeratorDefinition(EnumeratorDefinition added, bool allowReplace)
        {
            added.Validate(null);

            var exists = this._enumerators.Find(x => x.Name == added.Name);
            if (exists != null)
            {
                if (allowReplace)
                {
                    exists = added;
                    return true;
                }

                string e = exists.IsGlobal ? "Enumerator" : "Enumerate";
                throw new Exception($"Block [{e}] with name [{added.Name}] already exists and can NOT be replaced. Ensure unique {e} names and/or allow global replacement override.");
            }
            
            this._enumerators.Add(added);
            return false;
        }

        public FacetDefinition GetFacetByName(string name)
        {
            throw new NotImplementedException();
        }

        public EnumeratorDefinition GetEnumerator(string name)
        {
            // REFACTOR: if ... the output of .Find is ... null, then... i should just be able to return this.enums.Find()
            var exists = this._enumerators.Find(x => x.Name == name);
            if (exists == null) 
                return null;

            return exists;
        }
    }
}