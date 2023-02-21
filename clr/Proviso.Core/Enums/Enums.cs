namespace Proviso.Core
{
    public enum FacetType
    {
        Scalar,
        Pattern
    }

    public enum Impact
    {
        None,
        Low,
        Medium,
        High
    }

    public enum OperationType
    {
        Facet,
        Surface,
        Runbook
    }

    public enum RunbookOrSurface
    {
        Runbook,
        Surface
    }

    public enum SetupOrCleanup
    {
        Setup, 
        Cleanup
    }

    public enum Verb
    {
        Read,
        Test,
        Invoke
    }
}