using System;
using System.Collections.Generic;
using System.Management.Automation;

namespace Proviso.Core
{
    // TODO: roll this into ... IDeclarable... 
    public interface ITrackable
    {
        DateTime Imported { get; }
        string SourceFile { get; }
    }

    // REFACTOR: In addition to being 'declarable' ... these 'attributes' also
    //      apply to script blocks ... so... IScriptBlockAble? (or something similar)?
    public interface IDeclarable
    {
        string Name { get; }
        string ParentName { get; }
        string ModelPath { get; set; }
        string TargetPath { get; set; }
        bool Skip { get; }
        string SkipReason { get; }
        string DisplayFormat { get; }

        ScriptBlock Expect { get; set; }
        ScriptBlock Extract { get; set; }
        //ScriptBlock Compare { get; }

        void SetDisplayFormat(string format);
        void SetPaths(string model, string target);
        void SetSkipped(string reason);
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

    public interface ISurface
    {
        //string Name { get; }

        bool IsVirtual { get; }
        bool IsPlaceHolder { get; }
    }

    // Not wild about this name: 
    public interface IFacetable
    {
        List<IFacet> Facets { get; }

        void AddFacet(IFacet added);
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
        public string ModelPath { get; set; }
        public string TargetPath { get; set; }
        public bool Skip { get; private set; }
        public string SkipReason { get; private set; }
        public string DisplayFormat { get; private set; }
        public ScriptBlock Expect { get; set; }
        public ScriptBlock Extract { get; set; }

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
    } 
}