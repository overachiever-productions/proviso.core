Set-StrictMode -Version 1.0;

$global:PvCatalog = [Proviso.Core.Catalog]::Instance;

function Add-FacetToCatalog {
	[CmdletBinding()]
	param (
		[Parameter(Mandatory, Position = 0)]
		[Proviso.Core.Models.Facet]$Facet
	);
	$PvCatalog.AddFacet($Facet);
}

function Get-FacetFromCatalog {
	[CmdletBinding()]
	param (
		[string]$Id,
		[string]$Name,
		[string]$ParentName
	);
	
	if (Has-Value $Id) {
		Write-Debug "	Attempting to load Facet: [$Id] from Catalog.";
		
		$output = $global:PvCatalog.GetFacetById($Id);
		
		if ($null -ne $output) {
			return $output;
		}
	}
	
	Write-Debug "	Attempting to load Facet: [$Name] from Catalog.";
	$output = $PvCatalog.GetFacetByName($Name, $ParentName);
	
	return $output;
}