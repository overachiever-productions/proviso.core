Set-StrictMode -Version 1.0;

<#
	Runbook
		[Setup]
		[Assertions]
			[Assert]
		Operations
			Implement 
			Implement
			Implement
		[Cleanup]

	Surface
		[Setup]
		[Assertions]
			[Assert]
		[Aspect]
			Facet | Pattern | [Import] -Pattern|Facet
				[Iterate] (for Pattern)
				[Add]	(Pattern)  - Install?
				[Remove] (Pattern) - Uninstall?
				Property | Cohort 
					Enumerate
					Add
					Remove
					Property (of Cohort - and... recurses)
					[Inclusion] (of Property | Cohort)
					Expect
					Extract
					[Compare]
					Configure

		[Cleanup]
#>


$global:PvOrthography = [Proviso.Core.Orthography]::Instance;

function Enter-Block {
	[CmdletBinding()]
	param (
		[Parameter(Mandatory)]
		[string]$Type,
		[string]$Name = $null
	);
	
	try {
		$PvOrthography.EnterBlock($Type, $Name);
	}
	catch {
		throw "Proviso Exception: $($_.Exception.Message) `r`t$($_.ScriptStackTrace) ";
	}
	
	Write-Debug "$(Get-DebugIndent)Entered $($Type): [$Name]";
}

function Exit-Block {
	[CmdletBinding()]
	param (
		[Parameter(Mandatory)]
		[string]$Type,
		[string]$Name = $null
	);
	
	Write-Debug "$(Get-DebugIndent) Exiting $($Type): [$Name]";
	
	try {
		$PvOrthography.ExitBlock($Type, $Name);
	}
	catch {
		throw "Proviso Exception: $($_.Exception.InnerException.Message) `r`t$($_.ScriptStackTrace) ";
	}
}

function Bind-Facet {
	[CmdletBinding()]
	param (
		[Proviso.Core.Definitions.FacetDefinition]$Facet
	);
	
	process {
		try {
			$parentBlockType = $global:PvOrthography.GetParentBlockType();
			$currentFacetType = $global:PvOrthography.GetCurrentBlockType();
			
			# TODO: Assess debug text for $facetType of Import... Or... is that done at discovery time? 
			switch ($parentBlockType) {
				"Facets" {
					Write-Debug "$(Get-DebugIndent)Bypassing Binding of $($currentFacetType): [$($Facet.Name) to Parent, because Parent is a $($currentFacetType)s wrapper.";
				}
				"Aspect" {
					Write-Debug "$(Get-DebugIndent) Binding $($currentFacetType): [$($Facet.Name)] to Aspect: [$($currentAspect.Name)].";
					$currentAspect.AddFacet($Facet);
				}
				"Surface" {
					$surfaceName = $global:PvOrthography.GetParentBlockName();
					
					Write-Debug "$(Get-DebugIndent)	Binding $($currentFacetType): [$($Facet.Name)] to Surface: [$surfaceName].";
					$currentSurface.AddFacet($Facet);
				}
			}
		}
		catch {
			throw "Exception in Bind-Facet: $($_.Exception.Message) `r`t$($_.ScriptStackTrace) ";
		}
	}
}

filter Get-CurrentBlockType {
	return $PvOrthography.GetCurrentBlockType();
}

filter Get-ParentBlockType {
	return $PvOrthography.GetParentBlockType();
}

filter Get-ParentBlockName {
	return $PvOrthography.GetParentBlockName();
}

filter Get-GrandParentBlockType {
	return $PvOrthography.GetGrandParentBlockType();
}

filter Get-GrandParentBlockName {
	return $PvOrthography.GetGrandParentBlockName();
}

filter Get-DebugIndent {
	return "`t" * $PvOrthography.CurrentDepth;
}

filter Get-FacetParentType {
	$ParentBlockType = $global:PvOrthography.GetParentBlockType();
	try {
		return [Proviso.Core.FacetParentType]$ParentBlockType;
	}
	catch {
		# MKC: It APPEARs that I only need this additional bit of error handling for Pester tests:
		# 		Specifically: I can NOT get 'stand-alone' Facets|Patterns to reach this logic in anything other than Pester.
		throw "Compilation Exception. [$currentFacetType] can NOT be a stand-alone (root-level) block (must be inside either an Aspect, Surface, or $($currentFacetType)s block).";
	}
}