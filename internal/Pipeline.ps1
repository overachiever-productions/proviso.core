Set-StrictMode -Version 1.0;

# REFACTOR:
# 		I've got a number of 'helper' functions below that 'think' at the property level - meaning that in each helper method
# 		they effectively do: foreach(Surface) -> foreach(Facet) -> foreach(Prop/nested prop...)
# 			over and over again. which...meh... who cares about the perf overhead of doing things over and over again. 
# 		what'd be COOLER/BETTER though would be: 
# 		before running all of these ... do a SINGLE call to something like $orderedPropertiesForCurrentPipelineProcessingRun = Expand-OrSerialize-Props $runbook (or whatever)
# 			to get these into a 'stream' of props... then ... process them (via the helper funcs) as needed instead of violating DRY and ... foreach-foreach-foreach-ing over and over again.

function Execute-Pipeline {
	[CmdletBinding()]
	param (
		[ValidateSet("Read", "Test", "Invoke")]
		[Parameter(Mandatory)]
		[string]$Verb,
		
		[ValidateSet("Facet", "Pattern", "Surface", "Runbook")]
		[string]$OperationType,
		
		[parameter(Mandatory)]
		[Object]$Block,
		
		[object]$Model,
		
		[object]$Config,  # just a (highly) specialized (kind of) model... 
		
		[object]$Target
	);
	
	begin {
		[bool]$xVerbose = ("Continue" -eq $global:VerbosePreference) -or ($PSBoundParameters["Verbose"] -eq $true);
		[bool]$xDebug = ("Continue" -eq $global:DebugPreference) -or ($PSBoundParameters["Debug"] -eq $true);
		
		Reset-PipelineDebugIndents;
		
		Write-Debug "$(Get-PipelineDebugIndent -Key "Root")Starting Pipeline Operations.";
		Write-Verbose "Starting Pipeline Operations.";
		
		[bool]$isRunbook = $false;
	}
	
	process {
		# ====================================================================================================
		# 1. Setup
		# ====================================================================================================		
		#region Setup
		$results = Initialize-ResultsObject -Verb $Verb -OperationType $OperationType -Block $Block -Verbose:$xVerbose -Debug:$xDebug;
		
		[Proviso.Core.ISurface[]]$surfaces = @();
		
		try {
			switch ($OperationType) {
				{ $_ -in @("Facet", "Pattern") } {
					$fakeSurface = New-Object Proviso.Core.Models.PlaceHolderSurface;
					$fakeSurface.AddFacet($Block);
					$surfaces += $fakeSurface;
				}
				"Surface" {
					$surfaces += $Block;
				}
				"Runbook" {
					$isRunbook = $true;
					$currentRunbook = $Block;
					
					foreach ($implement in $Block.Implements) {
						$surfaces += $implement;
					}
				}
			}
		}
		catch {
			Write-Debug "$(Get-PipelineDebugIndent -Key "SetupException")Processing Pipeline: Exception During Setup: $($_.Exception.Message) -Stack: $($_.ScriptStackTrace)";
			# TODO: implement this throw... stuff
			throw "Processing Setup Exception: $_";
		}
		Write-Debug "$(Get-PipelineDebugIndent -Key "SetupDone")Pipeline Setup Operations Complete.";
		
		#endregion
		
		# ====================================================================================================
		# 2. Runtime Validation 
		# ====================================================================================================
		#region Validation 
		Write-Debug "$(Get-PipelineDebugIndent -Key "Validation")Starting Pipeline Validations.";
		
		Validate-PipelinePatterns;
		Validate-PipelineCollections;
		Validate-PropertyDisplayTokens;
		
		TrySet-TargetAsImplicitExtractForNonExplicitExtractProperties -Surfaces $surfaces -Target $Target -Verbose:$xVerbose -Debug:$xDebug;
		
		if ($Verb -in ("Test", "Invoke")) {
			# TODO: address how model vs config stuff works ... i.e., this is starting to be where I have to draw the line between the two. 
			# 		are they same things? just slightly different with slightly different names? or ... are they entirely different things? 
			# 			either way, the func below should handle the complexity... (i.e., I might need to pass in -Config $Config here as well? )
			TrySet-ModelAsImplicitExpectForNonExplicitExpectProperties -Surfaces $surfaces -Model $Model -Verbose:$xVerbose -Debug:$xDebug;
		}
		
		if ("Invoke" -eq $Verb) {
			# Couple of Tasks Here:
			# 1. Make sure we've got a Configure for each Property. 
			# 		or, that if -UsesAdd or whatever is set ... that we've got what we need in that dept. 
			# 2. Validate -Impact of each property ... vs -PipelineAllowedImpact (or whatever) I'm going to call that. 
			# 		obviously, if an impact for a single property is 'greater than' what the user has specified/allowed... we'll have to throw here. 
		}
		
		Write-Debug "$(Get-PipelineDebugIndent -Key "Validation")Pipeline Validations Complete.";
		#endregion
		
		# ====================================================================================================
		# 3. Processing (i.e., actual pipeline)
		# ====================================================================================================		
		#region Processing 
		Write-Debug "$(Get-PipelineDebugIndent -Key "Processing")Starting Pipeline Processing.";
		try {
			if ($isRunbook) {
				# A. 
				# if there's a .Setup { } block (and... if it's applicable???)
				# then... do $runbook.Setup();
				# TODO:
				#$resultsObject.AddRunbookSetupOutcome(exceptionOrNot, that's about it, right?);
				
				# B. 
				# if there are any asserts AND if they're applicable... 
				# 	run applicable RUNBOOK asserts.
				# 	i.e., for EACH assert ... 
				# 		process 
				# TODO:
				# 	and $resultsObject.AddRunbookAssertOutcome()

			}
			
			foreach ($surface in $surfaces) {
				
				if (-not ($surface.IsPlaceHolder)) {
					Write-Debug "		Processing Surface: [$($surface.Name)].";
				}
				
				if ($surface.Setup) {
					# or... do we need to check for the verb types? 
					# do setup... 
					
					# TODO: handle $resultsObject.AddSurfaceSetupOutcome();
				}
				
				if ($surface.HasActiveAssertions) {
					# i.e., if any assertions exist, are not disabled, and ... apply to the verb??? we're running... 
					# 		then... do each assertion. 
					
					# TODO: foreach... 
					# 	TODO: $resultsObject.AddSurfaceAssertOutcome()
				}
				
				foreach ($facet in $surface.Facets) {
					if ($facet.IsPattern) {
						Write-Debug "$(Get-PipelineDebugIndent -Key "Instances")Iterating Pattern Instances.";
						
						# REFACTOR: Recursion might be a better way to do the following (only, I worry it MIGHT become untenable).
						switch ($facet.Instances.Count) {
							0 {
								throw "some kind of weird validation problem - should've detected this before now... "
							}
							1 {
								$members = Get-PatternIterationMembers -Pattern $facet -Verb $Verb;
								foreach ($m in $members) {
									Set-PvContext_InstanceData -InstanceName ($facet.Instances[0].Name) -Members $m -CurrentMember $members -DefaultInstanceName ($facet.Instances[0].DefaultInstanceName);
									
									Iterate-FacetProperties -FacetOrPattern $facet;
								}
							}
							2 {
								$parents = Get-PatternIterationMembers -Pattern $facet -Verb $Verb;
								$parentInstancesName = $facet.Instances[0].Name;
								$parentInstancesDefaultInstanceName = $facet.Instances[0].DefaultInstanceName;
								foreach ($parent in $parents) {
									Set-PvContext_InstanceData -InstanceName $parentInstancesName -Members $parents -CurrentMember $parent -DefaultInstanceName $parentInstancesDefaultInstanceName;
									
									$children = Get-PatternIterationMembers -Pattern $facet -Depth 1 -Verb $Verb;
									$childrenInstancesName = $facet.Instances[1].Name;
									$childrenInstancesDefaultInstanceName = $facet.Instances[1].DefaultInstanceName;
									foreach ($child in $children) {
										Set-PvContext_InstanceData -InstanceName $childrenInstancesName -Members $children -CurrentMember $child -DefaultInstanceName $childrenInstancesDefaultInstanceName;
										
										Iterate-FacetProperties -FacetOrPattern $facet;
									}
								}
							}
							3 {
								# TODO: implement as above - but with ... grand-children (sheesh)
								throw "Iteration of Instances for Patterns with 3x (or more?) Instance-Blocks hasn't been completed yet.";
							}
							default {
								throw "only 3x leves supported for now."; # and... honestly, > 3x starts getting pretty complex, no?
							}
						}
						
						Write-Debug "$(Get-PipelineDebugIndent -Key "Instances")Instance Iteration Complete.";
					}
					else {
						Iterate-FacetProperties -FacetOrPattern $facet;
					}
				}
				
				if ($surface.Cleanup) {
					# if defined and applicable... 
					# do Cleanup()... 
				}
			}
			
			if ($isRunbook) {
				# if there's a .Cleanup {} (and if it's applicable?) 
				# 	then... do $runbook.Cleanup();
			}
		}
		catch {
			throw "Error in ... Pipeline Processing (step 3): $_.`t$($_.ScriptStackTrace) ";
		}
		Write-Debug "$(Get-PipelineDebugIndent -Key "Processing")Pipeline Processing Complete.";
		#endregion
		
		# ====================================================================================================
		# 4. Post-Processing
		# ====================================================================================================		
		$results.PipelineEnd = [datetime]::Now;
		
		# TODO: add $results into a list/collection of 'past' pipeline operations. 
		# 		i.e., we'll always RETURN $results ... meaning they'll be 'intercepted' by Posh and 'rendered' for output via custom XML formats... 
		# 			but, users might also want to 'look at' the 'last'/previous executions etc... 
	}
	
	end {
		Write-Debug "$(Get-PipelineDebugIndent -Key "Root")Pipeline Operations Complete.";
		Write-Verbose "Pipeline Operations Complete.";
		
		# TODO: if there was an unhandled exception or full-blown problem... DON'T return results?
		# 		or ... do, but load it with exception info? e.g., this is EASY to TEST (just throw somewhere early in the pipeline (in the Process block) - or ... put a RETURN in the process block somewhere... 
		return $results;
	}
}

