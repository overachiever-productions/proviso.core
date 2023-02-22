namespace Proviso.Core.Definitions
{
    public class ImplementDefinition
    {
        public string SurfaceName { get; private set; }
        public string DisplayFormat { get; private set; }

        public ImplementDefinition(string surfaceName)
        {
            this.SurfaceName = surfaceName;
        }
    }
}