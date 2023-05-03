//using Proviso.Core.Definitions;

//namespace Proviso.Core.Models
//{
//    public class Enumerator
//    {
//        public EnumeratorDefinition Definition { get; set; }

//        public Facet RuntimeFacet { get; set; }
//        public Cohort RuntimeCohort { get; set; }
//        // RuntimeAspect & Runbook?
//        //      probabably aspect, but ... probably going to tackle runbooks differently?


//        // NOTES: 
//        //     1. If Definition.ScriptBlock.Definition (or whatever the script body is) ... is NULL/EMPTY... 
//        //          that's FINE in terms of compile-time.. 
//        //              but, there will need to be something at this point (discovery and on up (i.e., run-time)) that throws in this case. 
//        //     2. If Definition.SurfaceName and Definition.CohortName are null/empty... 
//        //          then this is a 'global' Enumerator. i.e., an ENUMERATOR not an Enumerate. 
//    }
//}