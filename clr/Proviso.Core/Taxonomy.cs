using System.Collections.Generic;

namespace Proviso.Core
{
    public class Taxonomy
    {
        public string NodeName { get; set; }
        public bool Rootable { get; set; }
        public bool Tracked { get; set; }
        public List<string> AllowedParents { get; set; }
        public List<string> AllowedChildren { get; set; }

        public Taxonomy()
        {
            this.Rootable = false;
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
                    NodeName = "Surface",
                    Rootable = true,
                    Tracked = true,
                    AllowedChildren = new List<string> { "Setup", "Assertions", "Aspect", "Cleanup" }
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
                    NodeName = "Iterator",
                    Rootable = true,
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
                    NodeName = "Assertions", 
                    AllowedParents = new List<string> { "Runbook", "Surface" }, 
                    // TODO: figure out how to address wildcards like this:
                    AllowedChildren = new List<string> { "Assert*" }
                }, 
                new Taxonomy
                {
                    NodeName = "Setup", 
                    AllowedParents = new List<string> { "Runbook", "Surface" }
                }, 
                new Taxonomy
                {
                    NodeName = "Cleanup", 
                    AllowedParents = new List<string> { "Runbook", "Surface" }
                },
                new Taxonomy
                {
                    NodeName = "Operations", 
                    AllowedParents = new List<string> { "Runbook" },
                    AllowedChildren = new List<string> { "Run" }
                }, 
                new Taxonomy
                {
                    NodeName = "Aspect", 
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