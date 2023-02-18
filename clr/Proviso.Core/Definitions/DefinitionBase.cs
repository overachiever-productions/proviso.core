using Proviso.Core.Interfaces;

namespace Proviso.Core.Definitions
{
    public class DefinitionBase : IDefinable
    {
        public string Name { get; private set; }
        public string ModelPath { get; private set; }
        public string TargetPath { get; private set; }
        public bool Skip { get; private set; }
        public string SkipReason { get; private set; }
        public Impact Impact { get; set; }

        public DefinitionBase(string name, string modelPath, string targetPath, bool skip, string skipReason)
        {
            this.Name = name;
            this.ModelPath = modelPath;
            this.TargetPath = targetPath;
            this.Skip = skip;
            this.SkipReason = skipReason;
        }

        public void SetExpectFromParameter(object expect)
        {
            // NOTE: I've been tempted to think about using ... PSON code/examples as a way to figure out what TYPE of object we've got here. 
            //      but i don't NEED to. 
            //      instead, I need to simply STORE this 'value' as ... an OBJECT 
            //      and let that get passed on DOWN the line ... until it becomes a 'code block' of return $object;
            //          COMPARISONS (i.e., the Compare func) will handle object types, etc. 
        }

        public void SetExtractFromParameter(object expect)
        {
            // DITTO.
        }

        public void SetThrowOnConfig(string message)
        {
            
        }
    }
}