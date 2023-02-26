using System;
using System.Collections.Generic;
using System.Management.Automation;
using Proviso.Core.Definitions;
using Proviso.Core.Models;

namespace Proviso.Core.Processing
{
    public class ProcessingManifest
    {
        private List<FacetDefinition> _facetDefinitions = new List<FacetDefinition>();
        private List<Facet> _facets = new List<Facet>();
        private List<Surface> _surfaces = new List<Surface>();

        public OperationType OperationType { get; private set; }
        public Verb Verb { get; private set; }
        public string OperatorTargetName { get; set; }

        public List<Surface> Surfaces => this._surfaces;
        public List<Facet> Facets => this._facets;

        #region Timing Details & HostName Info
        public DateTime PipelineStart { get; set; }
        public DateTime? PipelineEnd { get; set; }

        public DateTime? DiscoveryStart { get; set; }
        public DateTime? DiscoveryEnd { get; set; }

        public DateTime? ProcessingStart { get; set; }
        public DateTime? ProcessingEnd { get; set; }

        public string HostName { get; set; }
        #endregion

        public Facet TargetFacet { get; private set; }
        public Surface TargetSurface { get; private set; }
        public Runbook TargetRunbook { get; set; }

        public int FacetDefinitionsCount
        {
            get { return this._facetDefinitions.Count; }
        }

        public bool HasRunbookSetup
        {
            get
            {
                switch (this.OperationType)
                {
                    case OperationType.Runbook:
                        return this.TargetRunbook.Setup != null;
                    default:
                        return false;
                }
            }
        }
        public bool HasRunbookAssertions
        {
            get
            {
                switch (this.OperationType)
                {
                    case OperationType.Runbook:
                        return this.TargetRunbook.Asserts.Count > 0;
                    default:
                        return false;
                }
            }
        }
        public bool HasRunbookCleanup
        {
            get
            {
                switch (this.OperationType)
                {
                    case OperationType.Runbook:
                        return this.TargetRunbook.Cleanup != null;
                    default:
                        return false;
                }
            }
        }

        public ProcessingManifest(OperationType type, Verb verb, string targetName)
        {
            this.OperationType = type;
            this.Verb = verb;
            this.OperatorTargetName = targetName;
        }

        public void AddFacet(Facet added)
        {
            this._facets.Add(added);
        }

        public void AddSurface(Surface added)
        {
            this._surfaces.Add(added);
        }

        public void AddSurfaceDefinition(SurfaceDefinition added)
        {
            
        }

        public void AddFacetDefinition(FacetDefinition added)
        {
            this._facetDefinitions.Add(added);
        }
    }
}