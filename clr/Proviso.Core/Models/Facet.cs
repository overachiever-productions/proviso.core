﻿using System;
using System.Collections.Generic;
using System.Text.Json;

namespace Proviso.Core.Models
{
    public class Facet : DeclarableBase, IFacet, IPotent, IBuildValidated
    {
        private List<IProperty> _properties = new List<IProperty>();
        private List<IIterator> _iterators = new List<IIterator>();

        public string Id { get; }
        public FacetParentType FacetParentType { get; }
        public List<IProperty> Properties => this._properties;
        public bool IsPattern { get; internal set; }
        public bool IsVirtual { get; }

        public Impact Impact { get; private set; }
        public bool ThrowOnConfig { get; private set; }
        public string MessageToThrow { get; private set; }

        public Facet(string name, string id, FacetParentType parentType, string parentName) : base(name, parentName)
        {
            if(!string.IsNullOrWhiteSpace(id))
                this.Id = id;

            this.FacetParentType = parentType;
        }

        public static Facet GetInstance(Facet source)
        {
            // shallow properties:
            var output = (Facet)source.MemberwiseClone();

            // complex/child properties: 
            output.ClearProperties();
            foreach (var prop in source.Properties)
                output.AddProperty(prop.GetInstance());

            return output;
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

        public void SetImpact(Impact impact)
        {
            this.Impact = impact;
        }

        public void SetThrowOnConfig(string message)
        {
            this.ThrowOnConfig = true;
            this.MessageToThrow = message;
        }

        public override int GetHashCode()
        {
            if (!string.IsNullOrWhiteSpace(this.Id))
                return this.Id.GetHashCode();

            return $"{this.Name}::{this.ParentName}".GetHashCode();
        }

        public void ClearProperties()
        {
            this._properties = new List<IProperty>();
        }

        public string Serialize()
        {
	        JsonSerializerOptions options = new()
	        {
		        WriteIndented = true
	        };

	        return JsonSerializer.Serialize<object>(this, options);
        }
	}

    public class Pattern : Facet
    {
        public MembershipType MembershipType { get; set; }

        public List<Instance> Instances { get; private set; }

        public Pattern(string name, string id, FacetParentType parentType, string parentName) 
            : base(name, id, parentType, parentName)
        {
            base.IsPattern = true;

            this.Instances = new List<Instance>();
        }

        public void AddInstance(Instance concrete)
        {
            // TODO: ... there might come a point where I need ... a virtual instanceS thingy.. 
            this.Instances.Add(concrete);
        }

        public new void Validate()
        {

        }
    }
}