using System;
using System.Collections.Generic;
using System.Management.Automation;
using Proviso.Core.Interfaces;
using Proviso.Core.Models;

namespace Proviso.Core.Definitions
{
    public class RunbookDefinition : IValidated
    {
        private List<AssertDefinition> _assertDefinitions = new List<AssertDefinition>();
        private List<ImplementDefinition> _implementDefinitions = new List<ImplementDefinition>();

        public string Name { get; private set; }
        public ScriptBlock Setup { get; set; }
        public ScriptBlock Cleanup { get; set; }

        public List<ImplementDefinition> Implements => this._implementDefinitions;
        public List<AssertDefinition> AssertDefinitions => this._assertDefinitions;

        public RunbookDefinition(string name)
        {
            this.Setup = null;
            this.Cleanup = null;

            this.Name = name;
        }

        public void AddAssert(AssertDefinition added)
        {
            // TODO: execute added.Validate();
            this._assertDefinitions.Add(added);
        }

        public void AddFacetImplementationReference(ImplementDefinition added)
        {
            // TODO: MAYBE? execute added.Validate();
            this._implementDefinitions.Add(added);
        }

        public void Validate(object validationContext)
        {   
            // TODO: is there anything to validate here? 
            // maybe that the COUNT of Implement defs is > 0?
            //  and... make sure to allow for -skip/disabled as a Implement params.
            //      then to check that ALL are not disabled. (Actually, if they're all Implement "blah" -Skip ... 
            //      i think i just report on that at run time. 
        }
    }
}