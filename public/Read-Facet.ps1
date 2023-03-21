Set-StrictMode -Version 1.0;

<#

	Import-Module -Name "D:\Dropbox\Repositories\proviso.core" -Force;

	$global:DebugPreference = "Continue";
	#$global:VerbosePreference = "Continue";

#	Facets {
#		Facet "My First Facet" { }
#	}
#
#	#Read-Facet "My First Facet";

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

	Read-Facet "ANOTHER My First Facet" { } 
	

write-host "--------------------------------------------------"

	$facets = @(
		[PSCustomObject]@{ Name = "My First Facet" }
		[PSCustomObject]@{ Name = "ANOTHER My First Facet" }
		[PSCustomObject]@{ Name = "My Second Facet" }
		[PSCustomObject]@{ Name = "My first Pattern" }
	)

	$facets | Read-Facet;

write-host "--------------------------------------------------"



#>


function Read-Facet {
	[CmdletBinding()]
	[Alias("Read-Pattern")]
	param (
		#[ValidateNotNullOrEmpty()]
		[Parameter(ValueFromPipelineByPropertyName)]
		[Alias("FacetName", "PatternName")]
		[string]$Name,
		[string]$ParentName = $null,
		[Alias("Targets")]
		[object]$Target = $null,
		[object]$Extract = $null,
		[string]$Servers = $null,
		[switch]$AsPSON = $false
	);
	
	begin {
		
		# TODO: address $Targets (array)
		# 		So, in terms of -Target(s) being an array:
		# 				what if I want to actually 'target' a single array of values - to tackle my READ operation. i.e., MAYBE -Extract is simply $Target.Count ??? right?
		# 				how can i tell the difference between the above, and, say... a scenario where I want to get $Target.Length() - but I want to do it against MULTIPLE targets?
		# 					I don't think i CAN actually differentiate between the two. 
		# 				the ONLY thing I can think of would be something like -Target and -[Multiple]Targets
		
		# TODO: address -Servers. # See PowerShell in Action - 3rd Edition - Chapter/Section 20.5 - on remote runspaces. Great stuff in there. 
		
	};
	
	process {
		# Validate Operation:
		[Proviso.Core.Definitions.FacetDefinition]$facet = $null;
		try {
			$facet = $global:PvCatalog.GetFacetDefinitionByName($Name, $ParentName);
		}
		catch {
			throw "$($_.Exception.Message) `r`t$($_.ScriptStackTrace) ";
		}
		
		if ($null -eq $facet) {
			throw "Error. No Facet or Pattern with the name [$Name] was found.";
		}
		
		# TODO: Make sure to proxy for -Target_S_ and -Servers... 
		
		# NOTE: No -Config or -Models for this operation:
		$result = Execute-Pipeline -Verb "Read" -OperationType "Facet" -Name $Name -Model $null -Target $Target;
	};
	
	end {
		
	};
}