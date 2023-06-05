Set-StrictMode -Version 1.0;

$global:PvBlockStore = [Proviso.Core.BlockStore]::Instance;

function Add-FacetToBlockStore {
	[CmdletBinding()]
	param (
		[Parameter(Mandatory, Position = 0)]
		[Proviso.Core.Models.Facet]$Facet,
		[bool]$AllowReplace = $false
	);
	
	if ($PvBlockStore.StoreFacet($Facet, $AllowReplace)) {
		Write-Verbose "Facet: [$Name] was replaced.";
	}
}

function Store-Pattern {
	
}

function Get-FacetFromBlockStore {
	[CmdletBinding()]
	param (
		[string]$Name,
		[string]$ParentName
	);
	
	return $PvBlockStore.GetFacetByName($Name, $ParentName);
}