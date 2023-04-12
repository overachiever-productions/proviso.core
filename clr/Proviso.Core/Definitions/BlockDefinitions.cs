using System;
using System.Collections.Generic;
using System.Management.Automation;
using System.Reflection;
using Proviso.Core.Models;

namespace Proviso.Core.Definitions
{
    public interface IValidated
    {
        void Validate(object validationContext);
    }

    public interface IDefinable
    {
        DateTime Created { get; }
        string Name { get; }
        string ModelPath { get; }
        string TargetPath { get; }
        bool Skip { get; }
        string SkipReason { get; }
        Impact Impact { get; }
        string DisplayFormat { get; }

        void SetDisplayFormat(string format);
        void SetPaths(string model, string target);
        void SetSkipped(string reason);
        void SetImpact(Impact impact);
        void SetComparisonType(string name);
        void SetExpectFromParameter(object expect);
        void SetExtractFromParameter(object expect);
        void SetThrowOnConfig(string message);
    }

    public class DefinitionBase : IDefinable
    {
        public DateTime Created => DateTime.Now;
        public string Name { get; private set; }
        public string ModelPath { get; private set; }
        public string TargetPath { get; private set; }
        public bool Skip { get; private set; }
        public string SkipReason { get; private set; }
        public Impact Impact { get; private set; }
        public string DisplayFormat { get; private set; }

        internal DefinitionBase(string name)
        {
            this.Skip = false;
            this.Impact = Impact.None;

            this.Name = name;
        }

        public void SetDisplayFormat(string format)
        {
            if (!string.IsNullOrWhiteSpace(format))
                this.DisplayFormat = format;
        }

        public void SetPaths(string model, string target)
        {
            if (!string.IsNullOrWhiteSpace(model))
                this.ModelPath = model;
            if (!string.IsNullOrWhiteSpace(target))
                this.TargetPath = target;
        }

        public void SetSkipped(string reason)
        {
            this.Skip = true;
            this.SkipReason = reason;
        }

        public void SetImpact(Impact impact)
        {
            this.Impact = impact;
        }

        public void SetComparisonType(string name)
        {
            throw new NotImplementedException();
        }

        public void SetExpectFromParameter(object expect)
        {
            // NOTE: I've been tempted to think about using ... PSON code/examples as a way to figure out what TYPE of object we've got here. 
            //      but i don't NEED to. 
            //      instead, I need to simply STORE this 'value' as ... an OBJECT 
            //      and let that get passed on DOWN the line ... until it becomes a 'code block' of return $object;
            //          COMPARISONS (i.e., the Compare func) will handle object types, etc. 
        }

        public void SetExtractFromParameter(object expect)
        {
            // same as with ... SetExpect... 
        }

        public void SetThrowOnConfig(string message)
        {
            throw new NotImplementedException("-ThrowOnConfig has not been implemented in DefinitionsBase (clr).");
        }
    }

    public class PropertyDefinition : DefinitionBase, IValidated
    {
        public PropertyParentType ParentType { get; private set; }
        public string ParentName { get; set; }

        public ScriptBlock Expect { get; set; }
        public ScriptBlock Extract { get; set; }
        public ScriptBlock Compare { get; set; }
        public ScriptBlock Configure { get; set; }

        public PropertyDefinition(string name, PropertyParentType parentType, string parentName) : base(name)
        {
            this.ParentType = parentType;
            this.ParentName = parentName;
        }

        public void Validate(object validationContext)
        {
            if (string.IsNullOrWhiteSpace(this.Name))
                throw new Exception("Proviso Validation Error. [Property] -Name can NOT be null/empty.");
        }
    }

    public class CohortDefinition : DefinitionBase, IValidated
    {
        private List<PropertyDefinition> _properties = new List<PropertyDefinition>();

        public PropertyParentType ParentType { get; private set; }
        public string ParentName { get; set; }

        public EnumeratorDefinition Enumerate { get; private set; }
        public EnumeratorAddDefinition Add { get; set; }
        public EnumeratorRemoveDefinition Remove { get; set; }

        public CohortDefinition(string name, PropertyParentType parentType, string parentName) : base(name)
        {
            this.ParentType = parentType;
            this.ParentName = parentName;
        }

        public void Validate(object validationContext)
        {
            if (string.IsNullOrWhiteSpace(this.Name))
                throw new Exception("Proviso Validation Error. [Cohort] -Name can NOT be null/empty.");

            if (this.ParentType != PropertyParentType.Cohorts)
            {
                if(string.IsNullOrWhiteSpace(this.ParentName))
                    throw new Exception("Proviso Validation Error. Non-Globally-Defined [Cohort] blocks must be within a Parent [Facet] or [Pattern] block.");
            }
        }

