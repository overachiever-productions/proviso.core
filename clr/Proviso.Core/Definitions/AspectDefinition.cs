namespace Proviso.Core.Definitions
{
    public class AspectDefinition : DefinitionBase
    {
        public AspectDefinition(string name, string modelPath, string targetPath, bool skip, string skipReason) 
            : base(name, modelPath, targetPath, skip, skipReason)
        {
        }
    }
}