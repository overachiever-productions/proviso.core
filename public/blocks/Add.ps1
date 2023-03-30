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
		
		if ("Enumerator" -eq $addType) {
			Bind-EnumeratorAdd -Add $addDefinition -Verbose:$xVerbose -Debug:$xDebug;
		}
		else {
			Bind-IteratorAdd -Add $addDefinition -Verbose:$xVerbose -Debug:$xDebug;
		}
	};
	
	end {
		Exit-Block $MyInvocation.MyCommand -Name $AddName -Verbose:$xVerbose -Debug:$xDebug;
	};
}

function Bind-EnumeratorAdd {
	[CmdletBinding()]
	param (
		[Proviso.Core.Definitions.EnumeratorAddDefinition]$Add
	);
	
	process {
		try {
			$parentBlockType = $global:PvOrthography.GetParentBlockType();
			
			if ("Cohort" -eq $parentBlockType) {
				$parentName = $global:PvOrthography.GetParentBlockName();
				$grandParentName = $global:PvOrthography.GetGrandParentBlockName();
				$parent = $global:PvOrthography.GetCohortDefinition($parentName, $grandParentName);
				
				Write-Debug "$(Get-DebugIndent)	Binding Enumerate-Add to Cohort: [$($parentName)].";
				
				$parent.Add = $Add;
			}
			
			# TODO: i don't need to pass in parentBlock name - should be able to GET that fro the the $Add itself, right? 
			# TODO: ONLY store Adds if they're non-anonymous?
			if ($global:PvOrthography.StoreAddDefinition($Add, $parentBlockType, $parentBlockName, (Allow-DefinitionReplacement))) {
				Write-Verbose "Add block replaced.";
			}
			
		}
		catch {
			throw "Exception in Bind-EnumeratorAdd: $($_.Exception.Message) `r`t$($_.ScriptStackTrace) ";
		}
	}
}

function Bind-IteratorAdd {
	[CmdletBinding()]
	param (
		[Proviso.Core.Definitions.IteratorAddDefinition]$Add
	);
	
	process {
		try {
			$parentBlockType = $global:PvOrthography.GetParentBlockType();
			
			if ("Pattern" -eq $parentBlockType) {
				$parentName = $global:PvOrthography.GetParentBlockName();
				$grandParentName = $global:PvOrthography.GetGrandParentBlockName();
				$parent = $global:PvOrthography.GetFacetDefinitionByName($parentName, $grandParentName);
				
				Write-Debug "$(Get-DebugIndent)		Binding Iterator-Add to parent Pattern: [$parentName] -> GrandParent: [$grandParentName]";
				
				$parent.AddIterateAdd($Add);
				
				if ($global:PvOrthography.StoreAddDefinition($Add, $parentBlockType, $parentBlockName, (Allow-DefinitionReplacement))) {
					Write-Verbose "Add block replaced.";
				}
			}
		}
		catch {
			throw "Exception in Bind-IteratorAdd: $($_.Exception.Message) `r`t$($_.ScriptStackTrace) ";
		}
	}
}