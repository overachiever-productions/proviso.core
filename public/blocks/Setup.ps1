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
		$parentBlockName = Get-ParentBlockName;
		
		Write-Verbose "Compiling .Setup{} for $parentBlockType named [$parentBlockName].";
		
		try {
			if ("Runbook" -eq $parentBlockType) {
				$runbook.Setup = $SetupBlock;
				Write-Debug "		Added Setup{ } to Runbook: [$parentBlockName].";
			}
			else {
				$surface.Setup = $SetupBlock;
				Write-Debug "		Added Setup{ } to Surface: [$parentBlockName].";
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