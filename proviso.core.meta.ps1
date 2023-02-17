Set-StrictMode -Version 1.0;

filter Import-Types {
	param (
		[string]$ScriptRoot = $PSScriptRoot
	);
	
	$classFiles = @(
		"$ScriptRoot\clr\Proviso.Core\Formatter.cs"
		"$ScriptRoot\clr\Proviso.Core\Orthography.cs"
		"$ScriptRoot\clr\Proviso.Core\BuildContext.cs"
		"$ScriptRoot\clr\Proviso.Core\ProvisoCatalog.cs"
		"$ScriptRoot\clr\Proviso.Core\Models\Runbook.cs"
		"$ScriptRoot\clr\Proviso.Core\Models\Surface.cs"
		"$ScriptRoot\clr\Proviso.Core\Models\Aspect.cs"
		"$ScriptRoot\clr\Proviso.Core\Models\Facet.cs"
	);
	
	Add-Type -Path $classFiles;
}

Import-Types;