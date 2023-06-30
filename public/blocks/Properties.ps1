Set-StrictMode -Version 1.0;

<#
	2 Locations / Uses:
		A. Members of a Pattern (i.e., list of properties to apply against the Instances node)
		B. Wrapper for globally defined (re-usable) properties. 
			AND. I Might change this to GlobalProperties or ReusableProperties instead of mere 'Properties'.
			either way, this is a vNEXT or a 'nah/never' kind of thing.
#>


function Properties {
	[CmdletBinding()]
	param (
		[Parameter(Mandatory, Position = 0, ParameterSetName = 'Named')]
		[string]$Name,
		[Parameter(Mandatory, Position = 1, ParameterSetName = 'Named')]
		[parameter(Mandatory, Position = 0, ParameterSetName = 'Anonymous')]
		[ScriptBlock]$PropertiesBlock
	);
	
	begin {
		[bool]$xVerbose = ("Continue" -eq $global:VerbosePreference) -or ($PSBoundParameters["Verbose"] -eq $true);
		[bool]$xDebug = ("Continue" -eq $global:DebugPreference) -or ($PSBoundParameters["Debug"] -eq $true);
		
		Enter-Block $MyInvocation.MyCommand -Name $Name -Verbose:$xVerbose -Debug:$xDebug;
	};
	
	process {
		
		& $PropertiesBlock;
	};
	
	end {
		Exit-Block $MyInvocation.MyCommand -Name $null -Verbose:$xVerbose -Debug:$xDebug;
	};
}