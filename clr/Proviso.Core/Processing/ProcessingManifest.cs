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
        public string OperatorTargetName { get; set; }

        #region Timing Details & HostName Info
        public DateTime PipelineStart { get; set; }
        public DateTime? PipelineEnd { get; set; }

        public DateTime? DiscoveryStart { get; set; }
        public DateTime? DiscoveryEnd { get; set; }

        public DateTime? ProcessingStart { get; set; }
        public DateTime? ProcessingEnd { get; set; }

        public string HostName { get; set; }
        #endregion

        public Facet ProcessingFacet { get; private set; }
        public Surface ProcessingSurface { get; private set; }
        public Runbook ProcessingRunbook { get; private set; }

        public int FacetDefinitionsCount
        {
            get { return this._facetDefinitions.Count; }
        }

        // REFACTOR: change these to PROPERTIES (get only) and ... tweak the calling code in PowerShell accordingly.
        public bool HasRunbookSetup()
        {
            switch (this.OperationType)
            {
                case OperationType.Surface:
                    throw new NotImplementedException("PENDING");
                    //break;
                default:
                    return false;
            }
        }
        // REFACTOR: change these to PROPERTIES (get only) and ... tweak the calling code in PowerShell accordingly.
        public bool HasRunbookAssertions()
        {
            switch (this.OperationType)
            {
                case OperationType.Surface:
                    throw new NotImplementedException("PENDING");
                    //break;
                default:
                    return false;
            }
        }
        // REFACTOR: change these to PROPERTIES (get only) and ... tweak the calling code in PowerShell accordingly.
        public bool HasRunbookCleanup()
        {
            switch (this.OperationType)
            {
                case OperationType.Surface:
                    throw new NotImplementedException("PENDING");
                    //break;
                default:
                    return false;
            }
        }

        public ProcessingManifest(OperationType type, Verb verb, string targetName)
        {
            this.OperationType = type;
            this.Verb = verb;
            this.OperatorTargetName = targetName;
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
            //                  TODO: address Aspects. 
            //                  TODO: address ... Iterate/Enumerate (modality operations) + paths. 
            //                       and verify that we've got all of the correct Iterate/Iterator + Add/Remove and Enumerate/Enumerator + Add/Remove
            //                               blocks that we need - based on Naive/Explict. 

            //                  likewise, verify that we've got all of the Except, Extract, Compare, Configure blocks (or syntactic-sugar repointers/shortcuts)
            //                       to satisfy the CURRENT .Verb

            switch (this.OperationType)
            {
                case OperationType.Facet:
                    break;
                case OperationType.Surface:
                    break;
                case OperationType.Runbook:
                    RunbookDefinition target = currentCatalog.GetRunbook(this.OperatorTargetName);
                    this.ProcessingRunbook = target.ToRunbook();
                    break;
                default:
                    throw new InvalidOperationException();
            }


            //if (this.OperationType == OperationType.Runbook)
            //{
            //    this.ProcessingSurface = x;
            //}

            //if (this.OperationType == OperationType.Surface)
            //{
            //    this.Processing
            //}


            // Rules: 
            // 1. If we're in a Runbook, set up a new .Runbook property. 
            //      and translate Definition 'stuff' to actual code blocks and such. 
            //      so that we've got properties for the Setup, Assertions, cleanup/etc. 


            // 2. If we're in a Surface, setup a new .Surface property... 
            //      just like above 
            //  only... also ... account for ... aspects? 
            //      think the best way to do so is ... 
            //          a) need to wrap aspects processing in a loop - cuz their .Paths and such can impact lower down. 
            //          b) make sure each Facet has a .ParentAspect property that is either null or <aspectName>. 


            // 3. For each Facet:
            //      a) dump into _facetsToProcess. 
            //      b) also link <aspectName, facet> ?? 
            //      c) and ditto for <surface, facet> as well... so'z, when processing, we can get all facets by surface/aspect. 

            //      d) if Pattern (vs 'facet') 
            //          then expand/extract and verify we've got an iterator. 
            //              note: either ... run the ACTUAL expansion here? (not ideal) 
            //              or just 'tell' (via meta-data/etc.) the facet what to 'expect' at run-time. 
            //          as in, this'll be SIMILAR to what old-proviso did at COMPILE time - only, I'll be doing that same 'stuff' during discovery. 
            //              i assume discovery will work well enough... 


            //      e) also. if pattern, make sure we've got the Iterate|Iterator and applicable add/remove for the .verb (or throw).

            // 4. for each property in the facet... 
            //      scalar or cohort? 
            //          if cohort, 'discovery' of paths and details? 
            //          verify that we'll have the Enumerate|Enumerator and Add/Remove needed. 
            //      again, rather than running full-blown/actual expansion here, would prefer to 'indicate' to processing what to expect here. 
            //      similar to how old proviso handled ... compile-time stuff. 

            // done, right? 

        }
    }
}