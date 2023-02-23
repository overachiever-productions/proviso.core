using System.CodeDom;
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
                    Rootable = true,
                    Tracked = true,
                    AllowedParents = new List<string> { "Surface", "Aspect" },  // POSSIBLY a "Surfaces" node for ... globally defined surfaces.
                    AllowedChildren = new List<string> { "Cohort", "Property" }
                },
                new Taxonomy
                {
                    NodeName = "Pattern",
                    Rootable = true,
                    Tracked = true,
                    AllowedParents = new List<string> { "Surface", "Aspect" },  // POSSIBLY a "Surfaces" node for ... globally defined surfaces.
                    AllowedChildren = new List<string> { "Cohort", "Property" }
                },
                new Taxonomy
                {
                    NodeName = "Iterate",
                    AllowedParents = new List<string> { "Pattern" },
                    AllowedChildren = new List<string> { "Add", "Remove" }
                },
                new Taxonomy
                {
                    NodeName = "Iterator",
                    Rootable = true,  // maybe NOT (see next line
                    //AllowedParents = new List<string> { "Iterators" },  // MAYBE need to 'anchor' all globallllly defined IteratORs in an Iterators{} block?
                    AllowedChildren = new List<string> { "Add", "Remove" }
                },
                new Taxonomy
                {
                    NodeName = "Enumerator",
                    Rootable = true,
                    AllowedChildren = new List<string> { "Add", "Remove" }
                },
                new Taxonomy
                {
                    NodeName = "Enumerate",
                    RequiresName = false,
                    NameAllowed = true,  
                    Rootable = true,
                    AllowedParents = new List<string> { "Cohort" },
                    AllowedChildren = new List<string> { "Add", "Remove" }
                },
                new Taxonomy
                {
                    NodeName = "Aspect", 
                    NameAllowed = true,
                    AllowedParents = new List<string> { "Surface" }, 
                    AllowedChildren = new List<string> { "Import", "Facet", "Pattern" }
                }, 
                new Taxonomy
                {
                    NodeName = "Property",
                    Tracked = true,
                    AllowedParents = new List<string> { "Facet", "Cohort" },
                    AllowedChildren = new List<string> { "Inclusion", "Expect", "Extract", "Compare", "Configure" }
                },
                new Taxonomy
                {
                    NodeName = "Cohort",
                    Tracked = true,
                    AllowedParents = new List<string> { "Facet" },
                    AllowedChildren = new List<string> { "Enumerate", "Property" }
                }
            };
        }
    }
}