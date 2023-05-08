using System;
using System.Collections.Generic;

namespace Proviso.Core
{

    // TODO: roll this into ... IDeclarable... 
    public interface ITrackable
    {
        DateTime Imported { get; }
        string SourceFile { get; }
    }

    public interface IDeclarable
    {
        string ParentName { get; }
        string Name { get; }
        string ModelPath { get; }
        string TargetPath { get; }
        bool Skip { get; }
        string SkipReason { get; }
        string DisplayFormat { get; }

        void SetDisplayFormat(string format);
        void SetPaths(string model, string target);
        void SetSkipped(string reason);
        
        // TODO: this stuff only applies to ... Properties? or ... does it also apply to Facets and Aspects? 
        void SetComparisonType(string name);
        void SetExpectFromParameter(object expect);
        void SetExtractFromParameter(object expect);
    }

    public interface IBuildValidated
    {
        public void Validate();
    }

    public interface IProperty
    {
        string Name { get; }
        string ParentName { get; }
        PropertyParentType ParentType { get; }
        PropertyType PropertyType { get; }
        bool IsCohort { get; }
        bool IsVirtual { get; }
    }

    public interface IIterator
    {
        string Name { get; }
        bool IsVirtual { get; }
        IteratorParentType IteratorParentType { get; }
    }

    public interface IFacet
    {
        string Name { get; }
        string Id { get; }
        string ParentName { get; }
        FacetParentType FacetParentType { get; }
        List<IProperty> Properties { get; }

        bool IsPattern { get; }
        bool IsVirtual { get; }
    }

    public interface IPotent {
        Impact Impact { get; }
        bool ThrowOnConfig { get; }
        string MessageToThrow { get; }

        void SetImpact(Impact impact);
        void SetThrowOnConfig(string message);
    }

    public interface IAddable
    {

    }

    public interface IRemovable
    {

    }

    public class DeclarableBase : IDeclarable
    {
        public string ParentName { get; private set; }
        public string Name { get; private set; }
        public string ModelPath { get; private set; }
        public string TargetPath { get; private set; }
        public bool Skip { get; private set; }
        public string SkipReason { get; private set; }
        public string DisplayFormat { get; private set; }

        internal DeclarableBase(string name, string parentName)
        {
            this.Name = name;
            this.ParentName = parentName;

            this.Skip = false;
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

            // TODO: Implement: throw new NotImplementedException();
        }

        public void SetExtractFromParameter(object expect)
        {
            // same as with ... SetExpect... 

            // TODO: Implement: throw new NotImplementedException();
        }
    } 
}