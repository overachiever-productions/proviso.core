Set-StrictMode -Version 1.0;

<#


#>

function Implement {
	[CmdletBinding()]
	param (
# TODO: Implement -Facet (or ditch)
#		[switch]$Facet, 	# syntactic sugar
		[Parameter(Mandatory, Position = 0)]
		[string]$FacetName
# TODO: 
# 		add other params as needed.
		
	);
	
	begin {
		[bool]$xVerbose = ("Continue" -eq $global:VerbosePreference) -or ($PSBoundParameters["Verbose"] -eq $true);
		[bool]$xDebug = ("Continue" -eq $global:DebugPreference) -or ($PSBoundParameters["Debug"] -eq $true);
		
		Enter-Block $MyInvocation.MyCommand -Name $FacetName -Verbose:$xVerbose -Debug:$xDebug;
	};
	
	process {
				
	};
	
	end {
		Exit-Block $MyInvocation.MyCommand -Name $FacetName -Verbose:$xVerbose -Debug:$xDebug;
	};
}