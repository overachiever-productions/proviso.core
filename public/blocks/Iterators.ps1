Set-StrictMode -Version 1.0;

<#

	Wrapper for globally defined Iterators, Adds, Removes.

#>


function Iterators {
	[CmdletBinding()]
	param (
		[Alias('IteratorsSetName')]
		[string]$Name,
		[ScriptBlock]$IteratorsBlock
	);
	
	begin {
		[bool]$xVerbose = ("Continue" -eq $global:VerbosePreference) -or ($PSBoundParameters["Verbose"] -eq $true);
		[bool]$xDebug = ("Continue" -eq $global:DebugPreference) -or ($PSBoundParameters["Debug"] -eq $true);
		
		Enter-Block $MyInvocation.MyCommand -Name $Name -Verbose:$xVerbose -Debug:$xDebug;
	};
	
	process {
		
		$IteratorsBlock;
	};
	
	end {
		Exit-Block $MyInvocation.MyCommand -Name $null -Verbose:$xVerbose -Debug:$xDebug;
	};
}