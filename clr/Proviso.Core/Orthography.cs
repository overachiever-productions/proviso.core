using System;
using System.Linq;
using System.Collections.Generic;
using Proviso.Core.Definitions;

namespace Proviso.Core
{
    public class Orthography
    {
        private readonly List<EnumeratorDefinition> _enumerators = new List<EnumeratorDefinition>();
        private readonly List<EnumeratorAddDefinition> _enumeratorAdds = new List<EnumeratorAddDefinition>();
        private readonly List<EnumeratorRemoveDefinition> _enumeratorRemoves = new List<EnumeratorRemoveDefinition>();
        private readonly List<IteratorDefinition> _iterators = new List<IteratorDefinition>();
        private readonly List<IteratorAddDefinition> _iteratorAdds = new List<IteratorAddDefinition>();
        private readonly List<IteratorRemoveDefinition> _iteratorRemoves = new List<IteratorRemoveDefinition>();
        private readonly List<RunbookDefinition> _runbooks = new List<RunbookDefinition>();
        private readonly List<FacetDefinition> _facets = new List<FacetDefinition>();
        //private readonly List<AspectDefinition> _aspects = new List<AspectDefinition>();
        private readonly List<SurfaceDefinition> _surfaces = new List<SurfaceDefinition>();

        // REFACTOR: looks like I lost my mind... cohorts and properties should ONLY BE children of their PARENT Facet... 
        //      er, well... did I ever decide to make properties|cohorts 'borrowable' from elsewhere?
        //      if so, then... they got to BOTH their parents and here... (but I'm going to need some sort of import/borrow/use syntax/func. 
        //      i THINK i was ONLY going to allow FACETS to be re-used like this (from one surface to the next)... but ... maybe I was going to do the same with props? (cohorts?)
        private readonly List<CohortDefinition> _cohorts = new List<CohortDefinition>();
        private readonly List<PropertyDefinition> _properties = new List<PropertyDefinition>();

        private List<Taxonomy> _grammar;
        private Stack<Taxonomy> _stack;
        private Stack<string> _namesStack;
        private Dictionary<string, string> _currentBlocks;

        private Taxonomy _currentParent;
        private Taxonomy _currentNode; // REFACTOR: insanely enough, I NEVER use this. 

        public int CurrentDepth => this._stack.Count;

        public static Orthography Instance => new Orthography();

        private Orthography()
        {
            this._grammar = Taxonomy.Grammar();
            this._stack = new Stack<Taxonomy>();
            this._namesStack = new Stack<string>();
            this._currentBlocks = new Dictionary<string, string>();

            this._currentParent = null;
            this._currentNode = null;
        }

        // REFACTOR: each of these GetCurrentX() needs to be renamed to GetCurrentXName().
        public string GetCurrentRunbook()
        {
            return this.GetCurrentBlockNameByType("Runbook");
        }

        public string GetCurrentSurface()
        {
            return this.GetCurrentBlockNameByType("Surface");
        }

        public string GetCurrentAspect()
        {
            return this.GetCurrentBlockNameByType("Aspect");
        }

        public string GetCurrentFacet()
        {
            return this.GetCurrentBlockNameByType("Facet");
        }

        public string GetCurrentPattern()
        {
            return this.GetCurrentBlockNameByType("Pattern");
        }

        public string GetCurrentCohort()
        {
            return this.GetCurrentBlockNameByType("Cohort");
        }

        public string GetCurrentBlockName()
        {
            if(this._namesStack.Count > 0)
                return this._namesStack.Peek();

            return "";
        }

        public string GetParentBlockName()
        {
            if (this._namesStack.Count > 1)
            {
                return this._namesStack.Skip(1).First();
            }

            return "";
        }

        public string GetCurrentBlockNameByType(string type)
        {
            if (this._currentBlocks.ContainsKey(type))
                return this._currentBlocks[type];

            return null;
        }

        public string GetCurrentBlockType()
        {
            if (this._stack.Count > 0)
            {
                var current = this._stack.Peek();  // i.e., CURRENT is what's on the TOP of the stack.
                return current.NodeName;
            }

            return "";
        }

        public string GetParentBlockType()
        {
            if (this._stack.Count > 1)
            {
                var parent = this._stack.Skip(1).First();
                return parent.NodeName;
            }

            return "";
        }

