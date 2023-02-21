using System.Management.Automation;
using Proviso.Core;

namespace Proviso.Core.Definitions
{
    // REFACTOR: need a better (more descriptive) name.
    public interface ISubBlockDefinition
    {
        RunbookOrSurface RunbookOrSurface { get; }
        SetupOrCleanup SetupOrCleanup { get; }
        ScriptBlock CodeBlock { get; }
    }

    public class SubBlockDefinitionBase : ISubBlockDefinition
    {
        public RunbookOrSurface RunbookOrSurface { get; }
        public SetupOrCleanup SetupOrCleanup { get; }
        public ScriptBlock CodeBlock { get; }

        internal SubBlockDefinitionBase(RunbookOrSurface runbookOrSurface, SetupOrCleanup setupOrCleanup, ScriptBlock codeBlock)
        {
            this.RunbookOrSurface = runbookOrSurface;
            this.SetupOrCleanup = setupOrCleanup;
            this.CodeBlock = codeBlock;
        }
    }

    public class RunbookSetupDefinition : SubBlockDefinitionBase
    {
        public RunbookSetupDefinition(ScriptBlock setupBlock) :
            base(RunbookOrSurface.Runbook, SetupOrCleanup.Setup, setupBlock)
        { }
    }

    public class RunbookCleanupDefinition : SubBlockDefinitionBase
    {
        public RunbookCleanupDefinition(ScriptBlock cleanupBlock)
            : base(RunbookOrSurface.Runbook, SetupOrCleanup.Cleanup, cleanupBlock) 
        { }
    }

    public class SurfaceSetupDescription : SubBlockDefinitionBase
    {
        public SurfaceSetupDescription(ScriptBlock setupBlock) :
            base(RunbookOrSurface.Surface, SetupOrCleanup.Setup, setupBlock)
        { }
    }

    public class SurfaceCleanupDescription : SubBlockDefinitionBase
    {
        public SurfaceCleanupDescription(ScriptBlock cleanupBlock) :
            base(RunbookOrSurface.Surface, SetupOrCleanup.Cleanup, cleanupBlock)
        { }
    }
}