function Initialize-ResultsObject {
	[CmdletBinding()]
	param (
		[string]$Verb,
		[string]$OperationType,
		[Proviso.Core.IDeclarable]$Block
	);
	
	# TODO: i could use a switch here ... with ... 9 friggin levels of stuff... 
	# 		or... might make more sense to figure out how 'dynamically' create a new Proviso.Core.$OperationType$VerbResult... and spit that out? 
	# 		i mean, worst case, i create a SCRIPTBLOCK of "return New-Object Proviso.Core.$($OperationType)$($Verb)Result($name, $format).."; 
	# 			cuz... that's 3-4 lines of code, max ... vs 9x switch/case options... 
	
	$name = $Block.Name;
	$display = $Block.Display;
	
	return New-Object Proviso.Core.FacetReadResult($name, $display);
}

function Get-PatternIterationMembers {
	[CmdletBinding()]
	param (
		[Proviso.Core.Models.Facet]$Pattern,
		[int]$Depth = 0,
		[string]$Verb
	);
	
	$iteratorBlock = $Pattern.Instances[$Depth].Enumerate;
	if ("Read" -eq $Verb) {
		$iteratorBlock = $Pattern.Instances[$Depth].List;
	}
	
	try {
		$iteratorMembers = & $iteratorBlock;
	}
	catch {
		throw "Exception attempting to iterate over <iterator-name-here>. Exception: $_ ";
	}
	
	if ($iteratorMembers.Count -le 1) {
		Write-Host "need to look for a default instance name here... and throw if REQUIRED but ..  be DONE if there's nothing... "
	}
	
	return $iteratorMembers;
}

