using System;
using System.Collections.Generic;
using System.Management.Automation;

namespace Proviso.Core
{
    // NOTE: I can do some CRAZY crap in here... 
    //      i.e., CLR stuff is type-safe. 
    //      powershell doesn't care about that. I mean, it 100% does ... but the code allows me to 'get around it'. 
    // which means that ... 
    //  as long as I'm WILLING to manage type-safety (at runtime) vs relying upon compile-time safety... 
    //      i can get away with some crazy stuff within my PIPELINE. 
    //  e.g., 
    //      i can have a FacetReadResult or a SurfaceTestResult going through the pipeline
    //          and both/either could be in the $resultsObject ... and powershell 'won't care' what it's dealing with. 
    //      so, as long as I'm careful with various 'switches' and if/else operations 
    //      about what I'm working with... i could do CRAZY things like
    //          $resultsObject.AddSurfaceAssertResult()
    //              even though said method could NEVER even be close to 'mentioned' against a FacetReadResult... 
    //              and my code will be TOTALLY fine. 


    public class ExtractResult
    {
        public bool Failed { get; set; }

        // refactor: it appears that I don't ever USE ObjectType ... 
        public string ObjectType { get; set; }
        public Object Result { get; set; }
        public ErrorRecord Error { get; set; }

        private ExtractResult(bool failed, string objectType, object result, ErrorRecord error)
        {
            this.Failed = failed;
            this.ObjectType = objectType;
            this.Result = result;
            this.Error = error;
        }

        public Object GetResultForConsoleDisplay()
        {
            if (this.Result == null)
            {
                return "$null";
            }

            return this.Result;
        }

        public static ExtractResult SuccessfulExtractResult(string objectType, object result)
        {
            return new ExtractResult(false, objectType, result, null);
        }

        public static ExtractResult NullResult()
        {
            return new ExtractResult(false, "", null, null);
        }

        public static ExtractResult FailedExtractResult(ErrorRecord error)
        {
            return new ExtractResult(true, null, null, error);
        }
    }

    //public class ExpectResult
    //{

    //}

    //public class CompareResult
    //{

    //}


    // XXXX REFACTOR XXXX: need to figure out what the potential overlap of ExtractResult vs ReadResult is... 
    //      i.e., a PropertyReadResult is just going to be a single ExtractResult. 
    //          whereas a PropertyTestResult will be a single ExtractResult + a single ExpectResult + a single TestResult.. 
    //      seems like there's a bit of overlap in these ... but... actually, there really isn't. 
    public class PropertyReadResult
    {
        public DateTime Start { get; set; }
        public DateTime End { get; set; }

        public string PropertyName { get; set; }
        public string DisplayFormat { get; set; }
        //public PropertyPipelineProcessingOutcome Outcome { get; set; }

        public ExtractResult ExtractionResult { get; set; }

        public PropertyReadResult(string name, string format, ExtractResult result)
        {
            this.PropertyName = name;
            this.DisplayFormat = format;
            this.ExtractionResult = result;
        }

        public string GetPropertyName()
        {
            // TODO: Implement DislapyFormat functionality... 
            return this.PropertyName;
        }

        public string GetReadDetail()
        {
            // TODO: Implement this fully. 
            if (this.ExtractionResult.Failed)
                return "Error: " + this.ExtractionResult.Error.Exception.Message;

            return "";
        }
    }

    //public class PropertyTestResult : PropertyReadResult
    //{

    //}

    //public class PropertyInvokeResult : PropertyTestResult
    //{

    //}

    public class FacetReadResult
    {
        public DateTime PipelineStart { get; private set; }
        public DateTime PipelineEnd { get; set; }
        public string FacetName { get; set; }
        public string DisplayFormat { get; set; }
        public List<PropertyReadResult> PropertyReadResults = new List<PropertyReadResult>();

        public FacetReadResult(string name, string format)
        {
            this.FacetName = name;
            this.DisplayFormat = format;

            this.PipelineStart = DateTime.Now;
        }

        // NOT the result of each Facet.Read in a Surface (or surfaces in a runbook)
        //  but the outcome of a Facet-Read result
        //      i.e., it's more streamlined and less 'complex' than surface/runbook operations... 
        public string GetFacetName()
        {
            // TODO: implement .DisplayFormat functionality if/when present. 
            return this.FacetName;
        }
    }

    public class FacetTestResult
    {
        // basically, the exact same as above, but .Properties contains .ExpectResults in addition to .ExtractResults ... 
        //      and, of course, will have .CompareResults as well... 
    }

    public class FacetInvokeResult
    {
        // ditto, but adds .ConfigurationResults ... which is info about .Exception or not during config (otherwise, when config started/ended). 
        //      and... some re-compare-results (however I end up implementing those).
    }

    public class SurfaceReadResult
    {
        // not a result for each surface in a runbook... but the result for a Read-Surface operation... 
    }

    public class SurfaceTestResult
    {
        // not a result for each surface in a runbook - but the result for a Test-Surface operation... 
    }

    public class SurfaceInvokeResult
    {
        // not a result for each surface in a runbook - but the result for an Invoke-Surface operation... 
    }

    public class RunbookReadResult
    {
        // result for a Read-Runbook operation... 
    }

    public class RunbookTestResult
    {
        // output for a Test-Runbook operation... 
    }

    public class RunbookInvokeResult
    {
        // output for an Invoke-Runbook operation... 
    }
}

