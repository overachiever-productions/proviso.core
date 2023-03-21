Set-StrictMode -Version 1.0;

<#

	Wrapper for globally defined Facets and Patterns.

#>

function Facets {
	[CmdletBinding()]
	[Alias('Patterns')]
	param (
		[Parameter(Mandatory, Position = 0, ParameterSetName = 'Named')]
		[Alias('FacetsSetName', 'PatternsSetName')]
		[string]$Name = $null,
		
		[Parameter(Mandatory, Position = 1, ParameterSetName = 'Named')]
		[Parameter(Mandatory, Position = 0, ParameterSetName = 'Anonymous')]
		[ScriptBlock]$FacetsBlock
	);
	
	begin {
		[bool]$xVerbose = ("Continue" -eq $global:VerbosePreference) -or ($PSBoundParameters["Verbose"] -eq $true);
		[bool]$xDebug = ("Continue" -eq $global:DebugPreference) -or ($PSBoundParameters["Debug"] -eq $true);
		
		Enter-Block $MyInvocation.MyCommand -Name $Name -Verbose:$xVerbose -Debug:$xDebug;
	};
	
	process {
		
		& $FacetsBlock;
	};
	
	end {
		Exit-Block $MyInvocation.MyCommand -Name $null -Verbose:$xVerbose -Debug:$xDebug;
	};
}