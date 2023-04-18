Set-StrictMode -Version 1.0;

<#

	Import-Module -Name "D:\Dropbox\Repositories\proviso.core" -Force;

	$global:DebugPreference = "Continue";
	#$global:VerbosePreference = "Continue";


	Facets {
		Facet "My First Facet" { 

			Cohort "Named" {
				# some code.
				Enumerate {

				}
				Add {

				}
				Remove {

				}

				Property "Cohort Property A" {
				}
				Property "Cohort Property B" {
				}
			}

			Property "Facet Property 1" { 
			}
			Property "Facet Property 2" {
			}
		}
	}

write-host "--------------------------------------------------"

	Read-Facet "My First Facet";



#>

function Register-Facet {
	[CmdletBinding()]
	param (
		[Parameter(Mandatory)]
		[string]$Name,
		[string]$ParentName,
		[switch]$OverWrite = $false		# synonyms or better names might be: $Replace, $Force? etc... 
	);
	
	begin {
		[bool]$xVerbose = ("Continue" -eq $global:VerbosePreference) -or ($PSBoundParameters["Verbose"] -eq $true);
		[bool]$xDebug = ("Continue" -eq $global:DebugPreference) -or ($PSBoundParameters["Debug"] -eq $true);
	};
	
	process {
		# Bit of a DRY violation as this is a copy/paste of the same lines from Get-Facet:
		[Proviso.Core.Definitions.FacetDefinition]$definition = $null;
		$definition = $global:PvOrthography.GetFacetDefinitionByName($Name, $ParentName);
		if ($null -eq $definition) {
			throw "Processing Error. Pattern or Facet: [$Name] was NOT found.";
		}
		
		Write-Debug "Facet Definition [$Name] located. Starting Discovery + Validation.";
		
		# TODO: this should be via $definition.ToFacet() or whatever... (as in, do mapping of properties and such within C# vs manually re-mapping in here... )
		[Proviso.Core.Models.Facet]$facet = New-Object Proviso.Core.Models.Facet($definition.Name, $definition.Id, $definition.FacetType);
		
		# Validate: 
		$facet.Validate($global:PvCatalog); # this could work... 
		
		
		
		# what does registration even mean? 
		# 	it's validation, basically. or ... confirmation that the build(ed) definition is legit. 
		# 	yeah, ultimately, it's a kind of 'compilation' - taking expressed intentions and turning them into a portable object/thingy... 
		
		# for a facet that means: 
		# 		1. does the facet have a parent? I don't think that really matters. as in, facets can be stand-alone(ish) - they either have to exist in a surface/aspect or ... facets block. 
		# 		2. is this a facet or a pattern? 
		# 		3. do we have at least 1 property/cohort? 
		# 		4. if we're a pattern, do we have an iterate/iterator-specified (and if the iterator is specified, can we find it?)
		# 		5. If there's a cohort... 
		# 			> does it have an emuerate or enumerator specified (and if enumerator - can we find one?)
		# 			> does the cohort have at least 1 property?
		# 		6. what else?
		
		# 		assuming that all of the above passes... 
		# 			congrats, we've got a facet/pattern?
		# 			store it (along with enumerate/iterate 'pointers'?)
		# 				er. no. no pointers. the actual code. 
		# 				and, insanely enough: caching/build/whatever dependencies on these enumerators/iterators
		# 					cuz if they end up being updated/replaced, I need to either update facets and such that depend on them, or dump them from the cache etc. 
		# 		So. Yeah. 
		# 			when i'm done here, what I'll have is a fully weaponized bit of code that has everything it needs to process 
		# 				e.g., it'll have all paths, all directives, and so on fully populated. 
		# 				it'll also have the code-blocks for Iterate/Add/Remove and Enumerate/Add/Remove 'copied into place' as needed. 
		# 			and ... 
		# 				for each property (or cohort-property/etc.) or inclusion and whatever... 
		# 			it'll have the code-blocks for EECC and EVERYTHING needed for execution. 
		
		
	};
	
	end {
		
	};
}

function Get-Facet {
	[CmdletBinding()]
	param (
		[Parameter(Mandatory)]
		[string]$Name,
		[string]$ParentName
	);
	
	process {
		Write-Debug "Attempting to get Facet: [$Name] from Catalog.";
		[Proviso.Core.Models.Facet]$facet = $global:PvCatalog.GetFacetByName($Name, $ParentName);
		
		if ($null -eq $facet) {
			Write-Debug "Facet: [$Name] not found in Catalog. Attempting to load definition (for registration).";
			
			[Proviso.Core.Definitions.FacetDefinition]$definition = $null;
			$definition = $global:PvOrthography.GetFacetDefinitionByName($Name, $ParentName);
			if ($null -eq $definition) {
				throw "Processing Error. Pattern or Facet: [$Name] was NOT found.";
			}
			
			Write-Debug "Facet: [$Name] definition found. Attempting Registration.";
			
			$facet = Register-Facet -Name $Name -ParentName $ParentName -OverWrite:(Allow-DefinitionReplacement) -Verbose:$xVerbose -Debug:$xDebug;
		}
		
	}
}