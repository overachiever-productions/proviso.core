Set-StrictMode -Version 1.0;

function Bind-Property {
	[CmdletBinding()]
	param (
		[Proviso.Core.Definitions.PropertyDefinition]$Property
	);
	
	process {
		switch ($Property.ParentType) {
			"Properties" {
				Write-Debug "		NOT Binding Property: [$($Property.Name)] to parent, because parent is a Properties wrapper.";
			}
			"Cohort" {
				$grandParentName = $global:PvLexicon.GetGrandParentBlockName();
				$parent = $global:PvCatalog.GetCohortDefinition($Property.ParentName, $grandParentName);
				$parent.AddChildProperty($Property);
			}
			{ $_ -in @("Facet", "Pattern") } {
				$parentType = $global:PvLexicon.GetParentBlockType();
				$grandParentName = $global:PvLexicon.GetGrandParentBlockName();
				$parent = $global:PvCatalog.GetFacetDefinitionByName($Property.ParentName, $grandParentName);
				
				Write-Debug "				Binding Property [$($Property.Name)] to Parent of Type [$parentType], named: [$($Property.ParentName)], with a grandparent named: [$grandParentName].";
				
				$parent.AddChildProperty($Property);
			}
			default {
				throw "Proviso Framework Error. Invalid Property Parent: [$($Property.ParentType)] specified.";
			}
		}
	}
}

function Bind-Cohort {
	[CmdletBinding()]
	param (
		[Proviso.Core.Definitions.CohortDefinition]$Cohort
	);
	
	process {
		switch ($Cohort.ParentType) {
			"Cohorts" {
				Write-Debug "		NOT Binding Cohort: [$($Cohort.Name)] to parent, because parent is a Cohorts wrapper.";
			}
			{ $_ -in @("Facet", "Pattern") } {
				$parentType = $global:PvLexicon.GetParentBlockType();
				$grandParentName = $global:PvLexicon.GetGrandParentBlockName();
				$parent = $global:PvCatalog.GetFacetDefinitionByName($Cohort.ParentName, $grandParentName);
				
				Write-Debug "				Binding Cohort [$($Cohort.Name)] to Parent of Type [$parentType], named: [$($Cohort.ParentName)], with a grandparent named: [$grandParentName].";
				
				$parent.AddChildCohort($Cohort);
			}
			default {
				throw "Proviso Framework Error. Invalid Cohort Parent: [$($Cohort.ParentType)] specified.";
			}
		}
	}
}

function Bind-Enumerate {
	[CmdletBinding()]
	param (
		[Proviso.Core.Definitions.EnumeratorDefinition]$Enumerate
	);
	
	process {
		$grandParentName = $global:PvLexicon.GetGrandParentBlockName();
		$cohort = $global:PvCatalog.GetCohortDefinition($Enumerate.ParentName, $grandParentName);
		$cohort.AddEnumerate($Enumerate);
	}
}

function Bind-EnumeratorAdd {
	[CmdletBinding()]
	param (
		[Proviso.Core.Definitions.EnumeratorAddDefinition]$Add
	);
	
	process {
		$parentBlockType = $global:PvLexicon.GetParentBlockType();
		
		if ("Cohort" -eq $parentBlockType) {
			$parentName = $global:PvLexicon.GetParentBlockName();
			$grandParentName = $global:PvLexicon.GetGrandParentBlockName();
			$parent = $global:PvCatalog.GetCohortDefinition($parentName, $grandParentName);
			
			$parent.Add = $Add;
		}
	}
}

function Bind-EnumeratorRemove {
	[CmdletBinding()]
	param (
		[Proviso.Core.Definitions.EnumeratorRemoveDefinition]$Remove
	);
	
	process {
		$parentBlockType = $global:PvLexicon.GetParentBlockType();
		
		if ("Cohort" -eq $parentBlockType) {
			$parentName = $global:PvLexicon.GetParentBlockName();
			$grandParentName = $global:PvLexicon.GetGrandParentBlockName();
			$parent = $global:PvCatalog.GetCohortDefinition($parentName, $grandParentName);
			
			$parent.Remove = $Remove;
		}
	}
}

function Bind-Iterate {
	[CmdletBinding()]
	param (
		[Proviso.Core.Definitions.IteratorDefinition]$Iterate
	);
	
	process {
		$grandParentName = $global:PvLexicon.GetGrandParentBlockName();
		$pattern = $global:PvCatalog.GetFacetDefinitionByName($Iterate.ParentName, $grandParentName);
		$pattern.AddIterate($Iterate);
	}
}

function Bind-IteratorAdd {
	[CmdletBinding()]
	param (
		[Proviso.Core.Definitions.IteratorAddDefinition]$Add
	);
	
	process {
		$parentBlockType = $global:PvLexicon.GetParentBlockType();
		
		if ("Pattern" -eq $parentBlockType) {
			$parentName = $global:PvLexicon.GetParentBlockName();
			$grandParentName = $global:PvLexicon.GetGrandParentBlockName();
			$parent = $global:PvCatalog.GetFacetDefinitionByName($parentName, $grandParentName);
			
			Write-Debug "					Binding Iterator-Add to parent Pattern: [$parentName] -> GrandParent: [$grandParentName]";
			
			$parent.AddIterateAdd($Add);
		}
	}
}

function Bind-IteratorRemove {
	[CmdletBinding()]
	param (
		[Proviso.Core.Definitions.IteratorRemoveDefinition]$Remove
	);
	
	process {
		$parentBlockType = $global:PvLexicon.GetParentBlockType();
		if ("Pattern" -eq $parentBlockType) {
			$parentName = $global:PvLexicon.GetParentBlockName();
			$grandParentName = $global:PvLexicon.GetGrandParentBlockName();
			$parent = $global:PvCatalog.GetFacetDefinitionByName($parentName, $grandParentName);
			
			Write-Debug "					Binding Iterator-Remove to parent Pattern: [$parentName] -> GrandParent: [$grandParentName]";
			
			$parent.AddIterateRemove($Remove);
		}
	}
}

function Bind-Facet {
	[CmdletBinding()]
	param (
		[Proviso.Core.Definitions.FacetDefinition]$Facet
	);
	
	process {
		$parentBlockType = $global:PvLexicon.GetParentBlockType();
		$facetType = $Facet.FacetType;
		if ("Scalar" -eq $facetType) {
			$facetType = "Facet";
		}
		
		# TODO: Asses debug text for $facetType of Import... 
		
		switch ($parentBlockType) {
			"Facets" {
				Write-Debug "		Bypassing Binding of $($facetType): [$($Facet.Name) to parent, because parent is a $($facetType)s wrapper.";
			}
			"Aspect" {
				Write-Host "I should be binding $($facetType): [$($Facet.Name)] to ... Aspect? "
			}
			"Surface" {
				$surfaceName = $global:PvLexicon.GetParentBlockName();
				$surface = $global:PvCatalog.GetSurfaceDefinition($surfaceName);
				Write-Debug "			Binding $($facetType): [$($Facet.Name)] to Surface: [$surfaceName].";
				
				$surface.AddFacet($Facet);
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

filter Get-FacetParentType {
	$ParentBlockType = $global:PvLexicon.GetParentBlockType();
	return [Proviso.Core.FacetParentType]$ParentBlockType;
}