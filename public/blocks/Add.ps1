Set-StrictMode -Version 1.0;

<#

	TODO:
		- MIGHT end up making sense to have Add-Member (cohort) and Add-Instance (patterns)
			a. that seems cleaner and more intuitive in the first place. 
			b. otherwise, worried about potential for someone to try and add an 'Add' for an enum into an Iterators {} block... etc. 

#>


function Add {
	[CmdletBinding()]
	param (
		[string]$Name = $null,
		[ScriptBlock]$AddBlock
	);
	
	begin {
		[bool]$xVerbose = ("Continue" -eq $global:VerbosePreference) -or ($PSBoundParameters["Verbose"] -eq $true);
		[bool]$xDebug = ("Continue" -eq $global:DebugPreference) -or ($PSBoundParameters["Debug"] -eq $true);
		
		# NOTE: a BIT confusing to call 'current'; but we HAVEN'T YET 'entered' this Add block yet.
		[string]$parentBlockType = $global:PvLexicon.GetCurrentBlockType();
		[string]$parentBlockName = $global:PvLexicon.GetCurrentBlockName();
		
		Enter-Block ($MyInvocation.MyCommand) -Name (Collapse-Arguments -Arg1 $Name -Arg2 $parentBlockName -IgnoreEmptyStrings) -Verbose:$xVerbose -Debug:$xDebug;
	};
	
	process {
		
		Write-Verbose "Processing Add Block for [$parentBlockType]: [$parentBlockName].";
		
		switch ($parentBlockType) {
			"Pattern" {
				Write-Debug "				Processing Add Block for Pattern: [$parentBlockName].";
				$addDefinition = New-Object Proviso.Core.Definitions.IteratorAddDefinition($Name, $AddBlock);
			}
			"Cohort" {
				Write-Debug "				Processing Add Block for Cohort: [$parentBlockName].";
				$addDefinition = New-Object Proviso.Core.Definitions.EnumeratorAddDefinition($Name, $AddBlock);
			}
			"Iterators" {
				if (Is-Empty $Name) {
					throw "Syntax Error. Globally defined Add blocks for Iterators MUST have a -Name (and the -Name must match the -Name for the associated Iterator).";
				}
				
				Write-Debug "				Processing Add Block for Global Iterator: [$Name].";
				$addDefinition = New-Object Proviso.Core.Definitions.IteratorAddDefinition($Name, $AddBlock);
			}
			"Enumerators" {
				if (Is-Empty $Name) {
					throw "Syntax Error. Globally defined Add blocks for Enumerators MUST have a -Name (and the -Name must match the -Name for the associated Enumerator).";
				}
				
				Write-Debug "				Processing Add Block for Global Enumerator [$Name]";
				$addDefinition = New-Object Proviso.Core.Definitions.EnumeratorAddDefinition($Name, $AddBlock);
			}
			default {
				throw 
			}
		}
		
		try {
			[bool]$replaced = $global:PvCatalog.StoreAddDefinition($addDefinition, $parentBlockType, $parentBlockName, (Allow-DefinitionReplacement));
			
			if ($replaced) {
				Write-Verbose "Add block replaced.";
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