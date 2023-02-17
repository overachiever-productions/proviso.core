namespace Proviso.Core
{
    public class BuildContext
    {
        public string Runbook { get; set; }
        public string Surface { get; set; }
        public string Aspect { get; set; }
        public string Facet { get; set; }
        public string Property { get; set; }

        public static BuildContext Instance => new BuildContext();

        private BuildContext()
        {
            this.Runbook = null;
            this.Surface = null;
            this.Aspect = null;
            this.Facet = null;
            this.Property = null;
        }
    }
}