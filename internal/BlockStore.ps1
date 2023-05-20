﻿Set-StrictMode -Version 1.0;

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
	param (
		[string]$Name,
		[string]$ParentName
	);
	
	return $PvBlockStore.GetFacetByName($Name, $ParentName);
}

# SEE NOTES in Property.ps1 - down near the #STORE comment... 
#function Store-Property {
#	[CmdletBinding()]
#	param (
#		[Parameter(Mandatory, Position = 0)]
#		[Proviso.Core.Models.Property]$Property,
#		[bool]$AllowReplace = $false
#	);
#	
#	if ($PvBlockStore.StoreProperty($Property, $AllowReplace)) {
#		Write-Verbose "Property: [$Name] was replaced.";
#	}
#}
#
#function Store-Cohort {
#	
#}