function Iterate-FacetProperties {
	[CmdletBinding()]
	param (
		[Proviso.Core.Models.Facet]$FacetOrPattern   # facetOrPattern... 
	);
	
	begin {
		# setup facet-level context info/details... 
		# e.g., $global:PvContext.Facet.xxxx props and such. 
		# and clear any $PVContext.get/setFacet-LevelStorage/State stuff as well. 		
	};
	
	process {
		Write-Debug "$(Get-PipelineDebugIndent -Key "Properties")Iterating Properties...";
		foreach ($property in $FacetOrPattern.Properties) {
			if ($property.IsCollection) {
				Write-Debug "			Processing Collection.";
				
				$enumerator = $property.Membership.Enumerate;
				if ("Read" -eq $Verb) {
					$enumerator = $property.Membership.List;
				}
				
				try {
					Write-Debug "				Enumerating Collection Members.";
					$enumeratorValues = & $enumerator;
					Write-Debug "				  Enumeration of Collection Members Complete. Found $($enumeratorValues.Count) members.";
				}
				catch {
					Write-Host "I need better error handling... but, this is a failure that happened in ... getting List{} results from Membership: $_ ";
				}
				
				if ($enumeratorValues.Count -le 1) {
					throw "List failed... didn't get 1 or more results..";
				}
				
				foreach ($currentValue in $enumeratorValues) {
					Write-Debug "					Setting Context Data for Current Collection Member/Members.";
					Set-PvContext_CollectionData -Name ($property.Name) -Membership ($property.Membership) -Members $enumeratorValues -CurrentMember $currentValue;
					
					foreach ($nestedProperty in $property.Properties) {
						
						# TODO: look at moving this INTO `Process-Property` ... as in, i should be able to tell, inside that func, IF we're dealing with a CollectionProp or not. 
						# 		i could, obviously, just check for $PVContext.Collection exists or ... not... OR, I could also, potentially, throw in ... an -IsCollectionProp switch or 
						# 			whatever that'd be set in this path/fork/if to $true and to $false in the else? 
						# 		the other thing I need to address is ... that I'll want/have-to? do something similar for iterator details too, right?
						if (-not $nestedProperty.Display) {
							$defaultEnumeratedPropertyDisplay = "$($nestedProperty.Name)::$($currentValue)"; # vNEXT: use equivalent of string.format ... (i.e., "{0}{1}") and allow a GLOBAL preference here for something like $PvPreferences.DefaultCollectionPropertiesFormatThingy = "{0}.{1}" ... or whatever. 
							$nestedProperty.SetDisplay($defaultEnumeratedPropertyDisplay);
						}
						
						Process-Property -Verb $Verb -Property $nestedProperty -Results $results `
										 -Model $Model -Config $Config -Target $Target -Verbose:$xVerbose -Debug:$xDebug;
					}
					
					Remove-PvContext_CollectionData;
				}
			}
			else {
				Process-Property -Verb $Verb -Property $property -Results $results `
								 -Model $Model -Config $Config -Target $Target -Verbose:$xVerbose -Debug:$xDebug;
			}
		}
		Write-Debug "$(Get-PipelineDebugIndent -Key "Properties")Property Iteration Complete.";		
	};
	
	end {
		# clear ... facet-level context stuff? 
	}
}

function Process-Property {
	[CmdletBinding()]
	param (
		[ValidateSet("Read", "Test", "Invoke")]
		[Parameter(Mandatory)]
		[string]$Verb,
		
		# TODO: might need to end up making this an IProperty (to account for Inclusion|Property (but never cohort/etc.))
		[Parameter(Mandatory)]
		[Proviso.Core.IProperty]$Property,
		
		$Results,
		
		[Object]$Model,
		
		[Object]$Config,
		
		[Object]$Target
	);
	
	begin {
		Set-PvContext_PropertyData -PropertyName ($Property.Name) -ParentName ($Property.ParentName);
	}
	
	process {
		try {
			$block = $Property.Extract;
			[Object]$output = & $block;
			
			if ($null -eq $output) {
				[Proviso.Core.ExtractResult]$extract = [Proviso.Core.ExtractResult]::NullResult();
			}
			else {
				[Proviso.Core.ExtractResult]$extract = [Proviso.Core.ExtractResult]::SuccessfulExtractResult(($output.GetType().FullName), $output);
			}
		}
		catch {
			[Proviso.Core.ExtractResult]$extract = [Proviso.Core.ExtractResult]::FailedExtractResult($_);
		}
		
		# TODO: bind $output from above as $PVContext.Current.Property.ExtractValue or whatever... 
		
		[string]$tokenizedDisplay = Process-DisplayTokenReplacements -Display ($Property.Display) -Name ($Property.Name);
		
		[Proviso.Core.PropertyReadResult]$read = New-Object Proviso.Core.PropertyReadResult(($Property.Name), $tokenizedDisplay, $extract);
		$Results.PropertyReadResults.Add($read);
		# TODO: if $Results is ... SurfaceXXX (vs FacetXXX) ... add $read to list of SURFACE-level $Props... 
		# TODO: if $Results is ... RunbookXXX (vs FacetXXX) ... ad $read to list of RUNBOOK-level $props... 
		
		if ($Verb -in ("Test", "Invoke")) {
			# do compare stuff. 
			# 	 specifically: 
			# 		1. get Extract (or current/actual value)
			# 		2. get Expect (the value we just got above ... and which should be in $PvContext.PRoperty.Current or whatever... )
			# 		3. use the current property's .Compare block/func to determine if Extract(ed) and Expect(ed) are the same or not... 
			# 		4. bundle-up/keep the results (along with any exceptions along the way)
		}
		
		if ("Invoke" -eq $Verb) {
			# if the outcome of Test is not an exception (or even if it is?) and if the outcome of Test is ... NOT SAME... 
			# then: 
			# 		1. invoke current prop's .Configure{} block (in a try-catch)
			# 		2. re-run extract
			# 		3. re-compare against expect(ed)
			# 		4. report on outcome/results/etc. 
		}
	}
	
	end {
		Remove-PvContext_PropertyData;
	}
}

function Validate-PipelinePatterns {
	# foreach pattern... in the 'pipeline/chain'
	# 	1. make sure there's at LEAST 1x Iterator. 
	#	2. Then, for each Iterator: 
	# 		a. make sure we have the at least `List{}` and... `Enumerate{}` DEPENDING upon the verb. 
	# 		b. based on strict/naive... is there anything else to address? 
}

function Validate-PipelineCollections {
	# foreach collection in the pipeline:
	# 	1. make sure that there is 1x (only) Membership. 
	#   2. for the membership: 
	# 		a. make sure we have a `List{}` - and, based on $Verb, an `Enumerate{}` 
	# 		b. anything else to do based on strict vs naive?
	
}

function Validate-PropertyDisplayTokens {
	foreach ($surface in $Surfaces) {
		foreach ($facet in $surface.Facets) {
			[bool]$isPattern = $false;
			if ($facet.IsPattern) {
				$isPattern = $true;
			}
			
			foreach ($prop in $facet.Properties) {
				if ($prop.IsCollection) {
					foreach ($nestedProp in $prop.Properties) {
						Validate-DisplayTokenUse -Display $nestedProp.Display -IsCollection -IsInstance:$isPattern;
					}
				}
				else {
					Validate-DisplayTokenUse -Display $prop.Display -IsInstance:$isPattern;
				}
			}
		}
	}
}

function TrySet-TargetAsImplicitExtractForNonExplicitExtractProperties {
	[CmdletBinding()]
	param (
		[Parameter(Mandatory)]
		[Proviso.Core.ISurface[]]$Surfaces,
		[Object]$Target
	);
	
	foreach ($surface in $Surfaces) {
		foreach ($facet in $surface.Facets) {
			foreach ($prop in $facet.Properties) {
				if ($prop.IsCollection) {
					foreach ($nestedProp in $prop.Properties) {
						if (-not ($nestedProp.Extract)) {
							if (Is-Empty $Target) {
								throw "`nRuntime Validation Failure: `n  - Cohort Property [$($nestedProp.Name)] does NOT have an explicit - Extract, Extract{}, or -Path defined. `n  -Either Implement Extract or specify -Target for $($global:PvPipelineContext_CurentOperationName). ";
							}
							
							$nestedProp.Extract = Get-RuntimeGeneratedExtractProxy $Target -Path ($nestedProp.TargetPath) -Verbose:$xVerbose -Debug:$xDebug;
						}
					}
				}
				else {
					if (-not ($prop.Extract)) {
						if (Is-Empty $Target) {
							throw "`nRuntime Validation Failure: `n  - Property [$($prop.Name)] does NOT have an explicit -Extract, Extract{}, or -Path defined. `n  - Either Implement Extract or specify -Target for $($global:PvPipelineContext_CurentOperationName). ";
						}
						
						$prop.Extract = Get-RuntimeGeneratedExtractProxy $Target -Path ($prop.TargetPath) -Verbose:$xVerbose -Debug:$xDebug;
					}
				}
			}
		}
	}
}

function TrySet-ModelAsImplicitExpectForNonExplicitExpectProperties {
	[CmdletBinding()]
	param (
		[Parameter(Mandatory)]
		[Proviso.Core.ISurface[]]$Surfaces,
		[Object]$Model,
		[Object]$Config   # TODO: figure out how to handle this - is it something I pass in INSTEAD of the $Model or ??? what? 
	);
	
	foreach ($surface in $Surfaces) {
		foreach ($facet in $surface.Facets) {
			foreach ($prop in $facet.Properties) {
				if ($prop.IsCohort) {
					foreach ($nestedProp in $prop.Properties) {
						if (-not ($nestedProp.Extract)) {
							if (Is-Empty $Model) {
								throw "`nRuntime Validation Failure: `n  - Cohort Property [$($nestedProp.Name)] does NOT have an explicit -Expect, Expect{}, or -Path defined. `n  - Either Implement Expect or specify -Model for $($global:PvPipelineContext_CurentOperationName). ";
							}
							
							$nestedProp.Extract = Get-RuntimeGeneratedExpectProxy $Model -Path ($nestedProp.ModelPath) -Config $Config -Verbose:$xVerbose -Debug:$xDebug;
						}
					}
				}
				else {
					if (-not ($prop.Extract)) {
						if (Is-Empty $Model) {
							# TODO: uhhh... what about ... if the property in question has a -ModdelPath ... then this should be generating something like "return $Model.<modelPath>"..
							throw "`nRuntime Validation Failure: `n  - Property [$($prop.Name)] does NOT have an explicit -Expect, Expect{}, or -Path defined. `n  - Either Implement Expect or specify -Model for $($global:PvPipelineContext_CurentOperationName). ";
						}
						
						$prop.Extract = Get-RuntimeGeneratedExpectProxy $Model -Path ($prop.ModelPath) -Config $Config -Verbose:$xVerbose -Debug:$xDebug;
					}
				}
			}
		}
	}
}

function Get-RuntimeGeneratedExtractProxy {
	[CmdletBinding()]
	param (
		[Parameter(Mandatory, Position = 0)]
		[Object]$Target,
		[string]$Path
	);
	
	if (Has-Value $Path) {
		$value = Extract-ValueFromObjectByPath -Object $Target -Path $Path;
		
		if ($null -eq $value) {
			# TODO: allow different path separators ... (i.e., the call into Object-SupportsPropertyAtPath is hard-coded for . as the path separator... )
			if (Object-SupportsPropertyAtPathLevel $Target -Path $Path) {
				return Get-ReturnScript $null; # can't merely return $null, have to return a SCRIPT that'll ... return $null;
			}
			
			# TODO: figure out how to hand in {operationNameHere} - e.g., "Read-Facet" or "Test-Surface".FacetName??? 
			throw "Explicitly Supplied -Target for [{operationNameHere}] does not have a property that matches the path: [$Path].";
		}
		
		return Get-ReturnScript $value;
	}
	else {
		return Get-ReturnScript $Target;
	}
}

function Get-RuntimeGeneratedExpectProxy {
	[CmdletBinding()]
	param (
		[Parameter(Mandatory, Position = 0)]
		[Object]$Model,
		[string]$Path,
		[Object]$Config  
	);
	
	# TODO: not sure if -Model AND -Config are used together, or if -Config will be used instead of -Model ... and so on... 
	#  		i.e., have to figure this out ... 
	
	
	throw "Not Implemented yet.";
	
	# TODO: virtually the same as Get-RuntimeGeneratedExtractProxy ... 
	# 	EXCEPT: 
	# 		1. There's an option for if/when the value expected is $null to look for a default / etc. 
	# 		2. There's also the option to handle/process {TOKEN} results as well... e.g., {PARENT} or {DEFAULT_PATH} or whatever makes sense and so on... 
	
}

filter Get-ReturnScript {
	param (
		[Object]$Output
	);
	
	# NOTE: This is a fairly naive implementation - probably needs some additional complexity/options to better handle outputs. 
	
	# TODO: This MIGHT be a much better option: 
	# 	https://github.com/iRon7/ConvertTo-Expression 
	
	if ($null -eq $Output) {
		$script = "return `$null; ";
	}
	else {
		switch ($Output.GetType().FullName) {
			"System.String" {
				$script = "return `"$Output`";";
			}
			"System.Object[]" {
				# TODO: this is a REALLY naive implementation and ... it's also casting @(10, "10") to @(10, 10) (as near as I can tell... )
				$data = $Output -join ",";
				$script = "return @(" + $data + "); ";
			}
			default {
				$script = "return $Output;";
			}
		}
	}
	return [ScriptBlock]::Create($script).GetNewClosure();
}

function Reset-PipelineDebugIndents {
	$script:pipelineIndentManager = New-Object Collections.Generic.List[String];
}

function Get-PipelineDebugIndent {
	param (
		[string]$Key
	);
	
	$Key = $Key.ToLower();
	
	[string]$pad = "";
	[int]$count = 0;
	if ($script:pipelineIndentManager.Contains($Key)) {
		[int]$count = $script:pipelineIndentManager.Count;
		$pad = " ";
		$script:pipelineIndentManager.Remove($Key) | Out-Null;
	}
	else {
		$script:pipelineIndentManager.Add($Key) | Out-Null;
		[int]$count = $script:pipelineIndentManager.Count;
	}
	
	return "$("`t" * ($count - 1))$pad";
}

#Reset-PipelineDebugIndents;
#
#Write-Host "Anchor";
#Write-Host "$(Get-PipelineDebugIndent -Key "Tier1")Start Tier 1";
#Write-Host "$(Get-PipelineDebugIndent -Key "Tier2")Start Tier 2";
#
#
#Write-Host "$(Get-PipelineDebugIndent -Key "TiEr2")End Tier 2";
#Write-Host "$(Get-PipelineDebugIndent -Key "TiEr1")End Tier 1";

# ------------------------------------------------------------------------------------

# OLD/NUKE...  (after reviewing the big block of comments in the 'start' of the logic of this func....)

<#
filter Get-RunTimeGeneratedReturnScript {
	param (
		[Parameter(Mandatory, Position = 0)]
		[Object]$Object,
		[string]$Path,
		[string]$PathType
	);
	
	
					$expect = $facet.Expect;
					$script = "return $expect;";
					
					# NOTE: I was hoping/thinking that whatever I did via the above would let $expect be ... whatever $expect is/was - i.e., let CLR handle the type-safety and just 'forward it on'
					# 	and such. 
					# 		that won't be the case - i.e., in the code above, what if $facet.Expect = "I'm a teapot, short and stout."?
					# 			if it is... the code above will not 'compile' via Script::CREATE() below. 
					# 		so... i'm stuck with then trying to figure out if $expect is a string or not... and wrapping accordingly. 
					
					# there's ANOTHER option. 
					# 	and it's borderline insane. But, then again, maybe ... not. 
					# Assume a $global:PvDictionary<Guid, object>. 
					# 	 at which point, I could do something like: 
					$key = Add-DicoValue($facet.Expect); # which spits back a GUID... 
					$script = "return $($global:PvDictionary.GetValueByKey($key)); ";
					#  	and... bob's your uncle ...as in, the dico returns 10, "10", 'x', "I'm a teapot, short and stout..";
					# 	etc... 
					
					# other than the SEEMING insanity of the above... I can't really think of any reason it... wouldn't work. 
					#  	er, well... if I add, say, a string into a dictionary<guid, object> ... and fetch it ... 
					# 			i don't think I get a string back, i get an object (that can, correctly, be cast to a string). 
					# 	SO. 
					# 		another option would be: 
					# 		get the TYPE of the object here... 
					# 			and... handle the whole $script = "return ($)"; via some sort of helper func. 
					# 			as in, pass $expect into Get-ReturnWhatzit ... 
					# 			and... it'll figure out what to do based on the type? 
					# 	that PROBABLY makes the most sense actually. 
					
					$prop.Expect = [ScriptBlock]::Create($script);	
	
	
	# TODO: this looks pretty dope actually: 
	# 	https://github.com/iRon7/ConvertTo-Expression
	
	switch ($Object.GetType().FullName) {
		"System.String" {
			$script = "return `"$Object`";";
		}
		"System.Object[]" {
			# TODO: this is a REALLY naive implementation and ... it's also casting @(10, "10") to @(10, 10) (as near as I can tell... )
			$data = $Object -join ",";
			$script = "return @(" + $data + "); ";
		}
		default {
			if (Has-Value $Path) {
				if (Object-HasSpecifiedPropertyByPath $Object -Path $Path) {
					try {
						# there are 2 options here: 
						# 	a. $script = "return $object.$path; "
						# 	b. $output = $object.$path => $scrip = "return $output";
						
						# going to use the first option - initially... 
						# 		$script = "return $Object.$($Path);";
						#   except ... that really didn't work... 
						
						
						
						$output = $Object.$Path;
						$script = "return `"$output`"";
						
			Write-Host "script: $script";
						
					}
					catch {
						throw "context here about what we're doing ... and ... unexpected error trying to assign: $_ etc... "
					}
				}
				else {
					throw "some context here for whatever... of -PathType ... does NOT have the property (or a child property) of ... -Path specified... ";
				}
			}
			else {
				$script = "return $Object;";
			}
		}
	}
	
	return [ScriptBlock]::Create($script).GetNewClosure();
}
#>