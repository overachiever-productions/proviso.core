Set-StrictMode -Version 1.0;

function Bind-Property {
	[CmdletBinding()]
	param (
		[Proviso.Core.Definitions.PropertyDefinition]$Property
	);
	
	process {
		switch ($Property.ParentType) {
			"Properties" {
				Write-Debug "Bypassing Binding of Property: [$($Property.Name)] to parent, because parent is a Properties wrapper.";
			}
			"Cohort" {
				$grandParentName = $global:PvLexicon.GetGrandParentBlockName();
				$parent = $global:PvCatalog.GetCohortDefinition($Property.ParentName, $grandParentName);
				$parent.AddChildProperty($Property);
			}
			{ $_ -in @("Facet", "Pattern") } {
				$parent = $global:PvCatalog.GetFacetDefinitionByName($Property.ParentName);
				$parent.AddChildProperty($Property);
			}
			default {
				throw "Proviso Framework Error. Invalid Property-Type Parent: [$($Property.ParentType)] specified.";
			}
		}
	}
}