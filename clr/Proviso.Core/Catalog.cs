using System;
using System.Collections.Generic;
using Proviso.Core.Definitions;
using Proviso.Core.Models;

namespace Proviso.Core
{
    public class Catalog
    {
        private List<EnumeratorDefinition> _enumerators = new List<EnumeratorDefinition>();
        private List<RunbookDefinition> _runbooks = new List<RunbookDefinition>();
        private List<FacetDefinition> _facets = new List<FacetDefinition>();
        
        // TODO: additional lists/collections to add: 
        //  _surfaces 
        //  _iterators 
        //  TODO: PROBABLY different, but some sort of 'named' asserts (and ... provide option for 'authors' to add theirs as well. 

        // REFACTOR: looks like I lost my mind... cohorts and properties should ONLY BE children of their PARENT Facet... 
        //      er, well... did I ever decide to make properties|cohorts 'borrowable' from elsewhere?
        //      if so, then... they got to BOTH their parents and here... (but I'm going to need some sort of import/borrow/use syntax/func. 
        //      i THINK i was ONLY going to allow FACETS to be re-used like this (from one surface to the next)... but ... maybe I was going to do the same with props? (cohorts?)
        private List<CohortDefinition> _cohorts = new List<CohortDefinition>();
        private List<PropertyDefinition> _properties = new List<PropertyDefinition>();

        public static Catalog Instance => new Catalog();

        private Catalog() { }

        // REFACTOR: all of these Set<T>Definition calls can/should be replaced by some sort of SetDefinition<T>(t, bool allowReplace)
        //      kind of internal/private helper. i.e., have to leave the interfaces/public methods the same... but should implement the copy-paste-tweak guts as a generic... 
        public bool SetRunbookDefinition(RunbookDefinition added, bool allowReplace)
        {
            added.Validate(null);

            var exists = this._runbooks.Find(x => x.Name == added.Name);
            if (exists != null)
            {
                if (allowReplace)
                {
                    exists = added;
                    return true;
                }

                throw new Exception($"[Runbook] with name [{added.Name}] already exists and can NOT be replaced. Ensure unique [Runbook] names and/or allow global replacement override.");
            }
            return false;
        }
        
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

        public RunbookDefinition GetRunbook(string name)
        {
            throw new NotImplementedException();
        }

        public SurfaceDefinition GetSurface(string name)
        {
            throw new NotImplementedException();
        }

        public FacetDefinition GetFacetByName(string name)
        {
            return this._facets.Find(x => x.Name == name);
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
            return this._enumerators.Find(x => x.Name == name);
        }
    }
}