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
		
		try {
			Bind-Iterate -Iterate $definition -Verbose:$xVerbose -Debug:$xDebug;
			
			# TODO: only goes in catalog if there's a name, right?
			[bool]$replaced = $global:PvOrthography.StoreIteratorDefinition($definition, (Allow-DefinitionReplacement));
			
			if ($replaced) {
				$replacedName = "for Pattern [$Name]";
				if ($isGlobal) {
					$replacedName = "named [$Name]";
				}
				Write-Verbose "Iterate block $replacedName was replaced.";
			}
		}
		catch {
			throw "$($_.Exception.Message) `r`t$($_.ScriptStackTrace) ";
		}
	};
	
	end {
		Exit-Block $MyInvocation.MyCommand -Name $Name -Verbose:$xVerbose -Debug:$xDebug;
	};
}