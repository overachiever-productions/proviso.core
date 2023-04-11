Set-StrictMode -Version 1.0;

<#

	Import-Module -Name "D:\Dropbox\Repositories\proviso.core" -Force;

	$global:DebugPreference = "Continue";
	#$global:VerbosePreference = "Continue";

	Cohorts {
		Cohort "Global Property - Add Test 3 " -Path "/something/{widget}/etc" {
			Enumerate "widget" { }
			Add "widget" {
				# code for Add implementation
			}
		}
	}

#>

function Add {
	[CmdletBinding()]
	param (
		[Parameter(Mandatory, Position = 0, ParameterSetName = 'Named')]
		[Alias('Name')]
		[string]$AddName = $null,
		[Parameter(Mandatory, Position = 1, ParameterSetName = 'Named')]
		[Parameter(Mandatory, Position = 0, ParameterSetName = 'Anonymous')]
		[ScriptBlock]$AddBlock
	);
	
	begin {
		[bool]$xVerbose = ("Continue" -eq $global:VerbosePreference) -or ($PSBoundParameters["Verbose"] -eq $true);
		[bool]$xDebug = ("Continue" -eq $global:DebugPreference) -or ($PSBoundParameters["Debug"] -eq $true);
		
		# NOTE: a BIT confusing to call 'current'; but we HAVEN'T 'entered' this Add block YET.
		[string]$parentBlockType = $global:PvOrthography.GetCurrentBlockType();
		[string]$parentBlockName = $global:PvOrthography.GetCurrentBlockName();
		
		# NOTE: For both iterate/enumerate blocks, if non-named (i.e., anonymous), we use the name of the PARENT block (hence the logic below for -Name)
		Enter-Block ($MyInvocation.MyCommand) -Name (Collapse-Arguments -Arg1 $AddName -Arg2 $parentBlockName -IgnoreEmptyStrings) -Verbose:$xVerbose -Debug:$xDebug;
	};
	
	process {
		Write-Verbose "Processing Add Block for [$parentBlockType]: [$parentBlockName].";
		
		$addType = "Enumerator";
		switch ($parentBlockType) {
			"Pattern" {
				Write-Debug "				Processing Add Block for Pattern: [$parentBlockName].";
				$addDefinition = New-Object Proviso.Core.Definitions.IteratorAddDefinition($AddName, $AddBlock);
				$addType = "Iterator";
			}
			"Cohort" {
				Write-Debug "				Processing Add Block for Cohort: [$parentBlockName].";
				$addDefinition = New-Object Proviso.Core.Definitions.EnumeratorAddDefinition($AddName, $AddBlock);
			}
			"Iterators" {
				if (Is-Empty $AddName) {
					throw "Syntax Error. Globally defined Add blocks for Iterators MUST have a -Name (and the -Name must match the -Name for the associated Iterator).";
				}
				
				Write-Debug "				Processing Add Block for Global Iterator: [$AddName].";
				$addDefinition = New-Object Proviso.Core.Definitions.IteratorAddDefinition($AddName, $AddBlock);
				$addType = "Iterator";
			}
			"Enumerators" {
				if (Is-Empty $AddName) {
					throw "Syntax Error. Globally defined Add blocks for Enumerators MUST have a -Name (and the -Name must match the -Name for the associated Enumerator).";
				}
				
				Write-Debug "				Processing Add Block for Global Enumerator [$AddName]";
				$addDefinition = New-Object Proviso.Core.Definitions.EnumeratorAddDefinition($AddName, $AddBlock);
			}
			default {
				throw "Proviso Framework Error. Invalid Parent for Add block.";
			}
		}
		
		 # BIND:
		if ("Enumerator" -eq $addType) {
			Write-Debug "$(Get-DebugIndent)	Binding Enumerate-Add to Cohort: [$($addDefinition.ParentName)].";
			
			$currentCohort.Add = $addDefinition;
		}
		else {
			$grandParentName = $global:PvOrthography.GetGrandParentBlockName();
			Write-Debug "$(Get-DebugIndent)		Binding Iterator-Add to parent Pattern: [$parentBlockName] -> GrandParent: [$grandParentName]";
			
			$currentPattern.AddIterateAdd($addDefinition);
		}
		
		# STORE:
		if (Has-Value $AddName) {
			if ($global:PvOrthography.StoreAddDefinition($addDefinition, (Allow-DefinitionReplacement))) {
				Write-Verbose "Add block replaced.";
			}
		}
	};
	
	end {
		Exit-Block $MyInvocation.MyCommand -Name $AddName -Verbose:$xVerbose -Debug:$xDebug;
	};
}