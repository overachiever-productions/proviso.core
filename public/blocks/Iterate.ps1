Set-StrictMode -Version 1.0;

function Iterate {
	[CmdletBinding()]
	param (
		[Parameter(Mandatory, Position = 0, ParameterSetName = 'Named')]
		[string]$Name = $null,
		[Parameter(Position = 1, ParameterSetName = 'Named')]
		[parameter(Mandatory, Position = 0, ParameterSetName = 'Anonymous')]
		[ScriptBlock]$IterateBlock,
		
		# TODO: this might not even make sense. It's implemented as a STRING for now.
		[string]$OrderBy = $null
	);
	
	begin {
		[bool]$xVerbose = ("Continue" -eq $global:VerbosePreference) -or ($PSBoundParameters["Verbose"] -eq $true);
		[bool]$xDebug = ("Continue" -eq $global:DebugPreference) -or ($PSBoundParameters["Debug"] -eq $true);
		
		[bool]$isGlobal = $true;
		if (Is-Empty $Name) {
			$Name = $global:PvOrthography.GetCurrentPattern();
			$isGlobal = $false; # name is inherited, i.e., this is equivalent of 'anonymous' (non-global).
		}
		
		Enter-Block $MyInvocation.MyCommand -Name $Name -Verbose:$xVerbose -Debug:$xDebug;
	};
	
	process {
		$parentName = $global:PvOrthography.GetParentBlockName();
		$definition = New-Object Proviso.Core.Definitions.IteratorDefinition($Name, $isGlobal, [Proviso.Core.IteratorParentType]"Pattern", $parentName);
		
		if (Has-Value $OrderBy) {
			$definition.OrderBy = $OrderBy;
		}
		
		$definition.Iterate = $IterateBlock;
		Bind-Iterate -Iterate $definition -Verbose:$xVerbose -Debug:$xDebug;
	};
	
	end {
		Exit-Block $MyInvocation.MyCommand -Name $Name -Verbose:$xVerbose -Debug:$xDebug;
	};
}

function Bind-Iterate {
	[CmdletBinding()]
	param (
		[Proviso.Core.Definitions.IteratorDefinition]$Iterate
	);
	
	process {
		try {
			$grandParentName = $global:PvOrthography.GetGrandParentBlockName();
			$pattern = $global:PvOrthography.GetFacetDefinitionByName($Iterate.ParentName, $grandParentName);
			
			Write-Debug "$(Get-DebugIndent)	Binding Iterate to Pattern: [$($pattern.Name)].";
			
			$pattern.AddIterate($Iterate);
			
			if ($global:PvOrthography.StoreIteratorDefinition($Iterate, (Allow-DefinitionReplacement))) {
				$replacedName = "for Pattern [$Name]";
				# TODO: $isGlobal ACCIDENTALLY works here ... cuz it's declared in the previous (Iterate) scope... 
				if ($isGlobal) { 
					$replacedName = "named [$Name]";
				}
				Write-Verbose "Iterate block $replacedName was replaced.";
			}
		}
		catch {
			throw "Exception in Bind-Iterate: $($_.Exception.Message) `r`t$($_.ScriptStackTrace) ";
		}
	}
}