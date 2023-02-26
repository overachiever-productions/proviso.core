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
		$parentBlockName = Get-ParentBlockName;
		
		Write-Verbose "Compiling .Cleanup{} for $parentBlockType named [$parentBlockName].";
		
		try {
			if ("Runbook" -eq $parentBlockType) {
				$runbook.Cleanup = $CleanupBlock;
				Write-Debug "		Added Cleanup{ } to Runbook: [$parentBlockName].";
			}
			else {
				$surface.Cleanup = $CleanupBlock;
				Write-Debug "		Added Cleanup{ } to Surface: [$parentBlockName].";
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