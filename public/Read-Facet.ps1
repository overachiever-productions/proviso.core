﻿Set-StrictMode -Version 1.0;

<#

	Import-Module -Name "D:\Dropbox\Repositories\proviso.core" -Force;

	#$global:DebugPreference = "Continue";
	#$global:VerbosePreference = "Continue";


[string[]]$global:target = @("a","B", "Cee", "d", "e", "11");

write-host "--------------------------------------------------"


	Facets {
		Facet "My First Facet" -TargetPath "Prop1" { 
			Property "Count" -DisplayFormat "hmmm" {
				Extract {
					return $global:target.Length;
				}
			}
			Property "Contains 'Cee'" -Expect $true { 
				Extract {
					return $global:target -contains "Cee";
				}
			}
			Property "Int Prop" -Expect 10 -Extract 99 {}
			Property "String Prop" -Expect "10" {}
			Property "Array Prop" -Expect @(10, "10") {}
			Property "IP Prop" -Expect 192.168.11.3 -Extract 11 {}
			#Cohort "Basic Cohort" -Expect 20  {
			#
			#}
		}
	}

#write-host "--------------------------------------------------"
	Read-Facet "My First Facet" -Target "Text 1";


#write-host "--------------------------------------------------"
	# re-load - it SHOULD already be in the catalog 
	Read-Facet "My First Facet" -Target "Text 2";


write-host "--------------------------------------------------"
	Read-Facet "This doesn't exist";


#>

<# 
write-host "--------------------------------------------------"

	Surface "Extended Events" {
		Setup { }
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
		Cleanup { }
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
	param (
		
# TODO: add in an option for Read-Facet via -Id... 		
		
		[Parameter(Mandatory, Position = 0, ParameterSetName = 'Default')]
		[Parameter(Mandatory, Position = 0, ParameterSetName = 'Targets')]
		[Parameter(Mandatory, Position = 0, ParameterSetName = 'Servers')]
		[Alias('FacetName')]
		[string]$Name,
		
		[Parameter(ParameterSetName = 'Default')]
		[Parameter(ParameterSetName = 'Targets')]
		[Parameter(ParameterSetName = 'Servers')]
		#[Alias('SurfaceName', 'AspectName')]
		[string]$ParentName,
		
		[Parameter(Mandatory, ValueFromPipeline, ParameterSetName = 'Targets')]
		[Parameter(ParameterSetName = 'Default')]
		[Parameter(ParameterSetName = 'Servers')]
		[Alias('Target')]
		[object[]]$Targets,
		
		
# TODO: add in a param (and ... param-set details) for $Model, right? 
# 		er, NO: if this were a Test or Invoke operation, then ... yup. 
# 			but not for a READ... 
		
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
		
		
# TODO: add in 2x display properties: 
# 		-Wrap: allows wrap of text in the 'outcome'/comments column (vs default which is equivlent of -NoWrap.)
# 		-NonMatchedOnly: which... a) needs a better name, and b) does NOT apply to READ-xxx. But, it's the idea that I could, somehow, emit a DIFFERENT result-type out the bottom of
# 			the Test-XXX or Invoke-XXX operation itself that'd be ... well, the exact same kind of object as the normal results object for those operations, but ... filtered to where it
# 			it only shows properties that ... were non-matched (either for Test... or for Invoke (second test/validate)
# 			and... truth is... i might not even need a secondary object-type or 'filtered' set of results in the same object type. in fact, i don't want that. 
# 			instead, I'd have $PvFormatter.WriteThisOrThatColumnIf($global:NonMatchedOrNot, $_)... 
# 		i mean... the above is way over-wrought... but it's, conceptually, what I'd want to tackle. i.e., ONLY write ENTIRE ROWS? if they're non-matched (assuming that this is even possible)
		
	);
	
	begin {
		[bool]$xVerbose = ("Continue" -eq $global:VerbosePreference) -or ($PSBoundParameters["Verbose"] -eq $true);
		[bool]$xDebug = ("Continue" -eq $global:DebugPreference) -or ($PSBoundParameters["Debug"] -eq $true);
		
		# CONTEXT: Get-Facet is a proxy method. If the Facet is already registered (discovered/validated, etc.) we'll get it back. 
		# 		If the facet isn't already registered, Get-Facet will attempt the registration process, then return the Facet (if everything worked).
		[Proviso.Core.Models.Facet]$facet = Get-Facet -Name $Name -ParentName $ParentName -Verbose:$xVerbose -Debug:$xDebug;
		
		if ($null -eq $facet) {
			throw "Processing Error. Facet: [$Name] NOT found.";
		}		
		
		$results = @();  # MUST be declared here to be able to be in scope for all pipeline'd operations... 
	};
	
	process {
		
		if (Has-ArrayValue $Servers) {
			foreach ($s in $Servers) {
				if (Has-ArrayValue $Targets) {
					foreach ($t in $Targets) {
						$results += Process-ReadFacet -Facet $facet -ServerName $s -Target $t -Credential $Credential -Verbose:$xVerbose -Debug:$xDebug;
					}
				}
				else {
					$results += Process-ReadFacet -Facet $facet -ServerName $s -Credential $Credential -Verbose:$xVerbose -Debug:$xDebug;
				}
			}
		}
		else {
			if (Has-ArrayValue $Targets) {
				foreach ($t in $Targets) {
					$results += Process-ReadFacet -Facet $facet -Target $t -Verbose:$xVerbose -Debug:$xDebug;
				}
			}
			else {
				$results += Process-ReadFacet -Facet $facet -Verbose:$xVerbose -Debug:$xDebug;
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
		$global:PvPipelineContext_CurentOperationName = "Read-Facet";  # TODO: turn this into an actual object...  ALTHOUGH... the pipeline can/will 'know' this via $Verb-$OperationType ... so, NOT needed.
		$result = Execute-Pipeline -Verb "Read" -OperationType Facet -Block $Facet -Target $Target -Verbose:$xVerbose -Debug:$xDebug;
	};
	
	end {
		return $result;
	};
}