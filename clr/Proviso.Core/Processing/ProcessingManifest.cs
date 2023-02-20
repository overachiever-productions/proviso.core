using System;
using System.Collections.Generic;
using Proviso.Core.Definitions;
using Proviso.Core.Models;

namespace Proviso.Core.Processing
{
    public class ProcessingManifest
    {
        private List<FacetDefinition> _facetDefinitions = new List<FacetDefinition>();

        public OperationType OperationType { get; private set; }
        public Verb Verb { get; private set; }
        public DateTime ProcessingStart { get; set; }
        public string HostName { get; set; }    

        public int FacetDefinitionsCount
        {
            get { return this._facetDefinitions.Count; }
        }

        public ProcessingManifest(OperationType type, Verb verb)
        {
            this.OperationType = type;
            this.Verb = verb;
        }

        public void AddSurfaceDefinition(SurfaceDefinition added)
        {

        }

        public void AddFacetDefinition(FacetDefinition added)
        {
            this._facetDefinitions.Add(added);
        }

        public void ExecuteDiscovery(Catalog currentCatalog)
        {

        }
    }
}