using System;
using System.Management.Automation;

namespace Proviso.Core.Models
{
    // REFACTOR: I think that 'Instances' is probably the best name for the code-block within Proviso... 
    //      there might be a better option like... InstanceMembership ... or something that denotes that we're specifying instances ... 
    //      e.g., InstanceManagement or InstanceSpecifiers. (Though, honestly, InstanceMembership is probably closest). 
    //      and... of course: ITERATOR might make the most sense. 
    //  AT ANY RATE: while "Instances" makes sense for Proviso.Core PS code-blocks... 
    //      it blows chunks for an 'object' name within C#... so... a) settle on a Posh block-name, b) posh-block name does NOT
    //          have to have 1-to-1 (perfect) correspondence with whatever I call this 'thing' within C#...
    // REFACTOR: Note, too, that this is roughly an IDENTICAL implementation (copy + paste + minor tweak) to the 
    //      implementation for Membership(s).
    public class Instances
    {
        public string Name { get; private set; }
        public string ParentName { get; private set; }
        public bool IsStrict { get; private set; }
        public bool SupportsRemove
        {
            get
            {
                if (this.IsStrict)
                {
                    if (this.Remove != null)
                        return true;
                }

                return false;
            }
        }

        public ScriptBlock List { get; private set; }  // Extract
        public ScriptBlock Enumerate { get; private set; }  // Expect
        public ScriptBlock Add { get; set; }
        public ScriptBlock Remove { get; set; }

        public Instances(string name, string parentName, bool isStrict)
        {
            this.Name = name;
            this.ParentName = parentName;

            this.IsStrict = isStrict;
        }

        public void SetListBlock(ScriptBlock list)
        {
            // REFACTOR: might just allow $xxx.List = $ListBlock from within Posh... 
            this.List = list;
        }
    }
}