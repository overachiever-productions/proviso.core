Set-StrictMode -Version 1.0;

function Iterator {
	
	param (
		[Parameter(Mandatory, Position = 0)]
		[ValidateNotNullOrEmpty()]
		[string]$Name,
		[Parameter(Mandatory, Position = 1)]
		[ScriptBlock]$IteratorBlock,
		
		# TODO: this might not even make sense. It's implemented as a STRING for now.
		[string]$OrderBy = $null
	);
	
	begin {
		[bool]$xVerbose = ("Continue" -eq $global:VerbosePreference) -or ($PSBoundParameters["Verbose"] -eq $true);
		[bool]$xDebug = ("Continue" -eq $global:DebugPreference) -or ($PSBoundParameters["Debug"] -eq $true);
		
		Enter-Block $MyInvocation.MyCommand -Name $Name -Verbose:$xVerbose -Debug:$xDebug;
	};
	
	process {
		$definition = New-Object Proviso.Core.Definitions.IteratorDefinition($Name, $true);
		
		if (Has-Value $OrderBy) {
			$definition.OrderBy = $OrderBy;
		}
		
		$definition.Iterate = $IteratorBlock;
		
		# BIND:
		# NOTE: EnumeraTORs (vs EnumeraTEs) do NOT get bound to parents during build - they're applied/imported during discovery. 
		
		# STORE: 
		if ($global:PvOrthography.StoreIteratorDefinition($definition, (Allow-DefinitionReplacement))) {
			Write-Verbose "Iterator block: [$($definition.Name)] was replaced.";
		}
	};
	
	end {
		Exit-Block $MyInvocation.MyCommand -Name $Name -Verbose:$xVerbose -Debug:$xDebug;
	};
}