﻿using System;
using System.Collections.Generic;

namespace Proviso.Core.Models
{
    public class Facet : DeclarableBase, IFacet, IBuildValidated
    {
        private List<IProperty> _properties = new List<IProperty>();
        private List<IIterator> _iterators = new List<IIterator>();
        private List<IteratorAdd> _adds = new List<IteratorAdd>();
        private List<IteratorRemove> _removes = new List<IteratorRemove>();

        public string Id { get; }
        public FacetParentType FacetParentType { get; }
        public List<IProperty> Properties => this._properties;
        public bool IsPattern { get; internal set; }
        public bool IsVirtual { get; }

        public Facet(string name, string id, FacetParentType parentType, string parentName) : base(name, parentName)
        {
            if(!string.IsNullOrWhiteSpace(id))
                this.Id = id;

            this.FacetParentType = parentType;
        }

        public void Validate()
        {

        }

        public void AddProperty(IProperty added)
        {
            var iValidated = added as IBuildValidated;
            if(iValidated != null)
                iValidated.Validate();

            this._properties.Add(added);
        }
    }

    public class Pattern : Facet
    {
        public MembershipType MembershipType { get; set; }

        public Pattern(string name, string id, FacetParentType parentType, string parentName) 
            : base(name, id, parentType, parentName)
        {

            base.IsPattern = true;
        }

        public new void Validate()
        {

        }
    }
}