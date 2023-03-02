using System;
using System.Collections.Generic;
using System.Management.Automation;
using System.Reflection.Metadata.Ecma335;
using Proviso.Core.Definitions;
using Proviso.Core.Models;

namespace Proviso.Core
{
    public delegate bool CatalogPredicate<in T>(T existing, T replacement);

    public static class CatalogExtensions
    {
        public static bool SetDefinition<T>(this List<T> list, T added, CatalogPredicate<T> predicate, bool allowReplace, string exceptionText)
        {
            var exists = list.Find(x => predicate(x, added));
            if (exists != null)
            {
                if (allowReplace)
                {
                    exists = added;
                    return true;
                }

                throw new Exception(exceptionText);
            }

            list.Add(added);
            return false;
        }
    }

    public class Catalog
    {
        private List<EnumeratorDefinition> _enumerators = new List<EnumeratorDefinition>();
        private List<EnumeratorAddDefinition> _enumeratorAdds = new List<EnumeratorAddDefinition>();
        private List<EnumeratorRemoveDefinition> _enumeratorRemoves = new List<EnumeratorRemoveDefinition>();
        private List<IteratorDefinition> _iterators = new List<IteratorDefinition>();
        private List<IteratorAddDefinition> _iteratorAdds = new List<IteratorAddDefinition>();
        private List<IteratorRemoveDefinition> _iteratorRemoves = new List<IteratorRemoveDefinition>();
        private List<RunbookDefinition> _runbooks = new List<RunbookDefinition>();
        private List<FacetDefinition> _facets = new List<FacetDefinition>();
        private List<SurfaceDefinition> _surfaces = new List<SurfaceDefinition>();

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

        public bool StoreRunbookDefinition(RunbookDefinition definition, bool allowReplace)
        {
            definition.Validate(null);

            CatalogPredicate<RunbookDefinition> predicate = (exists, added) => exists.Name == added.Name;
            string errorText = $"[Runbook] with name [{definition.Name}] already exists and can NOT be replaced. Ensure unique [Runbook] names and/or allow global replacement override.";
            return this._runbooks.SetDefinition(definition, predicate, allowReplace, errorText);
        }

        public bool StoreSurfaceDefinition(SurfaceDefinition definition, bool allowReplace)
        {
            definition.Validate(null);

            CatalogPredicate<SurfaceDefinition> predicate = (exists, added) => exists.Name == added.Name;
            string errorText = $"";
            return this._surfaces.SetDefinition(definition, predicate, allowReplace, errorText);
        }
        
        public bool StoreFacetDefinition(FacetDefinition definition, bool allowReplace)
        {
            definition.Validate(null);

            // NOTE: using .Id instead of .Name in predicate:
            CatalogPredicate<FacetDefinition> predicate = (exists, added) => exists.Id == added.Id;
            string errorText = $"Facet with name [{definition.Name}] already exists and can NOT be replaced. Ensure unique [Facet] names and/or allow global replacement override.";
            return this._facets.SetDefinition(definition, predicate, allowReplace, errorText);
        }

        public bool StorePropertyDefinition(PropertyDefinition definition, bool allowReplace)
        {
            definition.Validate(null);

            CatalogPredicate<PropertyDefinition> predicate = (exists, added) => exists.Name == added.Name;
            string errorText = $"[Property] with name [{definition.Name}] already exists and can NOT be replaced. Ensure unique [Property] names and/or allow global replacement override.";
            return this._properties.SetDefinition(definition, predicate, allowReplace, errorText);
        }

        public bool StoreCohortDefinition(CohortDefinition definition, bool allowReplace)
        {
            definition.Validate(null);

            CatalogPredicate<CohortDefinition> predicate = (exists, added) => exists.Name == added.Name;
            string errorText = $"[Cohort] with name [{definition.Name}] already exists and can NOT be replaced. Ensure unique [Cohort] names and/or allow global replacement override.";
            return this._cohorts.SetDefinition(definition, predicate, allowReplace, errorText);
        }

        public bool StoreEnumeratorDefinition(EnumeratorDefinition definition, bool allowReplace)
        {
            definition.Validate(null);

            CatalogPredicate<EnumeratorDefinition> predicate = (exists, added) => exists.Name == added.Name;
            string e = definition.IsGlobal ? "Enumerator" : "Enumerate";
            string errorText = $"[{e}] with name [{definition.Name}] already exists and can NOT be replaced. Ensure unique {e} names and/or allow global replacement override.";
            return this._enumerators.SetDefinition(definition, predicate, allowReplace, errorText);
        }

        public bool StoreIteratorDefinition(IteratorDefinition definition, bool allowReplace)
        {
            definition.Validate(null);

            CatalogPredicate<IteratorDefinition> predicate = (exists, added) => exists.Name == added.Name;
            string e = definition.IsGlobal ? "Iterator" : "Iterate";
            string errorText = $"[{e}] with name [{definition.Name}] already exists and can NOT be replaced. Ensure unique {e} names and/or allow global replacement override.";
            return this._iterators.SetDefinition(definition, predicate, allowReplace, errorText);
        }

