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
        public PropertyType PropertyType { get; private set; }
        // REFACTOR: how'z about ... ParentName? since I already (now) know the PropertyType
        public string FacetName { get; set; }
        public string PatternName { get; set; }
        public string CohortName { get; set; }

        public PropertyDefinition(string name, PropertyType type) : base(name)
        {
            this.PropertyType = type;
        }

        public void Validate(object validationContext)
        {
            if (string.IsNullOrWhiteSpace(this.Name))
                throw new Exception("Proviso Validation Error. [Property] -Name can NOT be null/empty.");
        }
    }

    public class CohortDefinition : DefinitionBase, IValidated
    {
        public string FacetName { get; set; }

        public EnumeratorAddDefinition Add { get; internal set; }
        public EnumeratorRemoveDefinition Remove { get; internal set; }

        public CohortDefinition(string name) : base(name) { }

        public void Validate(object validationContext)
        {
            if (string.IsNullOrWhiteSpace(this.Name))
                throw new Exception("Proviso Validation Error. [Cohort] -Name can NOT be null/empty.");

            if (string.IsNullOrWhiteSpace(this.FacetName))
                throw new Exception("Proviso Validation Error. [Cohort] blocks must be within a Parent [Facet] block.");
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
        public string Name { get; private set; }
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
        public string Name { get; private set; }
        public ModalityType Modality { get; private set; }
        public Visibility Visibility { get; private set; }
        public Impact Impact { get; private set; }
        public ScriptBlock ScriptBlock { get; private set; }

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
        public string FacetName { get; set; }
        public string CohortName { get; set; }

        public string Name { get; private set; }
        public bool IsGlobal { get; private set; }
        public ScriptBlock Enumerate { get; set; }
        public string OrderBy { get; set; }

        public EnumeratorDefinition(string name, bool isGlobal)
        {
            this.Name = name;
            this.IsGlobal = isGlobal;
        }

        public void Validate(object validationContext)
        {
            if (string.IsNullOrWhiteSpace(this.Name))
                throw new Exception("Proviso Validation Error. [Enumerator] -Name can NOT be null/empty.");

            if (IsGlobal)
            {
                // TODO: Implement AND set up some rudimentar unit tests..
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
        public string SurfaceName { get; set; }
        public string AspectName { get; set; }
        public Membership MembershipType { get; private set; }
        public string SpecifiedIterator { get; private set; }

        public IteratorAddDefinition Add { get; internal set; }
        public IteratorRemoveDefinition Remove { get; internal set; }

        public string Id { get; private set; }
        public FacetType FacetType { get; private set; }

        public FacetDefinition(string name, string id, FacetType type) : base(name)
        {
            this.Id = string.IsNullOrWhiteSpace(id) ? Guid.NewGuid().ToString() : id;
            this.FacetType = type;
        }

        public void SetPatternMembershipType(Membership membershipType)
        {
            if (this.FacetType == FacetType.Scalar)
                throw new InvalidOperationException();

            this.MembershipType = membershipType;
        }

        public void SetPatternIteratorFromParameter(string iteratorName)
        {
            if (this.FacetType == FacetType.Scalar)
                throw new InvalidOperationException();

            this.SpecifiedIterator = iteratorName;
        }

        public void Validate(object validationContext)
        {
            if (string.IsNullOrWhiteSpace(this.Name))
                throw new Exception("Proviso Validation Error. [Facet] -Name can NOT be null/empty.");

            // TODO: if there's an Aspect, there MUST also be a Surface. (But the inverse is not true/required.)
        }
    }

    public class IteratorDefinition : IValidated
    {
        public DateTime Created => DateTime.Now;
        public string SurfaceName { get; set; }
        public string AspectName { get; set; }
        public string PatternName { get; set; }

        public string Name { get; private set; }
        public bool IsGlobal { get; private set; }
        public ScriptBlock Iterate { get; set; }
        public string OrderBy { get; set; }

        public IteratorDefinition(string name, bool isGlobal)
        {
            this.Name = name;
            this.IsGlobal = isGlobal;
        }

        public void Validate(object validationContext)
        {
            // TODO: Implement
        }
    }

    public class AspectDefinition : DefinitionBase, IValidated
    {
        public string SurfaceName { get; set; }

        public AspectDefinition(string name) : base(name) { }

        public void Validate(object validationContext)
        {
            throw new NotImplementedException();
        }
    }

    public class SurfaceDefinition: DefinitionBase, IValidated
    {
        public SurfaceDefinition(string name) : base(name) { }

        public void AddAssert(AssertDefinition added)
        {
            throw new NotImplementedException();
        }

        internal Surface ToSurface()
        {
            throw new NotImplementedException();
        }

        public void Validate(object validationContext)
        {
            // TODO: this'll be roughly the same as for ... Implement|Run Def... 
            throw new NotImplementedException();
        }
    }

    public class ImplementDefinition : DefinitionBase, IValidated
    {
        internal ImplementDefinition(string name) : base(name) { }

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
        public ScriptBlock Setup { get; set; }
        public ScriptBlock Cleanup { get; set; }

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

