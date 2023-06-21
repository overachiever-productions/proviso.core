using System;
using System.Management.Automation;

namespace Proviso.Core.Models
{
    public class Membership
    {
        public ScriptBlock List { get; private set; }


        public Membership(string name, string parentName)
        {

        }

        public void SetListBlock(ScriptBlock list)
        {
            // REFACTOR: might just allow $xxx.List = $ListBlock from within Posh... 
            this.List = list;
        }
    }

    // TODO: create a 'virtual membership' for ... referenced or 'promised' memberships (i.e., re-usable/global) memberships.
    //  e.g., if i have a collection:  Collection "my Collection" -UsersStrictMembership "LocalAdmins" ... 
    //          then, "LocalAdmins" is presumed to be an extant/viable "membership" by the time that compilation/parsing is 
    //          done - meaning that 'discovery' phase can/will be able to map/replace a 'virtualMembership' of "LocalAdmins" with ... 
    //              the actual, global, definition.
}