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
        public bool IsCollection { get; }
        public bool IsVirtual { get; }

        public ScriptBlock Compare { get; set; }
        public ScriptBlock Configure { get; set; }

        public Property(string name, PropertyParentType parentType, string parentName) : base(name, parentName)
        {
            this.ParentType = parentType;

            this.PropertyType = PropertyType.Property;
            this.IsCollection = false;
            this.IsVirtual = false;
        }

        public void Validate()
        {
            if (string.IsNullOrWhiteSpace(this.Name))
                throw new Exception("Validation Error. [Property] -Name can NOT be null/empty.");
        }

        public IProperty GetInstance()
        {
            return (Property)this.MemberwiseClone();
        }
    }

    public class Collection : DeclarableBase, IProperty, IBuildValidated
    {
        private List<IProperty> _properties = new List<IProperty>();

        public PropertyParentType ParentType { get; }
        public PropertyType PropertyType { get; }
        public bool IsCollection { get; }
        public bool IsVirtual { get; }

        public Membership Membership { get; private set; }
        public List<IProperty> Properties => this._properties;

        public Collection(string name, PropertyParentType parentType, string parentName) : base(name, parentName)
        {
            this.ParentType = parentType;

            this.PropertyType = PropertyType.Collection;
            this.IsCollection = true;
            this.IsVirtual = false;
        }

        public void AddMemberProperty(IProperty added)
        {
            if (added.IsCollection)
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

        public void SetMembership(Membership concrete)
        {
            // TODO: I might need to reframe this method to allow IMembership - so'z I can pass in VIRTUAL memberships (i.e., promises)
            //      vs what I have now - which is JUST the ability to specify concrete memberships.

            this.Membership = concrete;
        }

        public void Validate()
        {
            // might just be a check to see if we've got the right details for our Membership - i.e., if membership = -Strict/-Naive
            //      do we have the right methods/blocks (e.g., we're always going to need a List{} block... 
            //      and always going to need an Add{} block ... but only need a Remove{} block if -Strict 
            //      and so on... 
        }

        public IProperty GetInstance()
        {
            var output = (Collection)this.MemberwiseClone();

            output.ClearProperties();
            foreach (IProperty prop in this.Properties)
                output.AddMemberProperty(prop.GetInstance());

            return output;
        }

        private void ClearProperties()
        {
            this._properties = new List<IProperty>();
        }
    }

    //public class Inclusion : DeclarableBase, IProperty
    //{

    //}

    public class AnonymousProperty : DeclarableBase, IProperty
    {
        public PropertyParentType ParentType { get; }
        public PropertyType PropertyType { get; }
        public bool IsCollection { get; }
        public bool IsVirtual { get; }

        // TODO: possibly add public ScriptBlock Compare ... 
        //  but... i don't that having a ScriptBlock for Configure will ever make sense, right? 

        public AnonymousProperty(PropertyParentType parentType, string parentName) : base($"{parentName}.Property", parentName)
        {
            this.ParentType = parentType;

            this.PropertyType = PropertyType.Property;
            this.IsVirtual = false; // false != anonymous
            this.IsCollection = false;
        }

        public IProperty GetInstance()
        {
            return (AnonymousProperty)this.MemberwiseClone();
        }
    }

    public class VirtualProperty : IProperty
    {
        public string Name { get; }
        public string ParentName { get; }
        public PropertyParentType ParentType { get; }
        public PropertyType PropertyType { get; }
        public bool IsCollection { get; }
        public bool IsVirtual { get; }

        public VirtualProperty(string name, string parentName, PropertyParentType parentType)
        {
            this.Name = name;
            this.ParentName = parentName;
            this.ParentType = parentType;

            this.PropertyType = PropertyType.VirtualProperty;
            this.IsCollection = false;
            this.IsVirtual = false;
        }

        public IProperty GetInstance()
        {
            throw new NotImplementedException();
        }
    }

    //public class VirtualCohort : IProperty
    //{
    //    public string Name { get; }
    //    public string ParentName { get; }
    //    public PropertyParentType ParentType { get; }
    //    public PropertyType PropertyType { get; }
    //    public bool IsCollection { get; }
    //    public bool IsVirtual { get; }

    //    public VirtualCohort(string name, string parentName, PropertyParentType parentType)
    //    {
    //        this.Name = name;
    //        this.ParentName = parentName;
    //        this.ParentType = parentType;

    //        this.PropertyType = PropertyType.VirtualCohort;
    //        this.IsCollection = true;
    //        this.IsVirtual = true;
    //    }

    //    public IProperty GetInstance()
    //    {
    //        throw new NotImplementedException();
    //    }
    //}
}