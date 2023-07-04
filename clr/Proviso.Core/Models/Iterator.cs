//using System;
//using System.Management.Automation;

//namespace Proviso.Core.Models
//{
//    public class Iterator : IIterator
//    {
//        public IteratorParentType IteratorParentType { get; private set; }
//        public bool IsAnonymous { get; private set; }
//        public string Name { get; private set; }
//        public string ParentName { get; private set; }
//        public string OrderBy { get; set; }
//        public bool IsVirtual { get; }

//        public ScriptBlock Enumerate { get; set; }

//        public Iterator(string name, string parentName, IteratorParentType parentType, bool isAnonymous)
//        {
//            this.Name = name;
//            this.ParentName = parentName;
//            this.IteratorParentType = parentType;
//            this.IsAnonymous = isAnonymous;

//            this.IsVirtual = false;
//        }
//    }

//    public class VirtualIterator : IIterator
//    {
//        public string Name { get; }
//        public bool IsVirtual { get; }
//        public IteratorParentType IteratorParentType { get; }

//        public VirtualIterator(string name, IteratorParentType parentType)
//        {
//            this.Name = name;
//            this.IteratorParentType = parentType;

//            this.IsVirtual = true;
//        }
//    }

//    public class IteratorAdd
//    {
//        public string Name { get; private set; }
//        public bool IsAnonymous { get; private set; }
//        public bool IsVirtual { get; private set; }

//        public ScriptBlock Add { get; set; }

//        public IteratorAdd(string name, bool isAnonymous, bool isVirtual)
//        {
//            this.Name = name;
//            this.IsAnonymous = isAnonymous;
//            this.IsVirtual = isVirtual;
//        }
//    }

//    public class IteratorRemove
//    {
//        public string Name { get; private set; }
//        public bool IsAnonymous { get; private set; }
//        public bool IsVirtual { get; private set; }

//        public ScriptBlock Remove { get; set; }

//        public IteratorRemove(string name, bool isAnonymous, bool isVirtual)
//        {
//            this.Name = name;
//            this.IsAnonymous = isAnonymous;
//            this.IsVirtual = isVirtual;
//        }
//    }
//}