        public void AddChildProperty(PropertyDefinition child)
        {
            child.Validate(null);
            this._properties.Add(child);
        }

        public void AddEnumerate(EnumeratorDefinition enumerate)
        {
            enumerate.Validate(null);
            this.Enumerate = enumerate;
        }
    }

    public interface IAddDefinition
    {
        DateTime Created { get; }
        string Name { get; }
        ModalityType Modality { get; }
        Visibility Visibility { get; }
        ScriptBlock ScriptBlock { get; }
    }

    public class AddDefinitionBase : IAddDefinition
    {
        public DateTime Created => DateTime.Now;
        public string Name { get; internal set; }
        public ModalityType Modality { get; private set; }
        public Visibility Visibility { get; private set; }
        public ScriptBlock ScriptBlock { get; private set; }

        internal AddDefinitionBase(string name, ScriptBlock block, ModalityType type)
        {
            if (!string.IsNullOrEmpty(name))
            {
                this.Name = name;
                this.Visibility = Visibility.Global;
            }
            else
                this.Visibility = Visibility.Anonymous;

            this.ScriptBlock = block;
            this.Modality = type;
        }
    }

    public interface IRemoveDefinition
    {
        DateTime Created { get; }
        string Name { get; }
        ModalityType Modality { get; }
        Visibility Visibility { get; }
        Impact Impact { get; }
        ScriptBlock ScriptBlock { get; }
    }

    public class RemoveDefinitionBase : IRemoveDefinition
    {
        public DateTime Created => DateTime.Now;
        public string Name { get; internal set; }
        public ModalityType Modality { get; private set; }
        public Visibility Visibility { get; private set; }
        public Impact Impact { get; private set; }
        public ScriptBlock ScriptBlock { get; set; }

        internal RemoveDefinitionBase(string name, Impact impact, ScriptBlock block, ModalityType modality)
        {
            if (!string.IsNullOrEmpty(name))
            {
                this.Name = name;
                this.Visibility = Visibility.Global;
            }
            else
                this.Visibility = Visibility.Anonymous;

            this.Impact = impact;
            this.ScriptBlock = block;
            this.Modality = modality;
        }
    }

    public class EnumeratorAddDefinition : AddDefinitionBase
    {
        public EnumeratorAddDefinition(string name, ScriptBlock block) : base(name, block, ModalityType.Enumerator) { }
    }

    public class IteratorAddDefinition : AddDefinitionBase
    {
        public IteratorAddDefinition(string name, ScriptBlock block) : base(name, block, ModalityType.Iterator) { }
    }

    public class EnumeratorRemoveDefinition : RemoveDefinitionBase
    {
        public EnumeratorRemoveDefinition(string name, Impact impact, ScriptBlock block) : base(name, impact, block, ModalityType.Enumerator) { }
    }

    public class IteratorRemoveDefinition : RemoveDefinitionBase
    {
        public IteratorRemoveDefinition(string name, Impact impact, ScriptBlock block) : base(name, impact, block, ModalityType.Iterator) { }
    }

    public class EnumeratorDefinition : IValidated
    {
        public DateTime Created => DateTime.Now;
        public EnumeratorParentType ParentType { get; private set; }
        public string ParentName { get; private set; }

        public string Name { get; private set; }
        public bool IsGlobal { get; private set; }
        public ScriptBlock Enumerate { get; set; }
        public string OrderBy { get; set; }

        public EnumeratorDefinition(string name, bool isGlobal, EnumeratorParentType parentType, string parentName)
        {
            this.Name = name;
            this.IsGlobal = isGlobal;
            this.ParentType = parentType;
            this.ParentName = parentName;
        }

        public void Validate(object validationContext)
        {
            if (string.IsNullOrWhiteSpace(this.Name))
                throw new Exception("Proviso Validation Error. [Enumerator] -Name can NOT be null/empty.");

            if (IsGlobal)
            {
                // TODO: Implement AND set up some rudimentary unit tests..
                //  e.g., globals can't have facet/cohort names
            }
            else
            {
                // TODO: Implement AND set up some rudimentar unit tests..
                //  on the other hand... anonymous ... must have cohort AND facet names
            }
        }
    }

    public class FacetDefinition : DefinitionBase, IValidated
    {
        private List<PropertyDefinition> _properties = new List<PropertyDefinition>();
        private List<CohortDefinition> _cohorts = new List<CohortDefinition>();
        private List<IteratorDefinition> _iterators = new List<IteratorDefinition>();
        private List<string> _namedIterators = new List<string>();
        private List<IteratorAddDefinition> _adds = new List<IteratorAddDefinition>();
        private List<IteratorRemoveDefinition> _removes = new List<IteratorRemoveDefinition>();

