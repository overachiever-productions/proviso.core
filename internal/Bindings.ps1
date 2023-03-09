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

function Bind-Expect {
	[CmdletBinding()]
	param (
		[ScriptBlock]$ExpectBlock
	);
	
	process {
		$parentBlockType = $global:PvLexicon.GetParentBlockType();
		$parentName = $global:PvLexicon.GetParentBlockName();
		$grandParentName = $global:PvLexicon.GetGrandParentBlockName();
		
		switch ($parentBlockType) {
			"Inclusion" {
				throw "Inclusiong BINDING not yet implemented";
			}
			"Property" {
				$parentProperty = $global:PvCatalog.GetPropertyDefinition($parentName, $grandParentName);
				$parentProperty.Expect = $ExpectBlock;
			}
			default {
				throw "Proviso Framework Error. Invalid Parent Block Type: [$($parentBlockType)] specified for Expect Block.";
			}
		}
	}
}

function Bind-Extract {
	[CmdletBinding()]
	param (
		[ScriptBlock]$ExtractBlock
	);
	
	process {
		$parentBlockType = $global:PvLexicon.GetParentBlockType();
		$parentName = $global:PvLexicon.GetParentBlockName();
		$grandParentName = $global:PvLexicon.GetGrandParentBlockName();
		
		switch ($parentBlockType) {
			"Inclusion" {
				throw "Inclusiong BINDING not yet implemented";
			}
			"Property" {
				$parentProperty = $global:PvCatalog.GetPropertyDefinition($parentName, $grandParentName);
				$parentProperty.Extract = $ExtractBlock;
			}
			default {
				throw "Proviso Framework Error. Invalid Parent Block Type: [$($parentBlockType)] specified for Extract Block.";
			}
		}
	}
}

function Bind-Compare {
	[CmdletBinding()]
	param (
		[ScriptBlock]$CompareBlock
	);
	
	process {
		$parentBlockType = $global:PvLexicon.GetParentBlockType();
		$parentName = $global:PvLexicon.GetParentBlockName();
		$grandParentName = $global:PvLexicon.GetGrandParentBlockName();
		
		switch ($parentBlockType) {
			"Inclusion" {
				throw "Inclusiong BINDING not yet implemented";
			}
			"Property" {
				$parentProperty = $global:PvCatalog.GetPropertyDefinition($parentName, $grandParentName);
				$parentProperty.Compare = $CompareBlock;
			}
			default {
				throw "Proviso Framework Error. Invalid Parent Block Type: [$($parentBlockType)] specified for Compare Block.";
			}
		}
	}
}


function Bind-Configure {
	[CmdletBinding()]
	param (
		[ScriptBlock]$ConfigureBlock
	);
	
	process {
		$parentBlockType = $global:PvLexicon.GetParentBlockType();
		$parentName = $global:PvLexicon.GetParentBlockName();
		$grandParentName = $global:PvLexicon.GetGrandParentBlockName();
		
		switch ($parentBlockType) {
			"Inclusion" {
				throw "Inclusiong BINDING not yet implemented";
			}
			"Property" {
				$parentProperty = $global:PvCatalog.GetPropertyDefinition($parentName, $grandParentName);
				$parentProperty.Configure = $ConfigureBlock;
			}
			default {
				throw "Proviso Framework Error. Invalid Parent Block Type: [$($parentBlockType)] specified for Configure Block.";
			}
		}
	}
}