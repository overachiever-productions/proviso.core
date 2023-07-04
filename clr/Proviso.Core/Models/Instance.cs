using System;
using System.Management.Automation;

namespace Proviso.Core.Models
{
    public class Instance
    {
        public string Name { get; private set; }
        public string ParentName { get; private set; }
        public string DefaultInstanceName { get; private set; }
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

        public Instance(string name, string parentName, bool isStrict, string defaultInstanceName)
        {
            this.Name = name;
            this.ParentName = parentName;
            this.DefaultInstanceName = defaultInstanceName;

            this.IsStrict = isStrict;
        }

        public void SetListBlock(ScriptBlock list)
        {
            // REFACTOR: might just allow $xxx.List = $ListBlock from within Posh... 
            this.List = list;
        }
    }
}