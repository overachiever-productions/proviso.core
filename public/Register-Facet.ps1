﻿Set-StrictMode -Version 1.0;

<#


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
		
		[Proviso.Core.IProperty[]]$runtimeProperties = @();
		if ($facet.Properties.Count -eq 0) {
			$anonymousProp = New-Object Proviso.Core.Models.AnonymousProperty(([Proviso.Core.PropertyParentType]"Facet"), $facet.Name);
			$runtimeProperties += $anonymousProp;
		}
		else {
			foreach ($prop in $facet.Properties) {
				if ($prop.IsCohort) {
					foreach ($nestedProp in $prop.Properties) {
						# TODO: I need to somehow know that this is a COHORT property ... as in, it belongs to a parent cohort, with ... details that can inherit/override 
						# 			and so that I can use the Enumerate, Add, Remove ... as needed.... 
						
						# arguably... i could create some sort of .ToCohortProperty() something here... and add that into the array of runtime properties.
						$runtimeProperties += $nestedProp;
						
						# GEDANKEN: 
						# assume I create a CohortProperty() out of this nestedProp... 
						# it would be: 
						# 	- copy of all relevant property details. 
						#   	- extract, compare, paths, impact, skip, throwOnConfig... 
						# 		- display
						# 		- parent... hmmm... parentType (yeah... cohort vs cohort's parent)
						# 	- it would need to find/define/register: 
						# 		- enumerate (script block) 
						# 				if this didn't exist as a block and we had a -Members(hip) arg... we could build one. 
						# 				if this didn't exist and there was a named Enumerator matching what was specified ... we'd load that 
						# 		- add / remove (script blocks)
					}
				}
				else {
					$runtimeProperties += $prop;
				}
			}
		}
		
		$facet.ClearProperties();
		foreach ($prop in $runtimeProperties) {
			$facet.AddProperty($prop);
		}
		
		
		foreach ($prop in $facet.Properties) {
#Write-Host "REGISTRATION STUFF FOR PROPERTY: [$($prop.Name)]"
			# GEDANKEN
			# 		IF $prop.IsCohortProp ... $parent = $prop.Cohort or whatever... 
			# 		ELSE $parent = $facet ... 
			# 			i.e., tackle some assignment operations here and ... go that route for inherit and override operations. 
			# 		 	likewise... i could simply add another layer of abstraction to something like: Do-InheritanceAndOverrides -Parent $cohortOrFacetOrWhatever -Child $prop
			# 				and IT would do all of the logic/calls below. 
			
			# INHERITANCE:
			Inherit -Parent $facet -Child $prop -Property "Expect";
			Inherit -Parent $facet -Child $prop -Property "Extract";
			Inherit -Parent $facet -Child $prop -Property "Display";
			Inherit -Parent $facet -Child $prop -Property "TargetPath";
			Inherit -Parent $facet -Child $prop -Property "ModelPath";
			
			# OVERRIDES:
			Override-Impact -Parent $facet -Child $prop;
			Override-Skip -Parent $facet -Child $prop;
			Override-ThrowOnConfig -Parent $facet -Child $prop;
		}
		
		Write-Debug "				Facet: [$Name] Passed Discovery. Adding to Catalog.";
		Add-FacetToCatalog $facet -Verbose:$xVerbose -Debug:$xDebug;
		
		return $facet;
	};
	
	end {
		
	};
}