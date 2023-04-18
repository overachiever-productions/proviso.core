Set-StrictMode -Version 1.0;

function Remove {
	[CmdletBinding()]
	param (
		[Parameter(Mandatory, Position = 0, ParameterSetName = 'Named')]
		[string]$Name = $null,
		[Parameter(Mandatory, Position = 1, ParameterSetName = 'Named')]
		[Parameter(Mandatory, Position = 0, ParameterSetName = 'Anonymous')]
		[ScriptBlock]$RemoveBlock,
		[ValidateSet("None", "Low", "Medium", "High")]
		[string]$Impact = "None"
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
				Write-Debug "$(Get-DebugIndent)		Processing Remove Block for Pattern: [$parentBlockName].";
				$removeDefinition = New-Object Proviso.Core.Definitions.IteratorRemoveDefinition($Name, $Impact, $RemoveBlock);
				$removeType = "Iterator";
			}
			"Cohort" {
				Write-Debug "$(Get-DebugIndent)		Processing Remove Block for Cohort: [$parentBlockName].";
				$removeDefinition = New-Object Proviso.Core.Definitions.EnumeratorRemoveDefinition($Name, $Impact, $RemoveBlock);
			}
			"Iterators" {
				if (Is-Empty $Name) {
					throw "Syntax Error. Globally defined Remove blocks for Iterators MUST have a -Name (and the -Name must match the -Name for the associated Iterator).";
				}
				
				Write-Debug "$(Get-DebugIndent)		Processing Remove Block for Global Iterator: [$Name].";
				$removeDefinition = New-Object Proviso.Core.Definitions.IteratorRemoveDefinition($Name, $Impact, $RemoveBlock);
				$removeType = "Iterator";
			}
			"Enumerators" {
				if (Is-Empty $Name) {
					throw "Syntax Error. Globally defined Remove blocks for Enumerators MUST have a -Name (and the -Name must match the -Name for the associated Enumerator).";
				}
				
				Write-Debug "$(Get-DebugIndent)		Processing Remove Block for Global Enumerator [$Name]";
				$removeDefinition = New-Object Proviso.Core.Definitions.EnumeratorRemoveDefinition($Name, $Impact, $RemoveBlock);
			}
			default {
				throw
			}
		}
		
		$removeDefinition.ScriptBlock = $RemoveBlock;
		
		# BIND:
		if ("Enumerator" -eq $removeType) {
			Write-Debug "$(Get-DebugIndent)	Binding Enumerate-Remove to Cohort: [$($currentCohort.Name)].";
			
			$currentCohort.Remove = $removeDefinition
		}
		else {
			$grandParentName = $global:PvOrthography.GetGrandParentBlockName();
			Write-Debug "$(Get-DebugIndent)		Binding Iterator-Remove to parent Pattern: [$parentBlockName] -> GrandParent: [$grandParentName]";
			
			$currentPattern.AddIterateRemove($removeDefinition);
		}
		
		# STORE: 
		if (Has-Value $Name) {
			if ($global:PvOrthography.StoreRemoveDefinition($Remove, (Allow-DefinitionReplacement))) {
				Write-Verbose "Remove block replaced.";
			}
		}
	};
	
	end {
		Exit-Block $MyInvocation.MyCommand -Name $Name -Verbose:$xVerbose -Debug:$xDebug;
	};
}