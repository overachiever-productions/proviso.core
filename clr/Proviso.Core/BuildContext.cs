﻿using System;
using System.Linq;
using System.Collections.Generic;

namespace Proviso.Core
{
    public class BuildContext
    {
        private List<Taxonomy> _grammar;
        private Stack<Taxonomy> _stack;
        private Stack<string> _namesStack;
        private Dictionary<string, string> _currentBlocks;
        private Taxonomy _currentParent;

        public int CurrentDepth => this._stack.Count;

        public static BuildContext Current = new BuildContext();

        private BuildContext()
        {
            this._grammar = Taxonomy.Grammar();
            this._stack = new Stack<Taxonomy>();
            this._namesStack = new Stack<string>();
            this._currentBlocks = new Dictionary<string, string>();

            this._currentParent = null;
        }

        public void EnterBlock(string blockType, string blockName)
        {
            Taxonomy taxonomy = this._grammar.Find(t => t.NodeName == blockType);
            if (taxonomy == null)
                throw new InvalidOperationException($"Unsupported ScriptBlock: [{blockType}].");

            if (this._currentParent == null)
            {
                if (!taxonomy.Rootable)
                    throw new InvalidOperationException(
                        $"ScriptBlock [{blockType}] can NOT be a stand-alone (root-level) block.");

                this._currentParent = taxonomy;
                this.PushCurrentTaxonomy(taxonomy, blockName);

                return;
            }

            if (taxonomy.RequiresName && string.IsNullOrWhiteSpace(blockName))
                throw new Exception($"A -Name is required for block-parentType: [{blockType}].");

            if (!taxonomy.NameAllowed && !string.IsNullOrWhiteSpace(blockName))
                throw new Exception($"[{blockType}] may NOT have a -Name (current -Name is [{blockName}]).");

            Taxonomy parent = this._stack.Peek();
            if (!taxonomy.AllowedParents.Contains(parent.NodeName))
                throw new InvalidOperationException(
                    $"ScriptBlock [{blockType}] can NOT be a child of: [{parent.NodeName}].");

            // TODO: account for wildcards here. (and... just use Regex.IsMatch(currentBlockName, taxonomy.WildcardPattern)  ...    
            // TODO: also, I THINK this is/could-be where I account for .AllowedChildren? (if not, remove them from grammar).
            this.PushCurrentTaxonomy(taxonomy, blockName);
        }

        // TODO: Either REQUIRE blockName to be the same as what was handed in via Enter (as an additional validation/test)
        //          OR, remove it from being an argument. One or the other. 
        //      EXCEPT: Setup/Assertions/Cleanup (for both Runbooks AND Surfaces) do NOT have names (and can't have names).
        public void ExitBlock(string blockType, string blockName)
        {
            Taxonomy taxonomy = this._grammar.Find(t => t.NodeName == blockType);
            if (taxonomy == null)
                throw new InvalidOperationException(
                    $"Proviso Framework Error. Unexpected ScriptBlock Terminator: [{blockType}].");

            this._stack.Pop();
            this._currentBlocks[blockType] = null;
            this._namesStack.Pop();

            if (this._stack.Count > 0)
            {
                Taxonomy previous = this._stack.Peek();

            }
            else
            {
                this._currentParent = null;
            }
        }

        //public string GetCurrentRunbookName()
        //{
        //    return this.GetCurrentBlockNameByType("Runbook");
        //}

        //public string GetCurrentSurfaceName()
        //{
        //    return this.GetCurrentBlockNameByType("Surface");
        //}

        //public string GetCurrentAspectName()
        //{
        //    return this.GetCurrentBlockNameByType("Aspect");
        //}

        //public string GetCurrentFacetName()
        //{
        //    return this.GetCurrentBlockNameByType("Facet");
        //}

        //public string GetCurrentPatternName()
        //{
        //    return this.GetCurrentBlockNameByType("Pattern");
        //}

        //public string GetCurrentCohortName()
        //{
        //    return this.GetCurrentBlockNameByType("Cohort");
        //}

        public string GetCurrentBlockName()
        {
            if (this._namesStack.Count > 0)
                return this._namesStack.Peek();

            return "";
        }

        public string GetCurrentBlockType()
        {
            if (this._stack.Count > 0)
            {
                var current = this._stack.Peek();  // i.e., CURRENT is what's on the TOP of the stack.
                return current.NodeName;
            }

            return "";
        }

        public string GetParentBlockName()
        {
            if (this._namesStack.Count > 1)
            {
                return this._namesStack.Skip(1).First();
            }

            return "";
        }

        public string GetParentBlockType()
        {
            if (this._stack.Count > 1)
            {
                var parent = this._stack.Skip(1).First();
                return parent.NodeName;
            }

            return "";
        }

        public string GetGrandParentBlockName()
        {
            if (this._namesStack.Count > 2)
            {
                return this._namesStack.Skip(2).First();
            }

            return "";
        }

        public string GetGrandParentBlockType()
        {
            if (this._stack.Count > 2)
            {
                var grandparent = this._stack.Skip(2).First();
                return grandparent.NodeName;
            }

            return "";
        }

        private string GetCurrentBlockNameByType(string type)
        {
            if (this._currentBlocks.ContainsKey(type))
                return this._currentBlocks[type];

            return null;
        }

        private void PushCurrentTaxonomy(Taxonomy current, string blockName)
        {
            this._stack.Push(current);

            this._namesStack.Push(blockName);

            if (current.Tracked)
            {
                if (this._currentBlocks.ContainsKey(current.NodeName))
                    this._currentBlocks[current.NodeName] = blockName;
                else
                    this._currentBlocks.Add(current.NodeName, blockName);
            }
        }
    }
}