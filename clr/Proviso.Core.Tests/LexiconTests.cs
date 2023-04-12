using NUnit.Framework;

namespace Proviso.Core.Tests;

[TestFixture]
public class LexiconTests
{
    [Test]
    public void Invalid_BlockType_Throws()
    {
        Assert.That(
            () => Orthography.Instance.EnterBlock("Pizza", "Pepperoni"),
            Throws.TypeOf<InvalidOperationException>()
        );
    }

    [Test]
    public void Valid_BlockTypes_Accepted()
    {
        Orthography.Instance.EnterBlock("Surface", "My Surface");
        Orthography.Instance.EnterBlock("Runbook", "My Runbook");
    }

    [Test]
    public void RootNode_Increments_Depth()
    {
        var sut = Orthography.Instance;

        Assert.AreEqual(0, sut.CurrentDepth);
        sut.EnterBlock("Surface", "My Surface");

        Assert.AreEqual(1, sut.CurrentDepth);
    }

    [Test]
    public void RootNode_And_ValidChild_Increment_Depth()
    {
        var sut = Orthography.Instance;
        sut.EnterBlock("Surface", "My Surface");
        sut.EnterBlock("Facet", "A Facet");

        Assert.AreEqual(2, sut.CurrentDepth);
    }

    [Test]
    public void RootNode_And_ValidChildren_Increment_Depth()
    {
        var sut = Orthography.Instance;
        sut.EnterBlock("Surface", "My Surface");
        sut.EnterBlock("Facet", "A Facet");
        sut.EnterBlock("Cohort", "Members Of SysAdmin");

        Assert.AreEqual(3, sut.CurrentDepth);
    }

    [Test]
    public void Exiting_RootNode_Resets_Depth()
    {
        var sut = Orthography.Instance;

        sut.EnterBlock("Surface", "My Surface");
        Assert.AreEqual(1, sut.CurrentDepth);

        sut.ExitBlock("Surface", "name isn't important");
        Assert.AreEqual(0, sut.CurrentDepth);
    }

    [Test]
    public void Exiting_ChildNode_Decrements_Depth()
    {
        var sut = Orthography.Instance;

        sut.EnterBlock("Surface", "My Surface");
        sut.EnterBlock("Facet", "A Facet");
        Assert.AreEqual(2, sut.CurrentDepth);

        sut.ExitBlock("Facet", "A Facet");

        Assert.AreEqual(1, sut.CurrentDepth);
    }

    [Test]
    public void Existing_All_Nodes_Resets_Depth()
    {
        var sut = Orthography.Instance;
        sut.EnterBlock("Surface", "My Surface");
        sut.EnterBlock("Facet", "A Facet");
        sut.EnterBlock("Cohort", "Members Of SysAdmin");
        Assert.AreEqual(3, sut.CurrentDepth);

        sut.ExitBlock("Cohort", "Cohort Name");
        sut.ExitBlock("Facet", "A Facet");
        sut.ExitBlock("Surface", "Surface");
        Assert.AreEqual(0, sut.CurrentDepth);
    }

    [Test]
    public void Trackable_Taxonomy_Is_Tracked()
    {
        var sut = Orthography.Instance;
        var surfaceName = "My Surface";
        sut.EnterBlock("Surface", surfaceName);

        StringAssert.AreEqualIgnoringCase(surfaceName, sut.GetCurrentSurface());
    }

    [Test]
    public void Trackable_Taxonomies_Are_Tracked()
    {
        var sut = Orthography.Instance;
        var surfaceName = "My Surface";
        var facetName = "A Facet";
        sut.EnterBlock("Surface", surfaceName);
        sut.EnterBlock("Facet", facetName);

        StringAssert.AreEqualIgnoringCase(surfaceName, sut.GetCurrentSurface());
        StringAssert.AreEqualIgnoringCase(facetName, sut.GetCurrentFacet());
    }

    [Test]
    public void Peer_Nodes_Are_Allowed()
    {
        var sut = Orthography.Instance;
        var prop1Name = "Disable Telemetry";
        var prop2Name = "Default XE Directory";
        var prop3Name = "Blocked Processes Threshold";

        sut.EnterBlock("Facets", null);
        sut.EnterBlock("Facet", "Test Facet");
        Assert.AreEqual(2, sut.CurrentDepth);

        sut.EnterBlock("Property", prop1Name);
        Assert.AreEqual(3, sut.CurrentDepth);
        sut.ExitBlock("Property", prop1Name);
        Assert.AreEqual(2, sut.CurrentDepth);

        sut.EnterBlock("Property", prop2Name);
        sut.ExitBlock("Property", prop2Name);

        sut.EnterBlock("Property", prop3Name);
        sut.ExitBlock("Property", prop3Name);

        Assert.AreEqual(2, sut.CurrentDepth);
    }

