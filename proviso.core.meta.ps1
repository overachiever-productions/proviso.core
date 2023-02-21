Set-StrictMode -Version 1.0;

filter Import-Types {
	param (
		[string]$ScriptRoot = $PSScriptRoot
	);
	
	# NOTE: Import order can/does impact BUILD operations
	$classFiles = @(
		"$ScriptRoot\clr\Proviso.Core\Enums\Enums.cs"
		
		"$ScriptRoot\clr\Proviso.Core\Interfaces\IDefinable.cs"
		"$ScriptRoot\clr\Proviso.Core\Interfaces\IValidated.cs"
		
		"$ScriptRoot\clr\Proviso.Core\Formatter.cs"
		"$ScriptRoot\clr\Proviso.Core\Taxonomy.cs"
		"$ScriptRoot\clr\Proviso.Core\Lexicon.cs"
		"$ScriptRoot\clr\Proviso.Core\Catalog.cs"
		
		"$ScriptRoot\clr\Proviso.Core\Definitions\DefinitionBase.cs"
		"$ScriptRoot\clr\Proviso.Core\Definitions\RunbookDefinition.cs"
		"$ScriptRoot\clr\Proviso.Core\Definitions\SurfaceDefinition.cs"
		"$ScriptRoot\clr\Proviso.Core\Definitions\AspectDefinition.cs"
		"$ScriptRoot\clr\Proviso.Core\Definitions\FacetDefinition.cs"
		"$ScriptRoot\clr\Proviso.Core\Definitions\PropertyDefinition.cs"
		"$ScriptRoot\clr\Proviso.Core\Definitions\CohortDefinition.cs"
		"$ScriptRoot\clr\Proviso.Core\Definitions\EnumeratorDefinition.cs"
		
		"$ScriptRoot\clr\Proviso.Core\Models\Runbook.cs"
		"$ScriptRoot\clr\Proviso.Core\Models\Surface.cs"
		"$ScriptRoot\clr\Proviso.Core\Models\Aspect.cs"
		"$ScriptRoot\clr\Proviso.Core\Models\Facet.cs"
		"$ScriptRoot\clr\Proviso.Core\Processing\ProcessingManifest.cs"
	);
	
	Add-Type -Path $classFiles;
}

Import-Types;