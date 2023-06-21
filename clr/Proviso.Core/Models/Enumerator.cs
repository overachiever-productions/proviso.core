//using System;
//using System.Management.Automation;

//namespace Proviso.Core.Models
//{
//    // REFACTOR: this is a brute force implementation - look into interfaces AFTER this is done... 
//    // TODO: probably add in IBuildValidated... 
//    public class Enumerator
//    {
//        public EnumeratorParentType EnumeratorParentType { get; private set; }
//        public bool IsAnonymous { get; private set; }
//        public string Name { get; private set; }
//        public string ParentName { get; private set; }
//        public string OrderBy { get; set; }

//        public ScriptBlock Enumerate { get; set; }

//        public Enumerator(string name, string parentName, EnumeratorParentType parentType, bool isAnonymous)
//        {
//            this.Name = name;
//            this.ParentName = parentName;
//            this.EnumeratorParentType = parentType;
//            this.IsAnonymous = isAnonymous;
//        }
//    }

//    // TODO: Verify that Enumerators can be global/re-used (pretty sure they can) and ... implement:
//    //      a) IEnumerator
//    //      b) VirtualEnumerator 
//    //          as I've done with 


//    // TODO: add parentName/type into thesse? 
//    //  TODO: remove Enum: ModalityType if ... i find out I don't need it (and ... i really don't think i do).
//    public class EnumeratorAdd
//    {
//        public string Name { get; private set; }
//        public bool IsAnonymous { get; private set; }

//        public ScriptBlock Add { get; set; }

//        public EnumeratorAdd(string name, bool isAnonymous)
//        {
//            Name = name;
//            IsAnonymous = isAnonymous;
//        }
//    }

//    public class EnumeratorRemove
//    {
//        public string Name { get; private set; }
//        public bool IsAnonymous { get; private set; }

//        public ScriptBlock Remove { get; set; }

//        public EnumeratorRemove(string name, bool isAnonymous)
//        {
//            Name = name;
//            IsAnonymous = isAnonymous;
//        }
//    }
//}

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