        public string GetGrandParentBlockType()
        {
            if (this._stack.Count > 2)
            {
                var grandparent = this._stack.Skip(2).First();
                return grandparent.NodeName;
            }

            return "";
        }

        public string GetGrandParentBlockName()
        {
            if (this._namesStack.Count > 2)
            {
                return this._namesStack.Skip(2).First();
            }

            return "";
        }

        public void EnterBlock(string blockType, string blockName)
        {
            Taxonomy taxonomy = this._grammar.Find(t => t.NodeName == blockType);
            if (taxonomy == null)
                throw new InvalidOperationException($"Unsupported ScriptBlock: [{blockType}].");

            if (this._currentParent == null)
            {
                if (!taxonomy.Rootable)
                    throw new InvalidOperationException($"ScriptBlock [{blockType}] can NOT be a stand-alone (root-level) block.");

                this._currentParent = taxonomy;
                this.PushCurrentTaxonomy(taxonomy, blockName);

                return;
            }

            if (taxonomy.RequiresName && string.IsNullOrWhiteSpace(blockName))
                throw new Exception($"A -Name is required for block-parentType: [{blockType}].");

            if (!taxonomy.NameAllowed && !string.IsNullOrWhiteSpace(blockName))
                throw new Exception($"[{blockType}] may NOT have a -Name (current -Name is [{blockName}]).");

            Taxonomy parent = this._stack.Peek();
            if (!taxonomy.AllowedParents.Contains(parent.NodeName))
                throw new InvalidOperationException(
                    $"ScriptBlock [{blockType}] can NOT be a child of: [{parent.NodeName}].");
    
           // TODO: account for wildcards here. (and... just use Regex.IsMatch(currentBlockName, taxonomy.WildcardPattern)  ...    
           // TODO: also, I THINK this is/could-be where I account for .AllowedChildren? (if not, remove them from grammar).

            this.PushCurrentTaxonomy(taxonomy, blockName);
        }

        // TODO: Either REQUIRE blockName to be the same as what was handed in via Enter (as an additional validation/test)
        //          OR, remove it from being an argument. One or the other. 
        //      EXCEPT: Setup/Assertions/Cleanup (for both Runbooks AND Surfaces) do NOT have names (and can't have names).
        public void ExitBlock(string blockType, string blockName)
        {
            Taxonomy taxonomy = this._grammar.Find(t => t.NodeName == blockType);
            if (taxonomy == null)
                throw new InvalidOperationException($"Proviso Framework Error. Unexpected ScriptBlock Terminator: [{blockType}].");

            this._stack.Pop();
            this._currentBlocks[blockType] = null;
            this._namesStack.Pop();

            if (this._stack.Count > 0)
            {
                Taxonomy previous = this._stack.Peek();
                this._currentNode = previous;
                
            }
            else
            {
                this._currentNode = null;
                this._currentParent = null;
            } 
        }

        private void PushCurrentTaxonomy(Taxonomy current, string blockName)
        {
            this._currentNode = current;
            this._stack.Push(current);

            this._namesStack.Push(blockName);

            if (current.Tracked)
            {
                if (this._currentBlocks.ContainsKey(current.NodeName))
                    this._currentBlocks[current.NodeName] = blockName;
                else 
                    this._currentBlocks.Add(current.NodeName, blockName);
            }
        }

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
            string errorText = $"Surface: [{definition.Name}] already exists and can NOT be replaced. Ensure unique surface names and/or allow global replacement override.";
            return this._surfaces.SetDefinition(definition, predicate, allowReplace, errorText);
        }

        //public bool StoreAspectDefinition(AspectDefinition definition, bool allowReplace)
        //{
        //    definition.Validate(null);

        //    CatalogPredicate<AspectDefinition> predicate = (exists, added) => (exists.Name == added.Name) && (exists.ParentName == added.ParentName);
        //    string errorText = $"Aspect: [{definition.Name}] already exists within Surface: [{definition.ParentName}] and can NOT be replaced. Ensure unique Aspect names (within Surfaces) and/or allow global replacement override.";
        //    return this._aspects.SetDefinition(definition, predicate, allowReplace, errorText);
        //}

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

