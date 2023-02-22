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
        public Runbook TargetRunbook { get; private set; }

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

        public void AddSurfaceDefinition(SurfaceDefinition added)
        {
            
        }

        public void AddFacetDefinition(FacetDefinition added)
        {
            this._facetDefinitions.Add(added);
        }

        public void ExecuteDiscovery(Catalog currentCatalog)
        {
            Formatter.WriteVerbose("C# says hello.");

            // TODO: probably need to EXPAND surfaces at this point?
            //      see comments in the 'implementDefs' foreach within case OperationType.Runbook (below)
            //      though, an INITIAL expansion phase already occurred in the pipeline... 

            // Targeting: 
            switch (this.OperationType)
            {
                case OperationType.Runbook:
                    RunbookDefinition runbookDef = currentCatalog.GetRunbook(this.OperatorTargetName);
                    if (runbookDef == null)
                        throw new Exception($"Proviso Framework Error. Runbook [{this.OperatorTargetName}] not found in PvCatalog.");

                    Runbook runbook = new Runbook(runbookDef.Name, runbookDef.Setup, runbookDef.Cleanup);
                    runbook.Setup = runbookDef.Setup;

                    foreach (AssertDefinition aDef in runbookDef.AssertDefinitions)
                    {

                    }

                    foreach (var implementDefinition in runbookDef.Implements)
                    {
                        var surfaceDefinition = currentCatalog.GetSurface(implementDefinition.SurfaceName);
                        if (surfaceDefinition == null)
                            throw new Exception($"Proviso Framework Error. A Surface with the name of [{implementDefinition.SurfaceName}] could not be found in the PvCatalog.");

                        // TODO:
                        // now ... convert the surfaceDefinition to ... a Surface... 
                        //      and... i THINK the currentCatalog should have, maybe?, already done this with all Surfaces?
                        //      so that I'm not 'double-creating' or converting surfaces/etc.
                    }

                    runbook.Cleanup = runbookDef.Cleanup;

                    this.TargetRunbook = runbook;

                    break;
                case OperationType.Surface:

                    // todo: account for aspects
                    //      think the best way to do so is ... 
                    //          a) need to wrap aspects processing in a loop - cuz their .Paths and such can impact lower down. 
                    //          b) make sure each Facet has a .ParentAspect property that is either null or <aspectName>. 
                    break;
                case OperationType.Facet:
                    FacetDefinition facetDef = currentCatalog.GetFacetByName(this.OperatorTargetName);
                    if (facetDef == null)
                        throw new Exception($"Proviso Framework Error. Facet [{this.OperatorTargetName}] not found in PVCatalog.");

                    Facet facet = new Facet(facetDef.Name, facetDef.Id, facetDef.FacetType, facetDef.AspectName, facetDef.SurfaceName, null);
                    this._facets.Add(facet);

                    // HACK:
                    //      The (PowerShell code) Processing phase starts by expanding any surfaces in either the RUNBOOK being executed, 
                    //          OR, in the SURFACE being executed. Then for each Surface, the processing pipeline iterates over each
                    //          Facet, and then from each facet 'on down' to each property/etc. 
                    //      The 'rub' is that there's a single pipeline that does ... all of this (i.e., NESTED for-each loops). 
                    //          So. Rather than have 2x pipelines (one for (optional)Surfaces -> Surfaces -> Facets, and one for JUST Facets),
                    //           currently creating the notion of a PlaceHolderSurface that uses some if/else switches through the pipeline
                    //           and elsewhere... vs having 2x pipelines with the potential for DRY-violations.
                    //      MAY end up hating this hack and having 2x pipeline (at the facet level) implementations - or a helper func/etc.
                    this._surfaces.Add(new PlaceHolderSurface(facet));
                    break;
                default:
                    throw new InvalidOperationException();
            }

            // Validation: 
            foreach (Facet f in this._facets)
            {
                if (f.FacetType == FacetType.Pattern)
                {
                    // make sure we've got an iterator. 
                    // and that paths match up as they should/need-to. 
                    //      er, make sure we've got 1 iterator per each path-indication of an iterator, right?

                    // also see if we've got ANY properties. 
                    //  if we don't that's 'fine'. we just can't READ against this thing... 
                    //      i.e., ONLY if there's a -Target ... then, the ... 'read' or 'extract' becomes, literally: $target. 
                    //      so, there needs to be some way to specify that. 
                }

                //foreach (Cohort c in f.RawCohorts ?)
                //{
                //    //     make sure we've got an Enumerate(or)
                //}
            }


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