        public string ParentName { get; private set; }
        public FacetParentType ParentType { get; private set; }

        public Membership MembershipType { get; private set; }

        //public string SpecifiedIterator { get; private set; }

        // TODO: specified iterators and iterator adds/removes need to be able to be PLURAL.
        //public IteratorAddDefinition Add { get; internal set; }
        //public IteratorRemoveDefinition Remove { get; internal set; }

        public string Id { get; private set; }
        public FacetType FacetType { get; private set; }

        public FacetDefinition(string name, string id, FacetType type, FacetParentType parentType, string parentName) : base(name)
        {
            this.Id = string.IsNullOrWhiteSpace(id) ? Guid.NewGuid().ToString() : id;
            this.FacetType = type;
            this.ParentName = parentName;
            this.ParentType = parentType;
        }

        public void SetPatternMembershipType(Membership membershipType)
        {
            if (this.FacetType == FacetType.Scalar)
                throw new InvalidOperationException();

            this.MembershipType = membershipType;
        }

        public void SetPatternIteratorFromParameter(string iteratorName)
        {
            // TODO: this NEEDS to be an array... or... this info needs to be stored as arrays... 
            //      i.e., powershell can LOOP through the inputs and add if/as needed... or, i can pass a string array HERE. 
            //      either way, there needs to be an array/list of specified iterators.
            if (this.FacetType == FacetType.Scalar)
                throw new InvalidOperationException();

            //this.SpecifiedIterator = iteratorName;
        }

        public void Validate(object validationContext)
        {
            if (string.IsNullOrWhiteSpace(this.Name)) // TODO: this error is hard-coded as Facet - could be Facet OR Pattern.
                throw new Exception("Proviso Validation Error. [Facet] -Name can NOT be null/empty.");

            // TODO: if there's an Aspect, there MUST also be a Surface. (But the inverse is not true/required.)
        }

        public void AddChildProperty(PropertyDefinition child)
        {
            child.Validate(null);
            this._properties.Add(child);
        }

        public void AddChildCohort(CohortDefinition child)
        {
            child.Validate(null);
            this._cohorts.Add(child);
        }

        public void AddIterate(IteratorDefinition iterator)
        {
            if (this.FacetType == FacetType.Scalar)
                throw new InvalidOperationException();

            // Patterns can have _UP TO_ 1x anonymous iterate block. 
            if (string.IsNullOrWhiteSpace(iterator.Name))
                iterator.Name = "_ANONYMOUS_";

            var exists = this._iterators.Find(x => x.Name == iterator.Name);
            if(exists != null)
                throw new InvalidOperationException();

            this._iterators.Add(iterator);
        }

        public void AddIterateAdd(IteratorAddDefinition added)
        {
            if (string.IsNullOrWhiteSpace(added.Name))
                added.Name = "_ANONYMOUS_";

            var exists = this._adds.Find(x => x.Name == added.Name);
            if (exists != null)
                throw new InvalidOperationException();

            this._adds.Add(added);
        }

        public void AddIterateRemove(IteratorRemoveDefinition added)
        {
            if (string.IsNullOrWhiteSpace(added.Name))
                added.Name = "_ANONYMOUS_";

            var exists = this._removes.Find(x => x.Name == added.Name);
            if (exists != null)
                throw new InvalidOperationException();

            this._removes.Add(added);
        }
    }

    public class IteratorDefinition : IValidated
    {
        public DateTime Created => DateTime.Now;
        public IteratorParentType ParentType { get; private set; }
        public string ParentName { get; private set; }

        public string Name { get; internal set; }
        public bool IsGlobal { get; private set; }
        public ScriptBlock Iterate { get; set; }
        public string OrderBy { get; set; }

        public IteratorDefinition(string name, bool isGlobal, IteratorParentType parentType, string parentName)
        {
            this.Name = name;
            this.IsGlobal = isGlobal;
            this.ParentType = parentType;
            this.ParentName = parentName;
        }

        public void Validate(object validationContext)
        {
            // TODO: Implement
        }
    }

    public class AspectDefinition : DefinitionBase, IValidated
    {
        private readonly List<FacetDefinition> _facets = new List<FacetDefinition>();

        public string ParentName { get; private set; }

        public AspectDefinition(string name, string parentName) : base(name)
        {
            this.ParentName = parentName;
        }

        public void AddFacet(FacetDefinition added)
        {
            added.Validate(null);

            var exists = this._facets.Find(x => x.Name == added.Name);
            if (exists != null)
                throw new InvalidOperationException($"Aspect [{base.Name}] already contains a Facet or Pattern with the name: [{added.Name}]. Pattern/Facet names must be UNIQUE per Aspect.");

            this._facets.Add(added);
        }


