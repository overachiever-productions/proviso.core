Set-StrictMode -Version 1.0;

<#

	Wrapper for globally defined Properties.

#>


function Properties {
	[CmdletBinding()]
	param (
		[Alias('PropertiesSetName')]
		[string]$Name,
		[ScriptBlock]$PropertiesBlock
	);
	
	begin {
		[bool]$xVerbose = ("Continue" -eq $global:VerbosePreference) -or ($PSBoundParameters["Verbose"] -eq $true);
		[bool]$xDebug = ("Continue" -eq $global:DebugPreference) -or ($PSBoundParameters["Debug"] -eq $true);
		
		Enter-Block $MyInvocation.MyCommand -Name $Name -Verbose:$xVerbose -Debug:$xDebug;
	};
	
	process {
		
		$PropertiesBlock;
	};
	
	end {
		Exit-Block $MyInvocation.MyCommand -Name $null -Verbose:$xVerbose -Debug:$xDebug;
	};
}