Set-StrictMode -Version 1.0;

function Bind-Property {
	[CmdletBinding()]
	param (
		[Proviso.Core.Definitions.PropertyDefinition]$Property
	);
	
	process {
		switch ($Property.ParentType) {
			"Properties" {
				Write-Debug "$(Get-DebugIndent)	NOT Binding Property: [$($Property.Name)] to parent, because parent is a Properties wrapper.";
			}
			"Cohort" {
				$grandParentName = $global:PvLexicon.GetGrandParentBlockName();
				$parent = $global:PvCatalog.GetCohortDefinition($Property.ParentName, $grandParentName);
				
				Write-Debug "$(Get-DebugIndent)	Binding Property [$($Property.Name)] to parent Cohort, named: [$($Property.ParentName)], with grandparent named: [$grandParentName].";
				
				$parent.AddChildProperty($Property);
			}
			{ $_ -in @("Facet", "Pattern") } {
				$parentType = $global:PvLexicon.GetParentBlockType();
				$grandParentName = $global:PvLexicon.GetGrandParentBlockName();
				$parent = $global:PvCatalog.GetFacetDefinitionByName($Property.ParentName, $grandParentName);
				
				Write-Debug "$(Get-DebugIndent)	Binding Property [$($Property.Name)] to Parent [$parentType], named: [$($Property.ParentName)], with grandparent named: [$grandParentName].";
				
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
				Write-Debug "$(Get-DebugIndent)	NOT Binding Cohort: [$($Cohort.Name)] to parent, because parent is a Cohorts wrapper.";
			}
			{ $_ -in @("Facet", "Pattern") } {
				$parentType = $global:PvLexicon.GetParentBlockType();
				$grandParentName = $global:PvLexicon.GetGrandParentBlockName();
				$parent = $global:PvCatalog.GetFacetDefinitionByName($Cohort.ParentName, $grandParentName);
				
				Write-Debug "$(Get-DebugIndent)	Binding Cohort [$($Cohort.Name)] to Parent of Type [$parentType], named: [$($Cohort.ParentName)], with a grandparent named: [$grandParentName].";
				
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
		
		Write-Debug "$(Get-DebugIndent)	Binding Enumrate to Cohort: [$($Enumerate.ParentName)].";
		
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
			
			Write-Debug "$(Get-DebugIndent)	Binding Enumerate-Add to Cohort: [$($parentName)].";
			
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
			
			Write-Debug "$(Get-DebugIndent)	Binding Enumerate-Remove to Cohort: [$($parentName)].";
			
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
		
		Write-Debug "$(Get-DebugIndent)	Binding Iterate to Pattern: [$($pattern.Name)].";
		
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
			
			Write-Debug "$(Get-DebugIndent)		Binding Iterator-Add to parent Pattern: [$parentName] -> GrandParent: [$grandParentName]";
			
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
			
			Write-Debug "$(Get-DebugIndent)		Binding Iterator-Remove to parent Pattern: [$parentName] -> GrandParent: [$grandParentName]";
			
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
		
		# TODO: Assess debug text for $facetType of Import... Or... is that done at discovery time? 
		
		switch ($parentBlockType) {
			"Facets" {
				Write-Debug "$(Get-DebugIndent)Bypassing Binding of $($currentFacetType): [$($Facet.Name) to parent, because parent is a $($currentFacetType)s wrapper.";
			}
			"Aspect" {
				Write-Debug "$(Get-DebugIndent) Binding $($currentFacetType): [$($Facet.Name)] to Aspect: [$($currentAspect.Name)].";
				$currentAspect.AddFacet($Facet);
			}
			"Surface" {
				$surfaceName = $global:PvLexicon.GetParentBlockName();
				
				Write-Debug "$(Get-DebugIndent)	Binding $($currentFacetType): [$($Facet.Name)] to Surface: [$surfaceName].";
				$currentSurface.AddFacet($Facet);
			}
		}
	}
}

function Bind-Aspect {
	[CmdletBinding()]
	param (
		[Proviso.Core.Definitions.AspectDefinition]$Aspect
	);
	
	process {
		$surfaceName = $global:PvLexicon.GetParentBlockName();
		$surface = $global:PvCatalog.GetSurfaceDefinition($surfaceName);
		
		Write-Debug "$(Get-DebugIndent)		Binding Aspect: [$($Aspect.Name)] to Surface: [$($surfaceName)].";
		$surface.AddAspect($Aspect);
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
				throw "Inclusion BINDING not yet implemented";
			}
			"Property" {
				$parentProperty = $global:PvCatalog.GetPropertyDefinition($parentName, $grandParentName);
				
				Write-Debug "$(Get-DebugIndent)		Binding Expect to Property: [$($parentName)].";
				
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
				
				Write-Debug "$(Get-DebugIndent)		Binding Extract to Property: [$($parentName)].";
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
				
				Write-Debug "$(Get-DebugIndent)		Binding Compare to Property: [$($parentName)].";
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
				
				Write-Debug "$(Get-DebugIndent)		Binding Configure to Property: [$($parentName)].";
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
	try {
		return [Proviso.Core.FacetParentType]$ParentBlockType;
	}
	catch {
		# MKC: It APPEARs that I only need this additional bit of error handling for Pester tests:
		# 		Specifically: I can NOT get 'stand-alone' Facets|Patterns to reach this logic in anything other than Pester.
		throw "Compilation Exception. [$currentFacetType] can NOT be a stand-alone (root-level) block (must be inside either an Aspect, Surface, or $($currentFacetType)s block).";
	}
}