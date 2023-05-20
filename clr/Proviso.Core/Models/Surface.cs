using System;
using System.Collections.Generic;
using System.Management.Automation;

namespace Proviso.Core.Models
{
    // REFACTOR: so, maybe the 'correct' way to model the relationships and 'progression of types' here would be to:
    //          1. start with a SurfaceBase ... that contains the few things that are required for all 3x implementations/types... 
    //          2. expand 'up' from that into the other types... (assuming that SurfaceBase could inherit from DeclarableBase?)
    //                      though... i'm not sure it could/would.

    public class Surface : DeclarableBase, ISurface, IPotent, IFacetable, IBuildValidated
    {
        private List<IFacet> _facets = new List<IFacet>();

        public List<IFacet> Facets => this._facets;
        public bool IsVirtual { get; }
        public bool IsPlaceHolder { get; }
        public Impact Impact { get; }
        public bool ThrowOnConfig { get; }
        public string MessageToThrow { get; }

        public Surface(string name, string parentName) : base(name, parentName)
        {


            this.IsVirtual = false;
            this.IsPlaceHolder = false;
        }

        public void SetImpact(Impact impact)
        {
            throw new NotImplementedException();
        }

        public void SetThrowOnConfig(string message)
        {
            throw new NotImplementedException();
        }

        public void Validate()
        {
            throw new NotImplementedException();
        }

        public void AddFacet(IFacet added)
        {
            // TODO: validate for duplicates and so on... 
            this._facets.Add(added);
        }
    }

    public class PlaceHolderSurface : ISurface, IFacetable
    {
        private List<IFacet> _facets = new List<IFacet>();

        public List<IFacet> Facets => this._facets;
        public bool IsVirtual { get; }
        public bool IsPlaceHolder { get; }

        public PlaceHolderSurface()
        {
            this.IsVirtual = false;
            this.IsPlaceHolder = true;
        }
        
        public void AddFacet(IFacet added)
        {
            // TODO: validate for duplicates and so on... 
            this._facets.Add(added);
        }
    }

    public class Implement : ISurface, IPotent
    {
        public string Name { get; }
        public bool IsVirtual { get; }
        public bool IsPlaceHolder { get; }
        public Impact Impact { get; }
        public bool ThrowOnConfig { get; }
        public string MessageToThrow { get; }

        public Implement(string name, string parentName) : this(null, name, parentName) { }

        public Implement(string id) : this(id, null, null) { }

        private Implement(string id, string name, string parentName)
        {
            // TODO: figure out how to find/store/locate/whatever ... the surface in question. 

            this.IsVirtual = true;
            this.IsPlaceHolder = false;
        }

        public void SetImpact(Impact impact)
        {
            throw new NotImplementedException();
        }

        public void SetThrowOnConfig(string message)
        {
            throw new NotImplementedException();
        }
    }


    //public class Surface
    //{
    //    internal List<Facet> _facets = new List<Facet>();
    //    private List<Assert> _asserts = new List<Assert>();

    //    public bool IsPlaceHolderOnly { get; internal set; }
    //    public string SurfaceName { get; private set; }

    //    public List<Facet> Facets => this._facets;
    //    public ScriptBlock Setup { get; private set; }
    //    public List<Assert> Asserts => this._asserts;
    //    public ScriptBlock Cleanup { get; private set; }

    //    public Surface(string name)
    //    {
    //        this.Setup = null;
    //        this.Cleanup = null;

    //        this.IsPlaceHolderOnly = false; // see notes in the ProcessingManifest (in the Discovery phase - for FACET (not Surface) Targets.
    //        this.SurfaceName = name;
    //    }
    //}

    //public class PlaceHolderSurface : Surface
    //{
    //    public PlaceHolderSurface(Facet currentChild)
    //        : base("FAKE")
    //    {
    //        base.IsPlaceHolderOnly = true;
    //        base._facets.Add(currentChild);
    //    }
    //}
}