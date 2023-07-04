using System;
using System.Collections.Generic;

namespace Proviso.Core
{
    public class Taxonomy
    {
        public string NodeName { get; set; }
        public bool Rootable { get; set; }
        public bool Tracked { get; set; }
        public bool AllowsWildcards => this.WildcardPattern != "";
        public string WildcardPattern { get; set; }
        public bool RequiresName { get; set; }
        public bool NameAllowed { get; set; }
        public List<string> AllowedParents { get; set; }
        public List<string> AllowedChildren { get; set; }

        public Taxonomy()
        {
            this.Rootable = false;
            this.Tracked = false;
            this.RequiresName = true;
            this.WildcardPattern = "";
            this.NameAllowed = true;
            this.AllowedParents = new List<string>();
            this.AllowedChildren = new List<string>();
        }

        public static List<Taxonomy> Grammar()
        {
            return new List<Taxonomy>
            {
                new Taxonomy
                {
                    NodeName = "Runbook",
                    Rootable = true,
                    Tracked = true,
                    AllowedChildren = new List<string> { "Setup", "Assertions", "Operations", "Cleanup" }
                },
                new Taxonomy
                {
                    NodeName = "Operations",
                    RequiresName = false,
                    NameAllowed = false,
                    AllowedParents = new List<string> { "Runbook" },
                    AllowedChildren = new List<string> { "Run" }
                },
                new Taxonomy
                {
                    NodeName = "Implement", 
                    AllowedParents = new List<string> { "Operations" }
                },
                new Taxonomy
                {
                    NodeName = "Surface",
                    Rootable = true,
                    Tracked = true,
                    AllowedChildren = new List<string> { "Setup", "Assertions", "Aspect", "Cleanup" }
                },
                new Taxonomy
                {
                    NodeName = "Setup",
                    RequiresName = false,
                    NameAllowed = false,
                    AllowedParents = new List<string> { "Runbook", "Surface" }
                },
                new Taxonomy
                {
                    NodeName = "Cleanup",
                    RequiresName = false,
                    NameAllowed = false,
                    AllowedParents = new List<string> { "Runbook", "Surface" }
                },
                new Taxonomy
                {
                    NodeName = "Assertions",
                    RequiresName = false,
                    NameAllowed = false,
                    AllowedParents = new List<string> { "Runbook", "Surface" }, 
                    AllowedChildren = new List<string> { "Assert*" }
                },
                new Taxonomy
                {
                    NodeName = "Assert", 
                    WildcardPattern = "Assert*",
                    AllowedParents =  new List<string> { "Assertions" }
                },
                new Taxonomy
                {
                    NodeName = "Facet",
                    Rootable = false,
                    Tracked = true,
                    AllowedParents = new List<string> { "Surface", "Aspect", "Facets" },  
                    AllowedChildren = new List<string> { "Collection", "Property" }
                },
                new Taxonomy
                {
                    NodeName = "Pattern",
                    Rootable = true,
                    Tracked = true,
                    AllowedParents = new List<string> { "Surface", "Aspect", "Facets" },  // "Facets" is block-name for global parents (but can be aliased as Patterns).  
                    AllowedChildren = new List<string> { "Topology", "Properties" }
                },
                //new Taxonomy
                //{
                //    NodeName = "Iterate",
                //    AllowedParents = new List<string> { "Pattern" },
                //    AllowedChildren = new List<string> { "Add", "Remove" }
                //},
                //new Taxonomy
                //{
                //    NodeName = "Iterator",
                //    AllowedParents = new List<string> { "Pattern", "Iterators"},
                //    AllowedChildren = new List<string> { "Add", "Remove" }
                //},
                //new Taxonomy
                //{
                //    NodeName = "Enumerator",
                //    AllowedParents = new List<string> { "Cohort", "Enumerators" },
                //    AllowedChildren = new List<string> { "Add", "Remove" }
                //},
                //new Taxonomy
                //{
                //    NodeName = "Enumerate",
                //    RequiresName = false,
                //    NameAllowed = true,  
                //    Rootable = true,
                //    AllowedParents = new List<string> { "Cohort" },
                //    AllowedChildren = new List<string> { "Add", "Remove" }
                //},
                //new Taxonomy
                //{
                //    NodeName = "Instance", 
                //    RequiresName = false, 
                //    NameAllowed = true, 
                //    Rootable = false, 
                //    AllowedParents = new List<string>{ "Pattern" },
                //    AllowedChildren = new List<string> { "List", "Define", "Initialize", "Finalize", "Add", "Remove" }
                //},
                new Taxonomy
                {
                    NodeName = "Topology",
                    RequiresName = false,
                    NameAllowed = false, 
                    Rootable = false, 
                    AllowedParents = new List<string> { "Pattern" }, 
                    AllowedChildren = new List<string>{ "Instance" }
                },
                new Taxonomy
                {
                    NodeName = "Instance", 
                    RequiresName = false,  
                    NameAllowed = true, 
                    Rootable = false, 
                    AllowedParents = new List<string> { "Topology", "Topologies" },  // "Topologies would be globally defined ... iterators.. 
                    AllowedChildren = new List<string>{ "List", "Enumerate", "Initialize", "Finalize", "Add", "Remove" }
                },
                new Taxonomy
                {
                    NodeName = "Properties",
                    RequiresName = false,
                    NameAllowed = true,
                    Rootable = false,
                    AllowedParents = new List<string>{ "Pattern" },
                    AllowedChildren = new List<string> { "Property", "Collection", "Inclusion" }
                },
                new Taxonomy
                {
                    NodeName = "Membership", 
                    RequiresName = false, 
                    NameAllowed = true, 
                    Rootable = false, 
                    AllowedParents = new List<string> { "Collection" }, 
                    AllowedChildren = new List<string> { "List", "Enumerate", "Initialize", "Finalize", "Add", "Remove" }
                },
                new Taxonomy
                {
                    NodeName = "List", 
                    RequiresName = false,
                    NameAllowed = true, 
                    Rootable = false, 
                    AllowedParents = new List<string> { "Membership", "Instance" }
                },
                new Taxonomy
                {
                    NodeName = "Enumerate",  
                    RequiresName = false,
                    NameAllowed = true,
                    Rootable = false,
                    AllowedParents = new List<string> { "Membership", "Instance" }
                },
                new Taxonomy
                {
                    NodeName = "Members", 
                    RequiresName = false,
                    NameAllowed = true, 
                    Rootable = false, 
                    AllowedParents = new List<string>{ "Collection" }, 
                    AllowedChildren = new List<string>{ "Property", "Inclusion"}
                },
                new Taxonomy
                {
                    NodeName = "Add", 
                    AllowedParents = new List<string> { "Pattern", "Collection" }
                },
                new Taxonomy
                {
                    NodeName = "Remove",
                    AllowedParents = new List<string> { "Pattern", "Collection" }
                },
                //new Taxonomy
                //{
                //    NodeName = "Aspect", 
                //    NameAllowed = true,
                //    AllowedParents = new List<string> { "Surface" }, 
                //    AllowedChildren = new List<string> { "Import", "Facet", "Pattern" }
                //},
                new Taxonomy
                {
                    NodeName = "Property",
                    Tracked = true,
                    AllowedParents = new List<string> { "Facet", "Pattern", "Members", "Properties" },
                    AllowedChildren = new List<string> { "Inclusion", "Expect", "Extract", "Compare", "Configure" }
                },
                new Taxonomy
                {
                    NodeName = "Collection",
                    Tracked = true,
                    RequiresName = false,
                    AllowedParents = new List<string> { "Facet", "Pattern" },
                    AllowedChildren = new List<string> { "Enumerate", "Property" }
                }, 
                new Taxonomy
                {
                    NodeName = "Expect", 
                    AllowedParents = new List<string> { "Property" }
                },
                new Taxonomy
                {
                    NodeName = "Extract",
                    AllowedParents = new List<string> { "Property" }
                },
                new Taxonomy
                {
                    NodeName = "Compare",
                    AllowedParents = new List<string> { "Property" }
                },
                new Taxonomy
                {
                    NodeName = "Configure",
                    AllowedParents = new List<string> { "Property" }
                },

                #region Globally Defined Resources
                new Taxonomy
                {
                    NodeName = "Facets",  // TODO: Should I call these "GlobalFacets" instead of merely "Facets"? 
                    Rootable = true,
                    AllowedChildren = new List<string>{ "Facet" }
                }
                
                //new Taxonomy
                //{
                //    NodeName = "GlobalProperties",  // was, originally, properties ... but there's no sense overloading names of blocks... 
                //    Rootable = true,
                //    AllowedChildren = new List<string>{ "Property" }
                //},
                //new Taxonomy
                //{
                //    NodeName = "Cohorts",
                //    Rootable = true,
                //    AllowedChildren = new List<string>{ "Cohort" }
                //},
                
                //new Taxonomy
                //{
                //    NodeName = "Iterators", // GlobalInstanceIterators? or ... just Iterators? 
                //    Rootable = true,
                //    AllowedChildren = new List<string>{ "Iterator", "Add", "Remove" }
                //},
                //new Taxonomy
                //{
                //    NodeName = "Enumerators",  // Hmm? not sure what to call this.
                //    Rootable = true,
                //    AllowedChildren = new List<string>{ "Enumerator", "Add", "Remove" }
                //},
                #endregion
            };
        }
    }
}