        public void Validate(object validationContext)
        {
            // TODO: Implement
        }
    }

    public class SetupOrCleanupDefinition
    {
        public DateTime Created => DateTime.Now;
        public string  ParentName { get; private set; }
        public RunbookOrSurface RunbookOrSurface { get; private set; }
        public SetupOrCleanup SetupOrCleanup { get; private set; }
        public bool Skip { get; private set; }
        public string SkipReason { get; private set; }
        public ScriptBlock ScriptBlock { get; set; }

        public SetupOrCleanupDefinition(RunbookOrSurface runbookOrSurface, SetupOrCleanup setupOrCleanup, string parentName)
        {
            this.RunbookOrSurface = runbookOrSurface;
            this.SetupOrCleanup = setupOrCleanup;
            this.ParentName = parentName;
        }
    }

    public class SurfaceDefinition: DefinitionBase, IValidated
    {
        private readonly List<FacetDefinition> _facets = new List<FacetDefinition>();
        private readonly List<AspectDefinition> _aspects = new List<AspectDefinition>();

        public SetupOrCleanupDefinition Setup { get; set; }
        public SetupOrCleanupDefinition Cleanup { get; set; }

        public SurfaceDefinition(string name) : base(name) { }

        public void AddAssert(AssertDefinition added)
        {
            throw new NotImplementedException();
        }

        public void AddFacet(FacetDefinition added)
        {
            added.Validate(null);

            var exists = this._facets.Find(x => x.Name == added.Name);
            if (exists != null)
                throw new InvalidOperationException($"Surface [{base.Name}] already contains a Facet or Pattern with the name: [{added.Name}]. Pattern/Facet names must be UNIQUE per Surface.");

            this._facets.Add(added);
        }

        public void AddAspect(AspectDefinition added)
        {
            added.Validate(null);

            this._aspects.Add(added);
        }

        //internal Surface ToSurface()
        //{
        //    throw new NotImplementedException();
        //}

        public void Validate(object validationContext)
        {
            // TODO: Implement
            // TODO: this'll be roughly the same as for ... Implement|Run Def... 
            //throw new NotImplementedException();
        }
    }

    public class ImplementDefinition : DefinitionBase, IValidated
    {
        public ImplementDefinition(string name) : base(name) { }

        public void Validate(object validationContext)
        {
            throw new NotImplementedException();
        }
    }

    public class AssertDefinition
    {
        public DateTime Created => DateTime.Now;
        public string Name { get; private set; }
        public string FailureMessage { get; private set; }
        public bool IsNegated { get; private set; }
        public bool ConfigureOnly { get; private set; }

        public ScriptBlock ScriptBlock { get; set; }
        public bool IsIgnored { get; private set; }
        public string IgnoredReason { get; private set; }

        public AssertDefinition(string name, string failureMessage, bool negated, bool configureOnly)
        {
            this.Name = name;
            this.FailureMessage = failureMessage;
            this.IsNegated = negated;
            this.ConfigureOnly = configureOnly;
        }

        public void SetIgnored(string reason)
        {
            this.IsIgnored = true;
            this.IgnoredReason = reason; // this can totally be blank/null at this point... 
        }
    }

    public class RunbookDefinition : IValidated
    {
        private List<AssertDefinition> _assertDefinitions = new List<AssertDefinition>();
        private List<ImplementDefinition> _implementDefinitions = new List<ImplementDefinition>();

        public DateTime Created => DateTime.Now;
        public string Name { get; private set; }
        public SetupOrCleanupDefinition Setup { get; set; }
        public SetupOrCleanupDefinition Cleanup { get; set; }

        public List<ImplementDefinition> Implements => this._implementDefinitions;
        public List<AssertDefinition> AssertDefinitions => this._assertDefinitions;

        public RunbookDefinition(string name)
        {
            this.Setup = null;
            this.Cleanup = null;

            this.Name = name;
        }

        public void AddAssert(AssertDefinition added)
        {
            // TODO: execute added.Validate();
            this._assertDefinitions.Add(added);
        }

        public void AddFacetImplementationReference(ImplementDefinition added)
        {
            // TODO: MAYBE? execute added.Validate();
            this._implementDefinitions.Add(added);
        }

        public void Validate(object validationContext)
        {
            // TODO: is there anything to validate here? 
            // maybe that the COUNT of Implement defs is > 0?
            //  and... make sure to allow for -skip/disabled as a Implement params.
            //      then to check that ALL are not disabled. (Actually, if they're all Implement "blah" -Skip ... 
            //      i think i just report on that at run time. 
        }
    }
}