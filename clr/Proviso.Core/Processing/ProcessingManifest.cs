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

        public DateTime PipelineStart { get; set; }
        public DateTime? PipelineEnd { get; set; }

        public DateTime? DiscoveryStart { get; set; }
        public DateTime? DiscoveryEnd { get; set; }

        public DateTime? ProcessingStart { get; set; }
        public DateTime? ProcessingEnd { get; set; }

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
            // TODO: address Aspects. 
            // TODO: address ... Iterate/Enumerate (modality operations) + paths. 
            //      and verify that we've got all of the correct Iterate/Iterator + Add/Remove and Enumerate/Enumerator + Add/Remove
            //              blocks that we need - based on Naive/Explict. 

            // likewise, verify that we've got all of the Except, Extract, Compare, Configure blocks (or syntactic-sugar repointers/shortcuts)
            //      to satisfy the CURRENT .Verb

            // verify 
        }
    }
}