using System;
using System.Collections.Generic;
using System.Management.Automation;
using System.Reflection.Metadata.Ecma335;
using Proviso.Core.Definitions;
using Proviso.Core.Models;

namespace Proviso.Core
{
    public class Catalog
    {
        public static Catalog Instance => new Catalog();

        private Catalog() { }

        public Facet GetFacetByName(string name, string parentName)
        {
            return null;
        }
    }
}