﻿Set-StrictMode -Version 1.0;

function Remove {
	[CmdletBinding()]
	param (
		[string]$Name = $null,
		[ValidateSet("None", "Low", "Medium", "High")]
		[string]$Impact = "None",
		[ScriptBlock]$RemoveBlock
	);
	
	begin {
		[bool]$xVerbose = ("Continue" -eq $global:VerbosePreference) -or ($PSBoundParameters["Verbose"] -eq $true);
		[bool]$xDebug = ("Continue" -eq $global:DebugPreference) -or ($PSBoundParameters["Debug"] -eq $true);
		
		# NOTE: a BIT confusing to call 'current' but we HAVEN'T YET 'entered' this Remove block yet.
		[string]$parentBlockType = $global:PvOrthography.GetCurrentBlockType();
		[string]$parentBlockName = $global:PvOrthography.GetCurrentBlockName();
		
		Enter-Block ($MyInvocation.MyCommand) -Name (Collapse-Arguments -Arg1 $Name -Arg2 $parentBlockName -IgnoreEmptyStrings) -Verbose:$xVerbose -Debug:$xDebug;
	};
	
	process {
		Write-Verbose "Processing Remove Block for [$parentBlockType]: [$parentBlockName].";
		
		$removeType = "Enumerator";
		switch ($parentBlockType) {
			"Pattern" {
				Write-Debug "				Processing Remove Block for Pattern: [$parentBlockName].";
				$removeDefinition = New-Object Proviso.Core.Definitions.IteratorRemoveDefinition($Name, $Impact, $RemoveBlock);
				$removeType = "Iterator";
			}
			"Cohort" {
				Write-Debug "				Processing Remove Block for Cohort: [$parentBlockName].";
				$removeDefinition = New-Object Proviso.Core.Definitions.EnumeratorRemoveDefinition($Name, $Impact, $RemoveBlock);
			}
			"Iterators" {
				if (Is-Empty $Name) {
					throw "Syntax Error. Globally defined Remove blocks for Iterators MUST have a -Name (and the -Name must match the -Name for the associated Iterator).";
				}
				
				Write-Debug "				Processing Remove Block for Global Iterator: [$Name].";
				$removeDefinition = New-Object Proviso.Core.Definitions.IteratorRemoveDefinition($Name, $Impact, $RemoveBlock);
				$removeType = "Iterator";
			}
			"Enumerators" {
				if (Is-Empty $Name) {
					throw "Syntax Error. Globally defined Remove blocks for Enumerators MUST have a -Name (and the -Name must match the -Name for the associated Enumerator).";
				}
				
				Write-Debug "				Processing Remove Block for Global Enumerator [$Name]";
				$removeDefinition = New-Object Proviso.Core.Definitions.EnumeratorRemoveDefinition($Name, $Impact, $RemoveBlock);
			}
			default {
				throw
			}
		}
		
		$removeDefinition.ScriptBlock = $RemoveBlock;
		
		if ("Enumerator" -eq $removeType) {
			Bind-EnumeratorRemove -Remove $removeDefinition -Verbose:$xVerbose -Debug:$xDebug;
		}
		else {
			Bind-IteratorRemove -Remove $removeDefinition -Verbose:$xVerbose -Debug:$xDebug;
		}
	};
	
	end {
		Exit-Block $MyInvocation.MyCommand -Name $Name -Verbose:$xVerbose -Debug:$xDebug;
	};
}

function Bind-EnumeratorRemove {
	[CmdletBinding()]
	param (
		[Proviso.Core.Definitions.EnumeratorRemoveDefinition]$Remove
	);
	
	process {
		try {
			$parentBlockType = $global:PvOrthography.GetParentBlockType();
			
			if ("Cohort" -eq $parentBlockType) {
				$parentName = $global:PvOrthography.GetParentBlockName();
				$grandParentName = $global:PvOrthography.GetGrandParentBlockName();
				$parent = $global:PvOrthography.GetCohortDefinition($parentName, $grandParentName);
				
				Write-Debug "$(Get-DebugIndent)	Binding Enumerate-Remove to Cohort: [$($parentName)].";
				
				$parent.Remove = $Remove;
			}
			
			if ($global:PvOrthography.StoreRemoveDefinition($Remove, (Allow-DefinitionReplacement))) {
				Write-Verbose "Remove block replaced.";
			}
		}
		catch {
			throw "Exception in Bind-EnumeratorRemove: $($_.Exception.Message) `r`t$($_.ScriptStackTrace) ";
		}
	}
}

function Bind-IteratorRemove {
	[CmdletBinding()]
	param (
		[Proviso.Core.Definitions.IteratorRemoveDefinition]$Remove
	);
	
	process {
		try {
			$parentBlockType = $global:PvOrthography.GetParentBlockType();
			if ("Pattern" -eq $parentBlockType) {
				$parentName = $global:PvOrthography.GetParentBlockName();
				$grandParentName = $global:PvOrthography.GetGrandParentBlockName();
				$parent = $global:PvOrthography.GetFacetDefinitionByName($parentName, $grandParentName);
				
				Write-Debug "$(Get-DebugIndent)		Binding Iterator-Remove to parent Pattern: [$parentName] -> GrandParent: [$grandParentName]";
				
				$parent.AddIterateRemove($Remove);
			}
			
			if ($global:PvOrthography.StoreRemoveDefinition($Remove, (Allow-DefinitionReplacement))) {
				Write-Verbose "Remove block replaced.";
			}
		}
		catch {
			throw "Exception in Bind-IteratorRemove: $($_.Exception.Message) `r`t$($_.ScriptStackTrace) ";
		}
		
	}
}