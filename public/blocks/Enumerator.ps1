Set-StrictMode -Version 1.0;

function Enumerator {
	[CmdletBinding()]
	param (
		[Parameter(Mandatory, Position = 0)]
		[ValidateNotNullOrEmpty()]
		[string]$Name,
		[Parameter(Mandatory, Position = 1)]
		[ScriptBlock]$ScriptBlock,
		
		# TODO: this might not even make sense. It's implemented as a STRING for now.
		[string]$OrderBy = $null
	);
	
	begin {
		[bool]$xVerbose = ("Continue" -eq $global:VerbosePreference) -or ($PSBoundParameters["Verbose"] -eq $true);
		[bool]$xDebug = ("Continue" -eq $global:DebugPreference) -or ($PSBoundParameters["Debug"] -eq $true);
		
		Enter-Block $MyInvocation.MyCommand -Name $Name -Verbose:$xVerbose -Debug:$xDebug;
	};
	
	process {
		$definition = New-Object Proviso.Core.Definitions.EnumeratorDefinition($Name, $true);
		
		if (Has-Value $OrderBy) {
			$definition.OrderBy = $OrderBy;
		}
		
		$definition.Enumerate = $ScriptBlock;
	};
	
	end {
		try {
			[bool]$replaced = $global:PvCatalog.SetEnumeratorDefinition($definition, (Allow-DefinitionReplacement));
			
			if ($replaced) {
				Write-Verbose "Enumerator block named [$Name] was replaced.";
			}
		}
		catch {
			throw "$($_.Exception.InnerException.Message) `r`t$($_.ScriptStackTrace) ";
		}
		
		Exit-Block $MyInvocation.MyCommand -Name $Name -Verbose:$xVerbose -Debug:$xDebug;
	};
}