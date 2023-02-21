using System;
using System.Collections.Generic;

namespace Proviso.Core
{
    public class Lexicon
    {
        private List<Taxonomy> _grammar;
        private Stack<Taxonomy> _stack;
        private Stack<string> _namesStack;
        private Dictionary<string, string> _currentBlocks;

        private Taxonomy _currentParent;
        private Taxonomy _currentNode; // REFACTOR: insanely enough, I NEVER use this. 

        public int CurrentDepth => this._stack.Count;

        public static Lexicon Instance => new Lexicon();

        private Lexicon()
        {
            this._grammar = Taxonomy.Grammar();
            this._stack = new Stack<Taxonomy>();
            this._namesStack = new Stack<string>();
            this._currentBlocks = new Dictionary<string, string>();

            this._currentParent = null;
            this._currentNode = null;
        }

        public string GetCurrentRunbook()
        {
            return this.GetCurrentBlockNameByType("Runbook");
        }

        public string GetCurrentSurface()
        {
            return this.GetCurrentBlockNameByType("Surface");
        }

        public string GetCurrentAspect()
        {
            return this.GetCurrentBlockNameByType("Aspect");
        }

        public string GetCurrentFacet()
        {
            return this.GetCurrentBlockNameByType("Facet");
        }

        public string GetCurrentCohort()
        {
            return this.GetCurrentBlockNameByType("Cohort");
        }

        public string GetCurrentBlockName()
        {
            if(this._namesStack.Count > 0)
                return this._namesStack.Peek();

            return "";
        }

        public string GetCurrentBlockNameByType(string type)
        {
            if (this._currentBlocks.ContainsKey(type))
                return this._currentBlocks[type];

            return null;
        }

        public string GetPreviousBlockType()
        {
            if (this._stack.Count > 0)
            {
                var previous = this._stack.Peek();
                return previous.NodeName;
            }

            return null;
        }

        public void EnterBlock(string blockType, string blockName)
        {
            Taxonomy taxonomy = this._grammar.Find(t => t.NodeName == blockType);
            if (taxonomy == null)
                throw new InvalidOperationException($"Unsupported ScriptBlock: [{blockType}].");

            if (this._currentParent == null)
            {
                if (!taxonomy.Rootable)
                    throw new InvalidOperationException($"ScriptBlock [{blockType}] can NOT be a stand-alone (root-level) block.");

                this._currentParent = taxonomy;
                this.PushCurrentTaxonomy(taxonomy, blockName);

                return;
            }

            if (taxonomy.RequiresName && string.IsNullOrWhiteSpace(blockName))
                throw new Exception($"A -Name is required for block-type: [{blockType}].");

            if (!taxonomy.NameAllowed && !string.IsNullOrWhiteSpace(blockName))
                throw new Exception($"[{blockType}] may NOT have a -Name (current -Name is [{blockName}]).");

            // TODO: is it ... _possible_ to check AllowedChildren? I've DEFINED which children are allowed in the grammar... 
            //  but i'm never using it... 

            Taxonomy parent = this._stack.Peek();
            if(!taxonomy.AllowedParents.Contains(parent.NodeName)) 
                throw new InvalidOperationException($"ScriptBlock [{blockType}] can NOT be a child of: [{parent.NodeName}].");

            this.PushCurrentTaxonomy(taxonomy, blockName);
        }

        // TODO: Either REQUIRE blockName to be the same as what was handed in via Enter (as an additional validation/test)
        //          OR, remove it from being an argument. One or the other. 
        //      EXCEPT: Setup/Assertions/Cleanup (for both Runbooks AND Surfaces) do NOT have names (and can't have names).
        public void ExitBlock(string blockType, string blockName)
        {
            Taxonomy taxonomy = this._grammar.Find(t => t.NodeName == blockType);
            if (taxonomy == null)
                throw new InvalidOperationException($"Proviso Framework Error. Unexpected ScriptBlock Terminator: [{blockType}].");

            this._stack.Pop();
            this._currentBlocks[blockType] = null;
            this._namesStack.Pop();

            if (this._stack.Count > 0)
            {
                Taxonomy previous = this._stack.Peek();
                this._currentNode = previous;
                
            }
            else
            {
                this._currentNode = null;
                this._currentParent = null;
            } 
        }

        private void PushCurrentTaxonomy(Taxonomy current, string blockName)
        {
            this._currentNode = current;
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