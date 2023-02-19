using System;
using System.Collections.Generic;
using Proviso.Core.Definitions;
using Proviso.Core.Models;

namespace Proviso.Core
{
    public class Catalog
    {
        private List<FacetDefinition> _facets = new List<FacetDefinition>();
        private List<CohortDefinition> _cohorts = new List<CohortDefinition>();
        private List<PropertyDefinition> _properties = new List<PropertyDefinition>();
        private List<EnumeratorDefinition> _enumerators = new List<EnumeratorDefinition>();
        

        public static Catalog Instance => new Catalog();

        private Catalog() { }


        // REFACTOR: all of these Set<T>Definition calls can/should be replaced by some sort of SetDefinition<T>(t, bool allowReplace)
        //      kind of internal/private helper. i.e., have to leave the interfaces/public methods the same... but should implement the copy-paste-tweak guts as a generic... 
        public bool SetFacetDefinition(FacetDefinition added, bool allowReplace)
        {
            added.Validate(null);

            var exists = this._facets.Find(x => x.Name == added.Name);
            if (exists != null)
            {
                if (allowReplace)
                {
                    exists = added;
                    return true;
                }

                throw new Exception($"[Facet] with name [{added.Name}] already exists and can NOT be replaced. Ensure unique [Facet] names and/or allow global replacement override.");
            }

            this._facets.Add(added);
            return false;

        }

        public bool SetPropertyDefinition(PropertyDefinition added, bool allowReplace)
        {
            added.Validate(null);

            var exists = this._properties.Find(x => x.Name == added.Name);
            if (exists != null)
            {
                if (allowReplace)
                {
                    exists = added;
                    return true;
                }

                throw new Exception($"[Property] with name [{added.Name}] already exists and can NOT be replaced. Ensure unique [Property] names and/or allow global replacement override.");
            }

            this._properties.Add(added);
            return false;
        }

        public bool SetCohortDefinition(CohortDefinition added, bool allowReplace)
        {
            added.Validate(null);

            var exists = this._cohorts.Find(x => x.Name == added.Name);
            if (exists != null)
            {
                if (allowReplace)
                {
                    exists = added;
                    return true;
                }

                throw new Exception($"[Cohort] with name [{added.Name}] already exists and can NOT be replaced. Ensure unique [Cohort] names and/or allow global replacement override.");
            }

            this._cohorts.Add(added);
            return false;

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
                throw new Exception($"[{e}] with name [{added.Name}] already exists and can NOT be replaced. Ensure unique {e} names and/or allow global replacement override.");
            }
            
            this._enumerators.Add(added);
            return false;
        }

        public FacetDefinition GetFacetByName(string name)
        {
            throw new NotImplementedException();
        }

        public FacetDefinition GetFacetById(string id)
        {
            // TODO: I'm not even sure this method/approach is needed.
            //  if it's NOT... then a) remove and b) change GetFacetByName to GetFacet(string name)
            throw new NotImplementedException();
        }

        public CohortDefinition GetCohort(string name)
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