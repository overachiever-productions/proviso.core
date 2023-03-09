Set-StrictMode -Version 1.0;

<#

	Wrapper for globally defined Cohorts.

#>


function Cohorts {
	[CmdletBinding()]
	param (
		[Alias('CohortsSetName')]
		[string]$Name,
		[ScriptBlock]$CohortsBlock
	);
	
	begin {
		[bool]$xVerbose = ("Continue" -eq $global:VerbosePreference) -or ($PSBoundParameters["Verbose"] -eq $true);
		[bool]$xDebug = ("Continue" -eq $global:DebugPreference) -or ($PSBoundParameters["Debug"] -eq $true);
		
		Enter-Block $MyInvocation.MyCommand -Name $Name -Verbose:$xVerbose -Debug:$xDebug;
	};
	
	process {
		
		$CohortsBlock;
	};
	
	end {
		Exit-Block $MyInvocation.MyCommand -Name $null -Verbose:$xVerbose -Debug:$xDebug;
	};
}