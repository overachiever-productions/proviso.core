Set-StrictMode -Version 1.0;

function Setup {
	[CmdletBinding()]
	param (
		[ScriptBlock]$SetupBlock
	);
	
	begin {
		[bool]$xVerbose = ("Continue" -eq $global:VerbosePreference) -or ($PSBoundParameters["Verbose"] -eq $true);
		[bool]$xDebug = ("Continue" -eq $global:DebugPreference) -or ($PSBoundParameters["Debug"] -eq $true);
		
		Enter-Block $MyInvocation.MyCommand -Name $null -Verbose:$xVerbose -Debug:$xDebug;
	};
	
	process {
		$parentBlockType = Get-ParentBlockType;
	
		if ("Runbook" -eq $parentBlockType) {
			$setup = New-Object Proviso.Core.Definitions.RunbookSetupDefinition($SetupBlock);
		}
		else {
			$setup = New-Object Proviso.Core.Definitions.SurfaceSetupDefinition($SetupBlock);
		}
		
		try {
			[bool]$replaced = $global:PvCatalog.SetSubBlockDefinition($setup, (Allow-DefinitionReplacement));
			
			if ($replaced) {
				Write-Verbose "$($parentBlockType).Setup was replaced.";
			}
		}
		catch {
			throw "$($_.Exception.Message) `r`t$($_.ScriptStackTrace) ";
		}
	};
	
	end {
		Exit-Block $MyInvocation.MyCommand -Name $null -Verbose:$xVerbose -Debug:$xDebug;
	};
}