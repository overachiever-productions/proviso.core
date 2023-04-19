using Proviso.Core.Definitions;
using System.Management.Automation;

namespace Proviso.Core.Models
{
    public static class PropertyMapper
    {
        public static Property ToProperty(this PropertyDefinition definition)
        {
            return new Property();
        }
    }

    // NOTE: going brute-force implementation. 
    //      THEN... I'll figure out what I need for any kind of interface and/or so on... 
    //      to better streamline code and refactor/etc. 
    public class Property
    {
        public PropertyType PropertyType { get; set; }
        public string Name { get; internal set; }
        public PropertyParentType PropertyParentType { get; set; }
        public string ParentName { get; set; }
        public string SourceFile { get; set; }

        public string ModelPath { get; set; }
        public string TargetPath { get; set; }
        public bool Skip { get; set; }
        public string SkipReason { get; set; }
        public Impact Impact { get; set; }
        public string DisplayFormat { get; set; }
        public bool ThrowOnConfig { get; set; }
        public string ThrowOnConfigReason { get; set; }

        public ScriptBlock Expect { get; set; }
        public ScriptBlock Extract { get; set; }
        public ScriptBlock Compare { get; set; }
        public ScriptBlock Configure { get; set; }

        public EnumeratorDefinition Enumerate { get; set; }
        public EnumeratorAddDefinition Add { get; set; }
        public EnumeratorRemoveDefinition Remove { get; set; }

        internal Property()
        {
            // private/internal (only) .ctor... to prevent anyone from every spinning these up. 
            // i.e., they're closed and can ONLY come from ... PropertyDefinition.ToProperty(). 
        }

        public void Validate(Orthography cache)
        {
            // so ... might pass in an ortho-cache here or ... a catalog? 
            //      either eay, the .Validate() here is going to be different signature than IValidated.Validate()
            //      but, i can create an ICatalogValidated.Validate() or IOrthoCacheValidated.Validate() interface instead.
        }
    }
}
