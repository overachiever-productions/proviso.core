Set-StrictMode -Version 1.0;

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
		
		Write-Debug "Starting Pipeline Operations.";
		Write-Verbose "Starting Pipeline Operations.";
		
		[bool]$isRunbook = $false;
	}
	
	process {
		# ====================================================================================================
		# 1. Setup
		# ====================================================================================================		
		#region Setup
		$results = Initialize-ResultsObject -Verb $Verb -OperationType $OperationType -Block $Block -Verbose:$xVerbose -Debug:$xDebug;
		
		#$blockInstance = DeepClone-Block -Block $Block -Verbose:$xVerbose -Debug:$xDebug;
#$blockInstance = $Block.Clone();
		
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
			Write-Debug "	Processing Pipeline: Exception During Setup: $($_.Exception.Message) -Stack: $($_.ScriptStackTrace)";
			# TODO: implement this throw... stuff
			throw "Processing Setup Exception: $_";
		}
		Write-Debug "	Pipeline Setup Operations Complete.";
		
		#endregion
		
		# ====================================================================================================
		# 2. Runtime Validation 
		# ====================================================================================================
		#region Validation 
		Write-Debug "	Starting Pipeline Validations.";
		
		# NOTE: no need to evaluate the verb for READs - we'll ALWAYS at LEAST do READ (can't Test (Compare) or Invoke (Configure) without READ-ing).
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
 
		Write-Debug "	  Pipeline Validations Complete.";
		#endregion
		
		# ====================================================================================================
		# 3. Processing (i.e., actual pipeline)
		# ====================================================================================================		
		#region Processing 
		
		Write-Debug "	Starting Pipeline Processing.";
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
					# setup facet-level context info/details... 
					# e.g., $global:PvContext.Facet.xxxx props and such. 
					
					Write-Debug "		Iterating Properties.";
					foreach ($property in $facet.Properties) { #note that at this point we'll always have 1 or more props, even if the prop in question is anonymous... 
						
						# TODO: additional context info/setup... 

						
						if ($property.IsCohort) {
			Write-Host "I'm a cohort... "
							foreach ($nestedProperty in $property.Properties) {
								Process-PropertyOperations -Verb $Verb -Property $nestedProperty -Results $results `
									-Model $Model -Config $Config -Target $Target -Verbose:$xVerbose -Debug:$xDebug;
							}
						}
						else {
							Process-PropertyOperations -Verb $Verb -Property $property -Results $results `
								-Model $Model -Config $Config -Target $Target -Verbose:$xVerbose -Debug:$xDebug;
						}
						
						
						# free-up/clear any context info as needed. 
					}
					Write-Debug "		Property Iteration Complete.";
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
			
		}
		Write-Debug "	  Pipeline Processing Complete.";
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
		Write-Debug "Pipeline Operations Complete.";
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
	$format = $Block.Format;
	
	return New-Object Proviso.Core.FacetReadResult($name, $format);
}

function Process-PropertyOperations {
	[CmdletBinding()]
	param (
		[ValidateSet("Read", "Test", "Invoke")]
		[Parameter(Mandatory)]
		[string]$Verb,
		
		# TODO: might need to end up making this an IProperty (to account for Inclusion|Property (but never cohort/etc.))
		[Parameter(Mandatory)]
		[Proviso.Core.Models.Property]$Property,
		
		$Results,
		
		[Object]$Model,
		
		[Object]$Config,
		
		[Object]$Target
	);
	
	# NOTE: no need to evaluate the verb for READs - we'll ALWAYS at LEAST do READ (can't Test (Compare) or Invoke (Configure) without READ-ing).
	try {
		$block = $Property.Extract;
		[Object]$output = & $block;
		
		[Proviso.Core.ExtractResult]$extract = [Proviso.Core.ExtractResult]::SuccessfulExtractResult(($output.GetType().FullName), $output);
	}
	catch {
		[Proviso.Core.ExtractResult]$extract = [Proviso.Core.ExtractResult]::FailedExtractResult($_);
	}
	
	[Proviso.Core.PropertyReadResult]$read = New-Object Proviso.Core.PropertyReadResult(($Property.Name), ($Property.DisplayFormat), $extract);
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
				if ($prop.IsCohort) {
					foreach ($nestedProp in $prop.Properties) {
						if (-not ($nestedProp.Extract)) {
							if (Is-Empty $Target) {
								throw "Runtime Validation Failure. Cohort Property [$($nestedProp.Name)] does NOT have an explicit -Extract or Extract {} defined. Either Implement Extract or specify -Target for $($global:PvPipelineContext_CurentOperationName). ";
							}
							
							# TODO: uhhh... what about ... if the property in question has a -TargetPath ... then this should be generating something like "return $Target.<targetPath>"..
							$nestedProp.Extract = Get-ReturnScript $Target;
						}
					}
				}
				else {
					if (-not ($prop.Extract)) {
						if (Is-Empty $Target) {
							throw "Runtime Validation Failure. Property [$($prop.Name)] does NOT have an explicit -Extract or Extract {} defined. Either Implement Extract or specify -Target for $($global:PvPipelineContext_CurentOperationName). ";
						}
						
						# TODO: uhhh... what about ... if the property in question has a -TargetPath ... then this should be generating something like "return $Target.<targetPath>"..
						$prop.Extract = Get-ReturnScript $Target;
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
		[Object]$Model
	);
	
	foreach ($surface in $Surfaces) {
		foreach ($facet in $surface.Facets) {
			foreach ($prop in $facet.Properties) {
				if ($prop.IsCohort) {
					foreach ($nestedProp in $prop.Properties) {
						if (-not ($nestedProp.Extract)) {
							if (Is-Empty $Model) {
								throw "Runtime Validation Failure. Cohort Property [$($nestedProp.Name)] does NOT have an explicit -Expect or Expect {} defined. Either Implement Expect or specify -Model for $($global:PvPipelineContext_CurentOperationName). ";
							}
							
							# TODO: uhhh... what about ... if the property in question has a -ModdelPath ... then this should be generating something like "return $Model.<modelPath>"..
							$nestedProp.Extract = Get-ReturnScript $Model;
						}
					}
				}
				else {
					if (-not ($prop.Extract)) {
						if (Is-Empty $Model) {
							# TODO: uhhh... what about ... if the property in question has a -ModdelPath ... then this should be generating something like "return $Model.<modelPath>"..
							throw "Runtime Validation Failure. Property [$($prop.Name)] does NOT have an explicit -Expect or Expect {} defined. Either Implement Expect or specify -Model for $($global:PvPipelineContext_CurentOperationName). ";
						}
						
						$prop.Extract = Get-ReturnScript $Model;
					}
				}
			}
		}
	}
}