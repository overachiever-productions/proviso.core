Set-StrictMode -Version 1.0;

function Surface {
	[CmdletBinding()]
	param (
		[Parameter(Mandatory, Position = 0)]
		[string]$Name,
		[Parameter(Mandatory, Position = 1)]
		[ScriptBlock]$ScriptBlock,
		[string]$ModelPath = $null,
		[string]$TargetPath = $null,
		[string]$Path,
		[ValidateSet("None", "Low", "Medium", "High")]
		[string]$Impact = "None",
		[switch]$Skip = $false,  # surfaces CAN be skipped/ignored when they're part of a runbook
		[string]$Ignore = $null,
		# TODO: still need to work on these semantics:
		[string[]]$ImpactsSurfaces = $null
	);
	
	begin {
		[bool]$xVerbose = ("Continue" -eq $global:VerbosePreference) -or ($PSBoundParameters["Verbose"] -eq $true);
		[bool]$xDebug = ("Continue" -eq $global:DebugPreference) -or ($PSBoundParameters["Debug"] -eq $true);
		Enter-Block $MyInvocation.MyCommand -Name $Name -Verbose:$xVerbose -Debug:$xDebug;
	};
	
	process {
		$bypass = Is-ByPassed $MyInvocation.MyCommand.Name -Name $Name -Skip:$Skip -Ignore $Ignore -Verbose:$xVerbose -Debug:$xDebug;
		
		if (Should-SetPaths $MyInvocation.MyCommand.Name -Name $Name -ModelPath $ModelPath -TargetPath $TargetPath -Path $Path -Verbose:$xVerbose -Debug:$xDebug) {
			$ModelPath, $TargetPath = $Path;
		}
		
		
		& $ScriptBlock;
	};
	
	end {
#		try {
#			$global:PvCatalog.AddSurfaceDefinition($definition);
#		}
#		catch {
#			throw "$($_.Exception.InnerException.Message) `r`t$($_.ScriptStackTrace) ";
#		}
		
		
		Exit-Block $MyInvocation.MyCommand -Name $Name -Verbose:$xVerbose -Debug:$xDebug;
	};
}