Set-StrictMode -Version 1.0;

function Get-Facet {
	[CmdletBinding()]
	param (
		# TODO: set up different paramter sets here... 
		[string]$Id,
		[Parameter(Mandatory)]
		[string]$Name,
		[string]$ParentName
	);
	
	begin {
		[bool]$xVerbose = ("Continue" -eq $global:VerbosePreference) -or ($PSBoundParameters["Verbose"] -eq $true);
		[bool]$xDebug = ("Continue" -eq $global:DebugPreference) -or ($PSBoundParameters["Debug"] -eq $true);
	}
	
	process {
		[Proviso.Core.Models.Facet]$facet = Get-FacetFromCatalog -Id $Id -Name $Name -ParentName $ParentName -Verbose:$xVerbose -Debug:$xDebug;
		
		if ($null -eq $facet) {
			Write-Debug "		Facet: [$Name] not found in Catalog. Attempting to load definition (for registration).";
			
			[Proviso.Core.Models.Facet]$definition = $null;
			
			# TODO: ... what about .. by Id? (guess that would be another signature/call into Read-Facet - i.e., it'd pass down 
			# 		the Id ... and then ... I'd pass that around until here? )
			# 		and yeah... it probably makes sense to maybe implement some different signatures (in the block store) for that?
			$definition = Get-FacetFromBlockStore -Name $Name -ParentName $ParentName -Verbose:$xVerbose -Debug:$xDebug;
			if ($null -eq $definition) {
				throw "Processing Error. Facet: [$Name] was NOT found.";
			}
			
			Write-Debug "		Facet: [$Name] definition found. Attempting Registration.";
			
			$facet = Register-Facet -Name $Name -ParentName $ParentName -OverWrite:(Allow-DefinitionReplacement) -Verbose:$xVerbose -Debug:$xDebug;
		}
		
		return $facet;
	}
}