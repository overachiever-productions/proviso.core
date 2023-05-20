Set-StrictMode -Version 1.0;

<#

	Import-Module -Name "D:\Dropbox\Repositories\proviso.core" -Force;

	$global:DebugPreference = "Continue";
	#$global:VerbosePreference = "Continue";


[string[]]$global:target = @("a","B", "Cee", "d", "e", "11");

	Facets {
		Facet "My First Facet" { 

			Property "Count" -DisplayFormat "hmmm" {
				Extract {
					return $global:target.Length;
				}
				Configure {
					throw "not supported - and this could/should be in a -param.";
				}
			}

			Cohort "Per Member" -DisplayFormat "should inherit 'down' to each child prop" -Expect $true {
				Enumerate {
					return $global:target;
				}
				Add {
					#$global:target += uhhhhh. ... guess there could/should be some sort of context data here? 
				}
				Remove {
					# yeah... remove what? 
				}

				# Inclusion goes here, right? 
				# 			might even make sense to call Inclusion something like Membership { } 


				Property "Is Upper Case" {
					Extract {
						# couple of ways to determin 'isUpperCase'. I don't REALLY care about that.
						# 	I care about ... iterating over $context.enumerator.Current or whatever... 
					}
				}

				Property "Is Vowel" {
					Extract {
						# return $context.whatever.current.EnumValue -in a,e,i,o,u (case insensitive)
					}
				}

				Property "Should be Skipped" -Skip {
					# add some code here... 
				}
			}

			Property "Contains 'Cee'" -Expect $true { 
				Extract {
					return $global:target -contains "Cee";
				}
			}

			Property "Has Numerics" -Expect $true {
				Extract {
					
				}
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
		# TODO: add option for $Id? 
		[Proviso.Core.Models.Facet]$facet = Get-FacetFromBlockStore -Name $Name -ParentName $ParentName;
		if ($null -eq $definition) {
			throw "Processing Error. Facet: [$Name] was NOT found.";
		}
		
		Write-Debug "			Facet Definition [$Name] located. Starting Discovery + Validation.";
		
		#region Implementation Notes:
		# NOTE: I presume that implementing the details listed below makes sense here (i.e., implement code here). 
		# 		but, eventually, code that loads FACETS will be loaded/executed for ... surfaces and such. 
		# 		so there's potentially a point to making the functionality below reusable?
		#endregion
		
		# DISCOVERY: 
		# 	Rules / Processes: 
		# 		- Each Facet MUST have at least 1 property. 
		# 			the property CAN be anonymous though... 
		
		# 		- NOTE: as I get to a point where I can/will? allow 'global' properties to be referenced. 
		# 			then, this is where those'd be added. 
		# 			i.e., process/logic would be something along the lines of: 
		# 			a) look for 'promises'/virtual property references. 
		# 					and ... then confirm that we can find them via the Catalog... 
		# 			b) similar-ish for Cohorts and their child properties. 
		# 					and ... validate their Enumerate|or and ADD/REMOVE + behavior/membership declarations. 
		# 					and ... then resolve any virtual/promise properties or whatever... 
		# 			c) explicitly defined properties... 
		# 			d) if we're at NO properties at this point... 
		# 				then ... create an ANONYMOUS property ... 
		
		if ($facet.Properties.Count -eq 0) {
			$anonymousProp = New-Object Proviso.Core.Models.AnonymousProperty($facet.Name, ([Proviso.Core.PropertyParentType]"Facet"));
			$facet.AddProperty($anonymousProp)
		}
		else {
			# might need to iterate props here and ... find cohorts and ...expand them on up/into the parent or??? 
			
			# i.e., I can do something like this without too much effort: 
			foreach ($p in $facet.Properties) {
				if ($p.IsCohort) {
					foreach ($pp in $p.Properties) {
						Write-Host "i'm a nested property.";
					}
				}
			}
			# only... 	all'z the above does is iterate over these ... i need a cohesive, bundled/weaponized, implementation. 
			
		}
		
		foreach ($prop in $facet.Properties) {
			
			
			
			# INHERITANCE:
			# 		?Display Format?, ?Compare/Comparison-Type?
			Inherit -Parent $facet -Child $prop -Property "Expect";
			Inherit -Parent $facet -Child $prop -Property "Extract";
			Inherit -Parent $facet -Child $prop -Property "TargetPath";
			Inherit -Parent $facet -Child $prop -Property "ModelPath";
			
			# OVERRIDES:
			Override-Impact -Parent $facet -Child $prop;
			Override-Skip -Parent $facet -Child $prop;
			Override-ThrowOnConfig -Parent $facet -Child $prop;
		}
		
		
		#     	- For EACH property in .Properties: 
		# 			MAP any of the following details owned/defined at the Facet Level:
		# 			> Target/Model Path - i.e., if not defined in the property, and IF defined by Facet, 'inherit down' to property (per each path option)
		# 			> Impact - i.e., Inherit if defined at facet and NOT defined at property (not that this'll be NONE/NONE by default at facet/prop level - but that's fine - we're looking for EXPLICIT declarations)
		# 			> Skip. If the Facet is skipped, all props will be skipped. 
		# 				at which point... do I even BOTHER with discovery? I THINK I do, cuz I'd want to see a 'skipped' facet with 4 props ... show up as 4 skips in validation/testing/etc. right?
		# 			> Display Format - again, inherit 'down' if/as needed. 
		# 			> EECC. 
		# 				not only do these 'inherit down' if/as needed. 
		# 				BUT... the values will be 'weaponized'
		# 				e.g., assume a Facet with 2x properties with -Expect 10 ... 
		# 					not only would this inherit down to it's 2x properties (so that their expects would be 10 (unless other values were explicitly specified)
		# 					 BUT, the actual EXPECT for those 2x properties would be, literally, something along the lines of { return $Expect; } - or whatever... 
		# 			> Configure - similar to the above ... 
		# 				if throwOnConfig or NoConfig is set at the FACET level... it overwrites all children. 
		
		
		#  	Reviewing the rules above, there are 2x behavior types: 
		# 		- Inherit-Down (i.e., syntactical sugar that allows for easier definition at the 'parent' level to trickle down to children IF they don't have values explicitly defined (otherwise, their explicit values 'trump' inheritance))
		# 		- OVERRIDE. Skip, Impact, and ThrowOnConfig are overrides. 	
		
		
		# Validation/Discovery Complete; Time to promote this to a registered Facet (i.e., shove it into the Catalog).
		Write-Debug "				Facet: [$Name] Passed Discovery. Adding to Catalog.";
		Add-FacetToCatalog $facet -Verbose:$xVerbose -Debug:$xDebug;
		
		return $facet;
	};
	
	end {
		
	};
}

function Get-Facet {
	[CmdletBinding()]
	param (
		# TODO: set up different paramter sets here... 
		[string]$Id,
		
		[Parameter(Mandatory)]
		[string]$Name,
		[string]$ParentName
	);
	
	process {
		[Proviso.Core.Models.Facet]$facet = Get-FacetFromCatalog -Id $Id -Name $Name -ParentName $ParentName -Verbose:$xVerbose -Debug:$xDebug;
		
		if ($null -eq $facet) {
			Write-Debug "		Facet: [$Name] not found in Catalog. Attempting to load definition (for registration).";
			
			[Proviso.Core.Models.Facet]$definition = $null;
			
	# TODO: -verbose -debug? 
	# TODO: ... what about .. by Id? (guess that would be another signature/call into Read-Facet - i.e., it'd pass down the Id ... and then ... I'd pass that around until here? )
	# 		and yeah... it probably makes sense to maybe implement some different signatures (in the block store) for that?
			$definition = Get-FacetFromBlockStore -Name $Name -ParentName $ParentName;
			if ($null -eq $definition) {
				throw "Processing Error. Facet: [$Name] was NOT found.";
			}
			
			Write-Debug "		Facet: [$Name] definition found. Attempting Registration.";
			
			$facet = Register-Facet -Name $Name -ParentName $ParentName -OverWrite:(Allow-DefinitionReplacement) -Verbose:$xVerbose -Debug:$xDebug;
		}
		
		return $facet;
	}
}