Set-StrictMode -Version 1.0;

function Enumerator {
	[CmdletBinding()]
	param (
		[Parameter(Mandatory, Position = 0)]
		[ValidateNotNullOrEmpty()]
		[string]$Name,
		[Parameter(Mandatory, Position = 1)]
		[ScriptBlock]$EnumeratorBlock,
		
		# TODO: this might not even make sense. It's implemented as a STRING for now.
		[string]$OrderBy = $null
	);
	
	begin {
		[bool]$xVerbose = ("Continue" -eq $global:VerbosePreference) -or ($PSBoundParameters["Verbose"] -eq $true);
		[bool]$xDebug = ("Continue" -eq $global:DebugPreference) -or ($PSBoundParameters["Debug"] -eq $true);
		
		Enter-Block $MyInvocation.MyCommand -Name $Name -Verbose:$xVerbose -Debug:$xDebug;
	};
	
	process {
		$parentName = $global:PvOrthography.GetParentBlockName(); # note, this CAN be empty... 
		$definition = New-Object Proviso.Core.Definitions.EnumeratorDefinition($Name, $true, [Proviso.Core.EnumeratorParentType]"Enumerators", $parentName);
		
		if (Has-Value $OrderBy) {
			$definition.OrderBy = $OrderBy;
		}
		
		$definition.Enumerate = $EnumeratorBlock;
		
		try {
			# NOTE: EnumeratORs do NOT get bound (at compile time) to their parent (they'll get bound during discovery).
			[bool]$replaced = $global:PvOrthography.StoreEnumeratorDefinition($definition, (Allow-DefinitionReplacement));
			
			if ($replaced) {
				Write-Verbose "Enumerator block named [$Name] was replaced.";
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