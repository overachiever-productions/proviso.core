Set-StrictMode -Version 1.0;

<#

	Import-Module -Name "D:\Dropbox\Repositories\proviso.core" -Force;

	$global:DebugPreference = "Continue";
	#$global:VerbosePreference = "Continue";

write-host "--------------------------------------------------"


	Facets {
		Facet "My First Facet" { }
	}

	#Read-Facet "My First Facet";

write-host "--------------------------------------------------"

	Surface "Extended Events" {
		Aspect "Named Aspect" {
			Facet "ANOTHER My First Facet" { }

			Pattern "My first Pattern" { 
				Iterate {}
				Add {}
				Remove {}

				Property "Do I need wrappers around Properties?" {}
				Property "No I don't need a parent wrapper" {}

				Cohort "Members Test" {
					Enumerate {
						return @("Piggly","Wiggly");
					}
					Add {
						# set some global array to $array + some new value or whatever... 
					}
					Remove {}
					Property "Cohort Property 1" {
						Expect {}
					}
					Property "Cohort Property 2" {}
				}
			}
		}
	}

	Facets {
		Facet "My Second Facet" { }
	}

	#Read-Facet "ANOTHER My First Facet" { } 
	

write-host "--------------------------------------------------"

	$facets = @(
		[PSCustomObject]@{ Name = "My First Facet" }
		[PSCustomObject]@{ Name = "ANOTHER My First Facet" }
		[PSCustomObject]@{ Name = "My Second Facet" }
		[PSCustomObject]@{ Name = "My first Pattern" }
	)

	#$facets | Read-Facet;

write-host "--------------------------------------------------"



#>

