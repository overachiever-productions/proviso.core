using System;
using System.Collections.Generic;
using Proviso.Core.Models;

namespace Proviso.Core.Definitions
{
    public class RunbookDefinition
    {
        public string RunbookName { get; set; }


        public RunbookDefinition(string name)
        {
            this.RunbookName = name;
        }

        public List<SurfaceDefinition> GetSurfaces()
        {
            throw new NotImplementedException();
        }

        internal Runbook ToRunbook()
        {
            throw new NotImplementedException();
        }
    }
}