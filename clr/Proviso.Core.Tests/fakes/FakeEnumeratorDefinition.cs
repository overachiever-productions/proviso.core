using Proviso.Core.Definitions;

namespace Proviso.Core.Tests.fakes;

// This exists SOLELY to allow tweaks/changes to the .Created property.
public class FakeEnumeratorDefinition : EnumeratorDefinition
{
    public new DateTime Created { get; internal set; }

    public FakeEnumeratorDefinition(string name, bool isGlobal) 
        : base(name, isGlobal, EnumeratorParentType.Cohort, "Faked_Cohort")
    {
    }
}