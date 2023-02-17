namespace Proviso.Core
{
    public class CompilationMonitor
    {
        public string Runbook { get; set; }
        public string Surface { get; set; }
        public string Aspect { get; set; }
        public string Facet { get; set; }
        public string Property { get; set; }

        public static CompilationMonitor Instance => new CompilationMonitor();

        private CompilationMonitor()
        {
            this.Runbook = null;
            this.Surface = null;
            this.Aspect = null;
            this.Facet = null;
            this.Property = null;
        }
    }
}