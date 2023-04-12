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
		
		# BIND: 
		# NOTE: Enumerators (not Enumerates) do NOT get bound to any kind of parent at this point - they are 'applied' during discovery.
		
		# STORE: 
		if ($global:PvOrthography.StoreEnumeratorDefinition($definition, (Allow-DefinitionReplacement))) {
			$replacedName = "for Enumerator [$Name]";
			if ($isGlobal) {
				$replacedName = "named [$Name]";
			}
			Write-Verbose "Enumerate block $replacedName was replaced.";
		}
	};
	
	end {
		Exit-Block $MyInvocation.MyCommand -Name $Name -Verbose:$xVerbose -Debug:$xDebug;
	};
}