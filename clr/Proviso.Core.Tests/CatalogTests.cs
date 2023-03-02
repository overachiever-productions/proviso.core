using NUnit.Framework;
using NUnit.Framework.Internal;
using Proviso.Core.Definitions;
using Proviso.Core.Tests.fakes;

namespace Proviso.Core.Tests;

[TestFixture]
public class CatalogTests
{
    [Test]
    public void False_For_Replace_Enumerator_Definition_Throws()
    {
        var sut = Catalog.Instance;

        var old = new EnumeratorDefinition("Test Enumerator", true);
        var newer = new EnumeratorDefinition("Test Enumerator", true);

        sut.StoreEnumeratorDefinition(old, false);

        Assert.That(
            () => sut.StoreEnumeratorDefinition(newer, false),
            Throws.TypeOf<Exception>()
        );
    }

    [Test]
    public void Enumerator_Definitions_Can_Be_Replaced()
    {
        var sut = Catalog.Instance;

        var old = new FakeEnumeratorDefinition("Test Enumerator", true);
        var newer = new EnumeratorDefinition("Test Enumerator", true);

        sut.StoreEnumeratorDefinition(old, true);
        bool replaced = sut.StoreEnumeratorDefinition(newer, true);

        Assert.IsTrue(replaced);
    }

    [Test]
    public void Replaced_Enumerator_Definitions_Are_Replaced()
    {
        // verify that the definition that COULD be replaced ACTUALLY _was_ replaced).
        var sut = Catalog.Instance;

        var old = new FakeEnumeratorDefinition("Test Enumerator", true);
        old.OrderBy = "I'm Idaho!";
        var newer = new EnumeratorDefinition("Test Enumerator", true);
        newer.OrderBy = "That’s where I saw the Leprechaun. He tells me to burn things.";

        sut.StoreEnumeratorDefinition(old, true);
        bool replaced = sut.StoreEnumeratorDefinition(newer, true);

        var retrieved = sut.GetEnumeratorDefinition("Test Enumerator");
        StringAssert.AreEqualIgnoringCase(old.OrderBy, retrieved.OrderBy);
    }
}