            CatalogPredicate<CohortDefinition> predicate = (exists, added) => (exists.Name == added.Name) && (exists.ParentName == added.ParentName);
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

        public bool StoreAddDefinition(IAddDefinition definition, bool allowReplace)
        {
            switch (definition.Modality)
            {
                case ModalityType.Enumerator:
                    return this.SetEnumeratorAddDefinition((EnumeratorAddDefinition)definition, allowReplace);
                case ModalityType.Iterator:
                    return this.SetIteratorAddDefinition((IteratorAddDefinition)definition, allowReplace);
                default:
                    throw new Exception("Proviso Framework Error. Invalid Modality Specified for StoreAddDefinition().");
            }
        }

        public bool StoreRemoveDefinition(IRemoveDefinition definition, bool allowReplace)
        {
            switch (definition.Modality)
            {
                case ModalityType.Enumerator:
                    return this.SetEnumeratorRemoveDefinition((EnumeratorRemoveDefinition)definition, allowReplace);
                case ModalityType.Iterator:
                    return this.SetIteratorRemoveDefinition((IteratorRemoveDefinition)definition, allowReplace);
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

        public FacetDefinition GetFacetDefinitionByName(string name, string parentName)
        {
            return this._facets.Find(x => x.Name == name && x.ParentName == parentName);
        }

        public FacetDefinition GetFacetDefinitionById(string id)
        {
            return this._facets.Find(x => x.Id == id);
        }

        public CohortDefinition GetCohortDefinition(string name, string parentName)
        {
            return this._cohorts.Find(x => x.Name == name && x.ParentName == parentName);
        }

        public PropertyDefinition GetPropertyDefinition(string name, string parentName)
        {
            return this._properties.Find(x => x.Name == name && x.ParentName == parentName);
        }

        public EnumeratorDefinition GetEnumeratorDefinition(string name)
        {
            return this._enumerators.Find(x => x.Name == name);
        }

        public EnumeratorAddDefinition GetEnumeratorAddDefinition(string name)
        {
            return this._enumeratorAdds.Find(x => x.Name == name);
        }

        private bool SetEnumeratorAddDefinition(EnumeratorAddDefinition definition, bool allowReplace)
        {
            if (definition.Visibility == Visibility.Global)
            {
                CatalogPredicate<EnumeratorAddDefinition> predicate = (exists, added) => exists.Name == added.Name;
                string errorText = $"Add for Enumerator with name [{definition.Name}] already exists and can NOT be replaced.";
                return this._enumeratorAdds.SetDefinition(definition, predicate, allowReplace, errorText);
            }

            return false;
        }

        private bool SetEnumeratorRemoveDefinition(EnumeratorRemoveDefinition definition, bool allowReplace)
        {
            if (definition.Visibility == Visibility.Global)
            {
                CatalogPredicate<EnumeratorRemoveDefinition> predicate = (exists, added) => exists.Name == added.Name;
                string errorText = $"Remove for Enumerator with name [{definition.Name}] already exists and can NOT be replaced.";
                return this._enumeratorRemoves.SetDefinition(definition, predicate, allowReplace, errorText);
            }

            return false;
        }

        private bool SetIteratorAddDefinition(IteratorAddDefinition definition, bool allowReplace)
        {
            if (definition.Visibility == Visibility.Global)
            {
                CatalogPredicate<IteratorAddDefinition> predicate = (exists, added) => exists.Name == added.Name;
                string errorText = $"Add for Enumerator with name [{definition.Name}] already exists and can NOT be replaced.";
                return this._iteratorAdds.SetDefinition(definition, predicate, allowReplace, errorText);
            }

            return false;
        }

        private bool SetIteratorRemoveDefinition(IteratorRemoveDefinition definition, bool allowReplace)
        {
            if (definition.Visibility == Visibility.Global)
            {
                CatalogPredicate<IteratorRemoveDefinition> predicate = (exists, added) => exists.Name == added.Name;
                string errorText = $"Remove for Enumerator with name [{definition.Name}] already exists and can NOT be replaced.";
                return this._iteratorRemoves.SetDefinition(definition, predicate, allowReplace, errorText);
            }

            return false;
        }


    }
}