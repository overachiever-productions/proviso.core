using System;
using System.Collections.Generic;
using System.Management.Automation;
using Proviso.Core;

namespace Proviso.Core.Models
{
    public class Property : DeclarableBase, IProperty, IBuildValidated
    {
        public PropertyParentType ParentType { get; }
        public PropertyType PropertyType { get; private set; }
        public bool IsCohort { get; }
        public bool IsVirtual { get; }

        public ScriptBlock Compare { get; set; }
        public ScriptBlock Configure { get; set; }

        public Property(string name, PropertyParentType parentType, string parentName) : base(name, parentName)
        {
            this.ParentType = parentType;

            this.PropertyType = PropertyType.Property;
            this.IsCohort = false;
            this.IsVirtual = false;
        }

        public void Validate()
        {
            if (string.IsNullOrWhiteSpace(this.Name))
                throw new Exception("Validation Error. [Property] -Name can NOT be null/empty.");
        }
    }

    public class Cohort : DeclarableBase, IProperty, IBuildValidated
    {
        private List<IProperty> _properties = new List<IProperty>();

        public PropertyParentType ParentType { get; }
        public PropertyType PropertyType { get; }
        public bool IsCohort { get; }
        public bool IsVirtual { get; }

        public List<IProperty> Properties => this._properties;

        public Cohort(string name, string parentName, PropertyParentType parentType) : base(name, parentName)
        {
            this.ParentType = parentType;

            this.PropertyType = PropertyType.Cohort;
            this.IsCohort = true;
            this.IsVirtual = false;
        }

        public void AddCohortProperty(IProperty added)
        {
            if (added.IsCohort)
                throw new InvalidOperationException("Build Error. Cohorts may NOT be nested.");

            if (added.PropertyType == PropertyType.Inclusion)
            {
                if (this._properties.Exists(x => x.PropertyType == PropertyType.Inclusion))
                    throw new InvalidOperationException("Build Error. Cohorts may only contain ONE Inclusion.");
            }

            var iValidated = added as IBuildValidated;
            if (iValidated != null)
                iValidated.Validate();
            
            this._properties.Add(added);
        }

        public void Validate()
        {
            // cohorts ... require a name or don't they? 
        }
    }

    //public class Inclusion : DeclarableBase, IProperty
    //{

    //}


    public class AnonymousProperty : IProperty
    {
        public string Name { get; }
        public string ParentName { get; }
        public PropertyParentType ParentType { get; }
        public PropertyType PropertyType { get; }
        public bool IsCohort { get; }
        public bool IsVirtual { get; }

        public AnonymousProperty(string parentName, PropertyParentType parentType)
        {
            // parentType can only be ... Facet or Cohort, right? 

            this.Name = $"{parentName}.Property";
            this.ParentName = parentName;
            this.ParentType = parentType;

            this.IsVirtual = false; // false != anonymous
            this.IsCohort = false;
        }
    }

    public class VirtualProperty : IProperty
    {
        public string Name { get; }
        public string ParentName { get; }
        public PropertyParentType ParentType { get; }
        public PropertyType PropertyType { get; }
        public bool IsCohort { get; }
        public bool IsVirtual { get; }

        public VirtualProperty(string name, string parentName, PropertyParentType parentType)
        {
            this.Name = name;
            this.ParentName = parentName;
            this.ParentType = parentType;

            this.PropertyType = PropertyType.VirtualProperty;
            this.IsCohort = false;
            this.IsVirtual = false;
        }
    }

    public class VirtualCohort : IProperty
    {
        public string Name { get; }
        public string ParentName { get; }
        public PropertyParentType ParentType { get; }
        public PropertyType PropertyType { get; }
        public bool IsCohort { get; }
        public bool IsVirtual { get; }

        public VirtualCohort(string name, string parentName, PropertyParentType parentType)
        {
            this.Name = name;
            this.ParentName = parentName;
            this.ParentType = parentType;

            this.PropertyType = PropertyType.VirtualCohort;
            this.IsCohort = true;
            this.IsVirtual = true;
        }
    }
}