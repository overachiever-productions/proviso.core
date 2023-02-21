using NUnit.Framework;

namespace Proviso.Core.Tests;

// NOTE: The Taxonomy object is so simple it doesn't NEED tests. 
//  Instead, this set of tests is where actual LANGUAGE/Taxonomy-combos are tested. 
//      i.e., LexiconTests covers tests for basic functionality of the Lexicon itself. 
//      This set of tests validates 'business' rules about what is allowed within Proviso.

[TestFixture]
public class TaxonomyTests
{
    [Test]
    public void Facet_Can_StandAlone()
    {
        var sut = Lexicon.Instance;

        sut.EnterBlock("Facet", "A Facet");
    }

    [Test]
    public void Facet_Can_Be_In_Surface()
    {
        var sut = Lexicon.Instance;

        sut.EnterBlock("Surface", "My Surface");
        sut.EnterBlock("Facet", "A Facet");
    }

    [Test]
    public void Facet_Can_Be_In_Aspect()
    {
        var sut = Lexicon.Instance;

        sut.EnterBlock("Surface", "My Surface");
        sut.EnterBlock("Aspect", "Some Grouping");
        sut.EnterBlock("Facet", "A Facet");
    }

    [Test]
    public void Runbook_with_Named_Setup_Throws()
    {
        var sut = Lexicon.Instance;
        sut.EnterBlock("Runbook", "Firewall Settings");

        Assert.That(
            () => sut.EnterBlock("Setup", "Should throw"),
            Throws.TypeOf<Exception>()
        );
    }

    [Test]
    public void Runbook_with_Named_AssertionsBlock_Throws()
    {
        var sut = Lexicon.Instance;
        sut.EnterBlock("Runbook", "Firewall Settings");

        Assert.That(
            () => sut.EnterBlock("Assertions", "Should throw"),
            Throws.TypeOf<Exception>()
        );
    }

    [Test]
    public void Surface_with_Named_Setup_Throws()
    {
        var sut = Lexicon.Instance;
        sut.EnterBlock("Surface", "Tiddlywinks");

        Assert.That(
            () => sut.EnterBlock("Setup", "Should throw"),
            Throws.TypeOf<Exception>()
        );
    }

    [Test]
    public void Surface_with_Named_AssertionsBlock_Throws()
    {
        var sut = Lexicon.Instance;
        sut.EnterBlock("Surface", "Tiddlywinks");

        Assert.That(
            () => sut.EnterBlock("Assertions", "Should throw"),
            Throws.TypeOf<Exception>()
        );
    }

    [Test]
    public void Runbook_Can_Have_Setup()
    {
        var sut = Lexicon.Instance;

        sut.EnterBlock("Runbook", "Firewall Settings");
        sut.EnterBlock("Setup", "");

        StringAssert.AreEqualIgnoringCase("Firewall Settings", sut.GetCurrentRunbook());
        Assert.AreEqual(2, sut.CurrentDepth);
    }

}