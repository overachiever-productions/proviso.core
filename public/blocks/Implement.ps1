Set-StrictMode -Version 1.0;

<#

	Allows 'Execution' of a Facet from within a Runbook.

	REFACTOR: MIGHT change this to 'Run' - i.e., that's what a RUNbook does... 

#>

function Implement {
	[CmdletBinding()]
	param (
# TODO: Implement -Facet (or ditch)
#		[switch]$Facet, 	# syntactic sugar
		[Parameter(Mandatory, Position = 0)]
		[string]$SurfaceName,
		
# TODO: pretty sure these should be added (i.e., path options - and, if present, they overwrite/re-write for the Facet in question? only... that'd 'cascade' on down into Aspects, Facets, Cohorts|Properties and the likes.)
#		[string]$ModelPath = $null,
#		[string]$TargetPath = $null,
#		[string]$Path,
		[string]$DisplayFormat = $null,
		[ValidateSet("None", "Low", "Medium", "High")]
		[string]$Impact = "None",
		[switch]$Skip = $false,
		[string]$Ignore = $null
		
# TODO: 
# 		add other params as needed.
		
	);
	
	begin {
		[bool]$xVerbose = ("Continue" -eq $global:VerbosePreference) -or ($PSBoundParameters["Verbose"] -eq $true);
		[bool]$xDebug = ("Continue" -eq $global:DebugPreference) -or ($PSBoundParameters["Debug"] -eq $true);
		
		Enter-Block $MyInvocation.MyCommand -Name $SurfaceName -Verbose:$xVerbose -Debug:$xDebug;
	};
	
	process {
		$grandParentBlockType = Get-GrandParentBlockType;
		$grandParentBlockName = Get-GrandParentBlockName;
		
		Write-Verbose "Compiling Facet Inclusion for Surface [$SurfaceName] via Implement for Runbook: [$grandParentBlockName].";
		
		[Proviso.Core.Definitions.ImplementDefinition]$implement = New-Object Proviso.Core.Definitions.ImplementDefinition($SurfaceName);
		
		# TODO: address skip/ignore... 
		
		# TODO: address any other parameters as needed... 
		
		try{
			$runbook.AddFacetImplementationReference($implement);
		}
		catch {
			throw "$($_.Exception.Message) `r`t$($_.ScriptStackTrace) ";
		}
	};
	
	end {
		Exit-Block $MyInvocation.MyCommand -Name $SurfaceName -Verbose:$xVerbose -Debug:$xDebug;
	};
}