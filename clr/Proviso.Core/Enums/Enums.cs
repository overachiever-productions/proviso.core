namespace Proviso.Core
{
    public enum FacetType
    {
        Scalar,
        Pattern, 
        Import
    }

    public enum Impact
    {
        None,
        Low,
        Medium,
        High
    }

    public enum Membership
    {
        Naive,
        Explicit
    }

    public enum ModalityType
    {
        Enumerator,
        Iterator
    }

    public enum OperationType
    {
        Facet,
        Surface,
        Runbook
    }

    public enum PropertyParentType
    {
        Properties, 
        Cohorts,
        Cohort, 
        Facet, 
        Pattern
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

    public enum Visibility
    {
        Anonymous, 
        Global
    }
}