        public bool StoreAddDefinition(IAddDefinition definition, string parentBlockType, string parentBlockName, bool allowReplace)
        {
            switch (definition.Modality)
            {
                case ModalityType.Enumerator:
                    return this.SetEnumeratorAddDefinition((EnumeratorAddDefinition)definition, parentBlockName, allowReplace);
                case ModalityType.Iterator:
                    return this.SetIteratorAddDefinition((IteratorAddDefinition)definition, parentBlockName, allowReplace);
                default:
                    throw new Exception("Proviso Framework Error. Invalid Modality Specified for StoreAddDefinition().");
            }
        }

        public bool StoreRemoveDefinition(IRemoveDefinition definition, string parentBlockType, string parentBlockName, bool allowReplace)
        {
            switch (definition.Modality)
            {
                case ModalityType.Enumerator:
                    return this.SetEnumeratorRemoveDefinition((EnumeratorRemoveDefinition)definition, parentBlockType, parentBlockName, allowReplace);
                case ModalityType.Iterator:
                    return this.SetIteratorRemoveDefinition((IteratorRemoveDefinition)definition, parentBlockType, parentBlockName, allowReplace);
                default:
                    throw new Exception("Proviso Framework Error. Invalid Modality Specified for StoreAddDefinition().");
            }
        }

        public RunbookDefinition GetRunbookDefinition(string name)
        {
            return this._runbooks.Find(x => x.Name == name);
        }

        public SurfaceDefinition GetSurfaceDefinition(string name)
        {
            return this._surfaces.Find(x => x.Name == name);
        }

        public FacetDefinition GetFacetDefinitionByName(string name)
        {
            return this._facets.Find(x => x.Name == name);
        }

        public FacetDefinition GetFacetDefinitionById(string id)
        {
            // TODO: I'm not even sure this method/approach is needed.
            //  if it's NOT... then a) remove and b) change GetFacetByName to GetFacet(string name)
            throw new NotImplementedException();
        }

        public CohortDefinition GetCohortDefinition(string name)
        {
            throw new NotImplementedException();
        }

        public EnumeratorDefinition GetEnumeratorDefinition(string name)
        {
            return this._enumerators.Find(x => x.Name == name);
        }

        private bool SetIteratorAddDefinition(IteratorAddDefinition definition, string parentBlockName, bool allowReplace)
        {
            FacetDefinition parent = this._facets.Find(x => (x.FacetType == FacetType.Pattern) && (x.Name == parentBlockName));
            if (parent == null)
            {
                throw new Exception($"Parent Pattern: [{parentBlockName}] not found in PvCatalog.");
            }
            parent.Add = definition;

            if (definition.Visibility == Visibility.Global)
            {
                CatalogPredicate<IteratorAddDefinition> predicate = (exists, added) => exists.Name == added.Name;
                string errorText = $"Add for Enumerator with name [{definition.Name}] already exists and can NOT be replaced.";
                return this._iteratorAdds.SetDefinition(definition, predicate, allowReplace, errorText);
            }

            return false;
        }

        private bool SetEnumeratorAddDefinition(EnumeratorAddDefinition definition, string parentBlockName, bool allowReplace)
        {
            CohortDefinition parent = this._cohorts.Find(x => x.Name == parentBlockName);
            if (parent == null)
            {
                throw new Exception($"Parent Cohort: [{parentBlockName}] not found in PvCatalog.");
            }
            parent.Add = definition;

            if (definition.Visibility == Visibility.Global)
            {
                CatalogPredicate<EnumeratorAddDefinition> predicate = (exists, added) => exists.Name == added.Name;
                string errorText = $"Add for Enumerator with name [{definition.Name}] already exists and can NOT be replaced.";
                return this._enumeratorAdds.SetDefinition(definition, predicate, allowReplace, errorText);
            }

            return false;
        }

        private bool SetIteratorRemoveDefinition(IteratorRemoveDefinition definition, string parentBlockType, string parentBlockName, bool allowReplace)
        {
            FacetDefinition parent = this._facets.Find(x => (x.FacetType == FacetType.Pattern) && (x.Name == parentBlockName));
            if (parent == null)
            {
                throw new Exception();
            }
            parent.Remove = definition;

            if (definition.Visibility == Visibility.Global)
            {
                CatalogPredicate<IteratorRemoveDefinition> predicate = (exists, added) => exists.Name == added.Name;
                string errorText = $"Remove for Enumerator with name [{definition.Name}] already exists and can NOT be replaced.";
                return this._iteratorRemoves.SetDefinition(definition, predicate, allowReplace, errorText);
            }

            return false;
        }

        private bool SetEnumeratorRemoveDefinition(EnumeratorRemoveDefinition definition, string parentBlockType, string parentBlockName, bool allowReplace)
        {
            CohortDefinition parent = this._cohorts.Find(x => x.Name == parentBlockName);
            if (parent == null)
            {
                throw new Exception();
            }
            parent.Remove = definition;

            if (definition.Visibility == Visibility.Global)
            {
                CatalogPredicate<EnumeratorRemoveDefinition> predicate = (exists, added) => exists.Name == added.Name;
                string errorText = $"Remove for Enumerator with name [{definition.Name}] already exists and can NOT be replaced.";
                return this._enumeratorRemoves.SetDefinition(definition, predicate, allowReplace, errorText);
            }

            return false;
        }
    }
}