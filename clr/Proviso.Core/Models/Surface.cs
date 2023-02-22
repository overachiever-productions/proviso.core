using System.Collections.Generic;
using System.Management.Automation;

namespace Proviso.Core.Models
{
    public class Surface
    {
        internal List<Facet> _facets = new List<Facet>();
        private List<Assert> _asserts = new List<Assert>();

        public bool IsPlaceHolderOnly { get; internal set; }
        public string SurfaceName { get; private set; }

        public List<Facet> Facets => this._facets;
        public ScriptBlock Setup { get; private set; }
        public List<Assert> Asserts => this._asserts;
        public ScriptBlock Cleanup { get; private set; }

        public Surface(string name)
        {
            this.Setup = null;
            this.Cleanup = null;

            this.IsPlaceHolderOnly = false; // see notes in the ProcessingManifest (in the Discovery phase - for FACET (not Surface) Targets.
            this.SurfaceName = name;
        }
    }

    public class PlaceHolderSurface : Surface
    {
        public PlaceHolderSurface(Facet currentChild)
            : base("FAKE")
        {
            base.IsPlaceHolderOnly = true;
            base._facets.Add(currentChild);
        }
    }
}