function Read-Facet {
	[CmdletBinding(DefaultParameterSetName = 'Default')]
	[Alias("Read-Pattern")]
	param (
		[Parameter(Mandatory, Position = 0, ParameterSetName = 'Default')]
		[Parameter(Mandatory, Position = 0, ParameterSetName = 'Targets')]
		[Parameter(Mandatory, Position = 0, ParameterSetName = 'Servers')]
		[Alias('FacetName', 'PatternName')]
		[string]$Name,
		[Parameter(ParameterSetName = 'Default')]
		[Parameter(ParameterSetName = 'Targets')]
		[Parameter(ParameterSetName = 'Servers')]
		[Alias('SurfaceName', 'AspectName')]
		[string]$ParentName,
		[Parameter(Mandatory, ValueFromPipeline, ParameterSetName = 'Targets')]
		[Parameter(ParameterSetName = 'Default')]
		[Parameter(ParameterSetName = 'Servers')]
		[Alias('Target')]
		[object[]]$Targets,
		[Parameter(Mandatory, ValueFromPipelineByPropertyName, ParameterSetName = 'Servers')]
		[Parameter(ParameterSetName = 'Default')]
		[Parameter(ParameterSetName = 'Targets')]
		[Alias('Host', 'Hosts', 'Server', 'Computer', 'Computers', 'ComputerName', 'ComputerNames')]
		[string[]]$Servers = $null,
		[Parameter(ParameterSetName = 'Default')]
		[Parameter(ParameterSetName = 'Targets')]
		[Parameter(ParameterSetName = 'Servers')]
		[switch]$AsPSON = $false,
		[Parameter(ParameterSetName = 'Default')]
		[Parameter(ParameterSetName = 'Targets')]
		[Parameter(ParameterSetName = 'Servers')]
		[PSCredential]$Credential
	);
	
	begin {
		[bool]$xVerbose = ("Continue" -eq $global:VerbosePreference) -or ($PSBoundParameters["Verbose"] -eq $true);
		[bool]$xDebug = ("Continue" -eq $global:DebugPreference) -or ($PSBoundParameters["Debug"] -eq $true);
		
		# Retrieve from Catalog + Validate (Discovery-Phase):
		[Proviso.Core.Definitions.FacetDefinition]$definition = $null;
		$definition = $global:PvCatalog.GetFacetDefinitionByName($Name, $ParentName);
		if ($null -eq $definition) {
			throw "Processing Error. Pattern or Facet: [$Name] was NOT found.";
		}
		
		[Proviso.Core.Models.Facet]$facetOrPattern = $null;
		try {
			# options here: Register-Facet (probably my best option)... or: Import-Facet, or even Assert-Facet or ... Initialize-Facet or ... Confirm-Facet. 
			# 			confirm sucks... and ... initialize works... but isn't exactly what I'm shooting for. 
			#   and... maybe what I need to do here is: 
			#    	a) PvCatalog ends up being a registry/catalog of 'COMPILED' things - like facets, surfaces, runbooks and any other resources. 
			# 		b) what I'm CURRENTLY calling the PvCatalog could be more of a dictionary/lexicon/register... that is used ONLY for build operations? 
			#  			and, yeah, the above is what I need to do... 
			# 				as in: BUILD is 'my problem/domain' - something that I have to tackle as the framework author... 
			# 				but the $PvCatalog is what 'users' can/will use to register  (or unregister) any of their objects and so on... 
			# 				as in: 'my' stuff/dictionary/whatever is hidden and internal ... whereas the 'catalog' is public and can have objects added/removed.
Write-Host "herro?"
			$facetOrPattern = Register-Facet -Facet $Name -Parent $ParentName -Verbose:$xVerbose -Debug:$xDebug;
		}
		catch {
			throw "Proviso Validation Error. Facet or Pattern: [$Name] failed validation: $($_.Exception.Message) `r`t$($_.ScriptStackTrace) ";
		}
		
		if ($null -eq $facetOrPattern) {
			throw "Could not find Pattern or Facet: [$Name].";
		}
		
		$results = @();  # MUST be declared here to be able to be in scope for all pipeline'd operations... 
	};
	
	process {
		if (Has-ArrayValue $Servers) {
			foreach ($s in $Servers) {
				if (Has-ArrayValue $Targets) {
					foreach ($t in $Targets) {
						$results += Process-ReadFacet -Facet $facetOrPattern -ServerName $s -Target $t -Credential $Credential -Verbose:$xVerbose -Debug:$xDebug;
					}
				}
				else {
					$results += Process-ReadFacet -Facet $facetOrPattern -ServerName $s -Credential $Credential -Verbose:$xVerbose -Debug:$xDebug;
				}
			}
		}
		else {
			if (Has-ArrayValue $Targets) {
				foreach ($t in $Targets) {
					$results += Process-ReadFacet -Facet $facetOrPattern -Target $t -Verbose:$xVerbose -Debug:$xDebug;
				}
			}
			else {
				$results += Process-ReadFacet -Facet $facetOrPattern -Verbose:$xVerbose -Debug:$xDebug;
			}
		}
	};
	
	end {
		if ($AsPSON) {
			
			throw "-AsPSON is not yet implemented.";
		}
		
		return $results;  # TODO: might need to declare this (early on/initially) as an array of ... FacetProcessingResults of whatever ... 
	};
}

# NOTE: No -Config or -Model for Read operations (just -Targets as an option):
function Process-ReadFacet {
	[CmdletBinding()]
	param (
		[Parameter(Mandatory)]
		[Proviso.Core.Models.Facet]$Facet,
		[string]$ServerName = $null,
		[object]$Target = $null,
		[PSCredential]$Credential
	);
	
	begin {
		
		if (Has-Value $ServerName) {
			
			# NOTE: attempt to use Creds if/as supplied? 
			
			Write-Host "need to validate server: $ServerName";
			# as in, make sure that a) we can connect to it (resolve it), b) it has same version of Proviso.Core on it. 
			
			# also, it MIGHT make sense to look into caching whether a server is accessible or not? 
		}
	};
	
	process {
		
		
		# $result = Execute-Pipeline -Verb "Read" -OperationType "Facet" -Name $Name -Model $null -Target $Target;
	};
	
	end {
		
	};
}