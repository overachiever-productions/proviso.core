namespace Proviso.Core
{
    public enum EnumeratorParentType
    {
        Enumerators,
        Cohort
    }

    public enum FacetParentType
    {
        Facets, 
        Patterns, 
        Aspect, 
        Surface
    }

    public enum FacetType
    {
        Facet,
        Pattern, 
        Import, 
        VirtualFacet, 
        VirtualPattern
    }

    public enum Impact
    {
        None,
        Low,
        Medium,
        High
    }

    public enum IteratorParentType
    {
        Iterators,
        Pattern
    }

    public enum MembershipType
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

    public enum PropertyType
    {
        Cohort,
        Inclusion,
        Property, 
        VirtualCohort, 
        VirtualProperty
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