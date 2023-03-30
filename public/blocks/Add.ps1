Set-StrictMode -Version 1.0;

<#

#>

function Add {
	[CmdletBinding()]
	param (
		[Parameter(Mandatory, Position = 0, ParameterSetName = 'Named')]
		[Parameter(ParameterSetName = 'Anonymous')]
		[Alias('Name')]
		[string]$AddName = $null,
		[Parameter(Mandatory, Position = 1, ParameterSetName = 'Named')]
		[Parameter(Mandatory, Position = 0, ParameterSetName = 'Anonymous')]
		[ScriptBlock]$AddBlock
	);
	
	begin {
		[bool]$xVerbose = ("Continue" -eq $global:VerbosePreference) -or ($PSBoundParameters["Verbose"] -eq $true);
		[bool]$xDebug = ("Continue" -eq $global:DebugPreference) -or ($PSBoundParameters["Debug"] -eq $true);
		
		# NOTE: a BIT confusing to call 'current'; but we HAVEN'T YET 'entered' this Add block yet.
		[string]$parentBlockType = $global:PvOrthography.GetCurrentBlockType();
		[string]$parentBlockName = $global:PvOrthography.GetCurrentBlockName();
		
		# TODO: bug/error here... this shouldn't be passing in the name of the parent... 
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
				throw "Proviso Framework Error. Invalid Parent-Block-Type for Enumerate|Enumerator.";
			}
		}
		
		try {
			if ("Enumerator" -eq $addType) {
				Bind-EnumeratorAdd -Add $addDefinition -Verbose:$xVerbose -Debug:$xDebug;
			}
			else {
				Bind-IteratorAdd -Add $addDefinition -Verbose:$xVerbose -Debug:$xDebug;
			}
			
			[bool]$replaced = $global:PvOrthography.StoreAddDefinition($addDefinition, $parentBlockType, $parentBlockName, (Allow-DefinitionReplacement));
			
			if ($replaced) {
				Write-Verbose "Add block replaced.";
			}
		}
		catch {
			throw "$($_.Exception.Message) `r`t$($_.ScriptStackTrace) ";
		}
	};
	
	end {
		Exit-Block $MyInvocation.MyCommand -Name $AddName -Verbose:$xVerbose -Debug:$xDebug;
	};
}