Set-StrictMode -Version 1.0;

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
		[string]$parentBlockType = $global:PvLexicon.GetCurrentBlockType();
		[string]$parentBlockName = $global:PvLexicon.GetCurrentBlockName();
		
		Enter-Block ($MyInvocation.MyCommand) -Name (Collapse-Arguments -Arg1 $Name -Arg2 $parentBlockName -IgnoreEmptyStrings) -Verbose:$xVerbose -Debug:$xDebug;
	};
	
	process {
		Write-Verbose "Processing Remove Block for [$parentBlockType]: [$parentBlockName].";
		
		switch ($parentBlockType) {
			"Pattern" {
				Write-Debug "				Processing Remove Block for Pattern: [$parentBlockName].";
				$removeDefinition = New-Object Proviso.Core.Definitions.IteratorRemoveDefinition($Name, $Impact, $RemoveBlock);
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
		
		try {
			[bool]$replaced = $global:PvCatalog.StoreRemoveDefinition($removeDefinition, $parentBlockType, $parentBlockName, (Allow-DefinitionReplacement));
			
			if ($replaced) {
				Write-Verbose "Remove block replaced.";
			}
		}
		catch {
			throw "$($_.Exception.InnerException.Message) `r`t$($_.ScriptStackTrace) ";
		}
	};
	
	end {
		Exit-Block $MyInvocation.MyCommand -Name $Name -Verbose:$xVerbose -Debug:$xDebug;
	};
}