    [Test]
    public void ScriptBlocks_Do_Not_Leak()
    {
        var sut = Orthography.Instance;
        var surfaceName = "My Surface";
        var facetName = "Test Facet";

        sut.EnterBlock("Surface", surfaceName);
        sut.EnterBlock("Facet", facetName);
        sut.ExitBlock("Facet", facetName);
        sut.ExitBlock("Surface", surfaceName);

        var runbookName = "Firewall Rules";
        sut.EnterBlock("Runbook", runbookName);
        sut.EnterBlock("Operations","");
        sut.ExitBlock("Operations", "");
        sut.EnterBlock("Cleanup", "");
        sut.ExitBlock("Cleanup", "");
        sut.ExitBlock("Runbook", runbookName);
    }

    [Test]
    public void Lexicon_Tracks_Current_Function_Name()
    {
        var sut = Orthography.Instance;

        var surfaceName = "My Surface";
        var facetName = "My Facet";
        var propName = "My Property"; 

        // enter:
        sut.EnterBlock("Surface", surfaceName);
        StringAssert.AreEqualIgnoringCase(surfaceName, sut.GetCurrentBlockName());

        sut.EnterBlock("Facet", facetName);
        StringAssert.AreEqualIgnoringCase(facetName, sut.GetCurrentBlockName());

        sut.EnterBlock("Property", propName);
        StringAssert.AreEqualIgnoringCase(propName, sut.GetCurrentBlockName());

        // unwind... 
        sut.ExitBlock("Property", propName);
        StringAssert.AreEqualIgnoringCase(facetName, sut.GetCurrentBlockName());

        sut.ExitBlock("Facet", facetName);
        StringAssert.AreEqualIgnoringCase(surfaceName, sut.GetCurrentBlockName());

        sut.ExitBlock("Surface", surfaceName);
        StringAssert.AreEqualIgnoringCase("", sut.GetCurrentBlockName());
    }

    [Test]
    public void Cohort_Tracks_Parent_Facet()
    {
        var sut = Orthography.Instance;

        var facetName = "My Facet";
        var cohortName = "Test Cohort";

        sut.EnterBlock("Facets", "");
        sut.EnterBlock("Facet", facetName);
        sut.EnterBlock("Cohort", cohortName);

        StringAssert.AreEqualIgnoringCase(facetName, sut.GetCurrentFacet());
    }

    [Test]
    public void Enumerate_Tracks_Parent_Cohort()
    {
        var sut = Orthography.Instance;

        var facetName = "My Facet";
        var cohortName = "Test Cohort";

        sut.EnterBlock("Facets", "");
        sut.EnterBlock("Facet", facetName);
        sut.EnterBlock("Cohort", cohortName);
        sut.EnterBlock("Enumerate", "");

        StringAssert.AreEqualIgnoringCase(cohortName, sut.GetCurrentCohort());
    }

    [Test]
    public void GetParent_Returns_Null_When_No_Parent()
    {
        var sut = Orthography.Instance;

        sut.EnterBlock("Facets", "");

        var blockType = sut.GetParentBlockType();
        StringAssert.AreEqualIgnoringCase("", blockType);
    }

    [Test]
    public void GetParent_Returns_Parent_When_Present()
    {
        var sut = Orthography.Instance;

        var facetName = "My Facet";
        var cohortName = "Test Cohort";

        sut.EnterBlock("Facets", "");
        sut.EnterBlock("Facet", facetName);
        sut.EnterBlock("Cohort", cohortName);

        var blockType = sut.GetParentBlockType();
        StringAssert.AreEqualIgnoringCase("Facet", blockType);
    }

    [Test]
    public void GetParent_Does_Not_Cause_Leaks()
    {
        // arguably NOT needed ... but just want to verify that _stack.Skip(1).First() doesn't ... pop (i.e., only does .peek.peek)
        var sut = Orthography.Instance;

        var facetName = "My Facet";
        var cohortName = "Test Cohort";
        sut.EnterBlock("Facets", "");
        sut.EnterBlock("Facet", facetName);
        sut.EnterBlock("Cohort", cohortName);

        var blockType = sut.GetParentBlockType();
        StringAssert.AreEqualIgnoringCase("Facet", blockType);

        sut.EnterBlock("Property", "My Property");
        sut.ExitBlock("Property", "My Property");

        sut.EnterBlock("Property", "Property 2");

        var currentPropertyName = sut.GetCurrentBlockNameByType("Property");

        StringAssert.AreEqualIgnoringCase("Property 2", currentPropertyName);
    }
}