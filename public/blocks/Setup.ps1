Set-StrictMode -Version 1.0;

function Setup {
	[CmdletBinding()]
	param (
		[ScriptBlock]$SetupBlock
	);
	
	begin {
		[bool]$xVerbose = ("Continue" -eq $global:VerbosePreference) -or ($PSBoundParameters["Verbose"] -eq $true);
		[bool]$xDebug = ("Continue" -eq $global:DebugPreference) -or ($PSBoundParameters["Debug"] -eq $true);
		
		$previousBlockType = Get-PreviousBlockType;
		
		Enter-Block $MyInvocation.MyCommand -Name $null -Verbose:$xVerbose -Debug:$xDebug;
	};
	
	process {
		if ("Runbook" -eq $previousBlockType) {
			$setup = New-Object Proviso.Core.Definitions.RunbookSetupDefintion($SetupBlock);
		}
		else {
			$setup = New-Object Proviso.Core.Definitions.SurfaceSetupDefinition($SetupBlock);
		}
		
		try {
			[bool]$replaced = $global:PvCatalog.SetSetupDefinition($setup, (Allow-DefinitionReplacement));
			
			if ($replaced) {
				Write-Verbose "$previousBlockType Setup was replaced.";
			}
		}
		catch {
			throw "$($_.Exception.InnerException.Message) `r`t$($_.ScriptStackTrace) ";
		}
	};
	
	end {
		Exit-Block $MyInvocation.MyCommand -Name $null -Verbose:$xVerbose -Debug:$xDebug;
	};
}