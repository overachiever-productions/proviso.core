Set-StrictMode -Version 1.0;

function Cleanup {
	[CmdletBinding()]
	param (
		[ScriptBlock]$CleanupBlock
	);
	
	begin {
		[bool]$xVerbose = ("Continue" -eq $global:VerbosePreference) -or ($PSBoundParameters["Verbose"] -eq $true);
		[bool]$xDebug = ("Continue" -eq $global:DebugPreference) -or ($PSBoundParameters["Debug"] -eq $true);
		
		Enter-Block $MyInvocation.MyCommand -Name $null -Verbose:$xVerbose -Debug:$xDebug;
	};
	
	process {
		$parentBlockType = Get-ParentBlockType;
		
		if ("Runbook" -eq $parentBlockType) {
			$cleanup = New-Object Proviso.Core.Definitions.RunbookCleanupDefinition($CleanupBlock);
		}
		else {
			$cleanup = New-Object Proviso.Core.Definitions.SurfaceCleanupDefinition($CleanupBlock);
		}
		
		try {
			[bool]$replaced = $global:PvCatalog.SetSubBlockDefinition($cleanup, (Allow-DefinitionReplacement));
			
			if ($replaced) {
				Write-Verbose "$($parentBlockType).Cleanup was replaced.";
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