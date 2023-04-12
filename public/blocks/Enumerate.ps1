Set-StrictMode -Version 1.0;

function Enumerate {
	[CmdletBinding()]
	param (
		[Parameter(Mandatory, Position = 0, ParameterSetName = 'Named')]
		[string]$Name = $null,
		[Parameter(Position = 1, ParameterSetName = 'Named')]
		[parameter(Mandatory, Position = 0, ParameterSetName = 'Anonymous')]
		[ScriptBlock]$EnumerateBlock,
		
		# TODO: this might not even make sense. It's implemented as a STRING for now.
		[string]$OrderBy = $null
	);
	
	begin {
		[bool]$xVerbose = ("Continue" -eq $global:VerbosePreference) -or ($PSBoundParameters["Verbose"] -eq $true);
		[bool]$xDebug = ("Continue" -eq $global:DebugPreference) -or ($PSBoundParameters["Debug"] -eq $true);
		
		[bool]$isGlobal = $true;
		if (Is-Empty $Name) {
			$Name = $global:PvOrthography.GetCurrentCohort();
			$isGlobal = $false;  # name is inherited, i.e., this is equivalent of 'anonymous' (non-global).
		}
		
		Enter-Block $MyInvocation.MyCommand -Name $Name -Verbose:$xVerbose -Debug:$xDebug;
	};
	
	process {
		$parentName = $global:PvOrthography.GetParentBlockName();
		$definition = New-Object Proviso.Core.Definitions.EnumeratorDefinition($Name, $isGlobal, [Proviso.Core.EnumeratorParentType]"Cohort" ,$parentName);
		
		if (Has-Value $OrderBy) {
			$definition.OrderBy = $OrderBy;
		}
		
		$definition.Enumerate = $EnumerateBlock;
		
		# BIND: 
		Write-Debug "$(Get-DebugIndent)	Binding Enumrate to Cohort: [$($definition.ParentName)].";
		$currentCohort.AddEnumerate($definition);
		
		# STORE: 
		if (Has-Value $Name) {
			if ($global:PvOrthography.StoreEnumeratorDefinition($definition, (Allow-DefinitionReplacement))) {
				$replacedName = "for Cohort [$Name]";
				if ($isGlobal) {
					$replacedName = "named [$Name]";
				}
				Write-Verbose "Enumerate block $replacedName was replaced.";
			}
		}
	};
	
	end {
		Exit-Block $MyInvocation.MyCommand -Name $Name -Verbose:$xVerbose -Debug:$xDebug;
	};
}