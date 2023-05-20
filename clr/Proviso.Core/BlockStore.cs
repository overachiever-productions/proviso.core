using System;
using System.Linq;
using System.Collections.Generic;
using System.Management.Automation;
using Proviso.Core.Models;

namespace Proviso.Core
{
    public delegate bool StoragePredicate<in T>(T existing, T replacement);

    public static class StorageExtensions
    {
        public static bool Save<T>(this List<T> list, T added, StoragePredicate<T> predicate, bool allowReplace, string identifier)
        {
            var exists = list.Find(x => predicate(x, added));
            if (exists != null)
            {
                if (allowReplace)
                {
                    exists = added;
                    return true;
                }

                string error = identifier + " has already been defined - and -AllowReplace is not enabled. Please review Proviso.Core Naming Guidelines for more info.";
                throw new Exception(error);
            }

            list.Add(added);
            return false;
        }
    }

    public class BlockStore
    {
        private List<Facet> _facets = new List<Facet>();

        public static BlockStore Instance => new BlockStore();

        private BlockStore()
        {

        }

        public bool StoreFacet(Facet added, bool allowReplace)
        {
            added.Validate();

            // NOTE: using hash-code for identification here... 
            StoragePredicate<Facet> predicate = (exists, added) => exists.GetHashCode() == added.GetHashCode();
            return this._facets.Save(added, predicate, allowReplace, $"Facet: [{added.Name}]");
        }

        public Facet GetFacetByName(string name, string parentName)
        {
            if (string.IsNullOrWhiteSpace(parentName))
            {
                var facets = this._facets.Where(x => x.Name == name);
                if (facets.Count() == 1)
                    return facets.First();

                if(facets.Count() > 1)
                    throw new InvalidOperationException($"Multiple Facets named: [{name}] exist - specify the ParentName or Execute Lookup by Facet.Id instead.");
            }

            return this._facets.FirstOrDefault(x => x.Name == name && x.ParentName == parentName);
        }

        public Facet GetFacetById(string id)
        {
            return this._facets.FirstOrDefault(x => x.Id == id);
        }

        public bool StorePattern(Pattern added, bool allowReplace)
        {
            throw new NotImplementedException();
        }
    }
}