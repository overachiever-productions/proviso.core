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
		[datetime]$pipelineStart = [datetime]::Now;
		
		[Proviso.Core.ISurface[]]$surfaces = @();
		
		try {
			switch ($OperationType) {
				{ $_ -in @("Facet", "Pattern") } {
					$fakeSurface = New-Object Proviso.Core.Models.PlaceHolderSurface;  # still hate how Posh won't allow parameterless .ctors..
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
			throw "Processing Setup Exception.";
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
		
		
#		if (-not (Does-ExtractExistsForAllProperties -Surfaces $surfaces -Verbose:$xVerbose -Debug:$xDebug)) {
#			if (Is-Empty $Target) {
#				$global:PvPipelineContext_OperationDescription
#				
#				throw "Pipeline Validation Error. All Properties in $($global:PvPipelineContext_OperationDescription) must containt an -Extract parameter or Extract{} block OR -Target must be supplied to $Verb-XXXX operation.";
#				
#				throw "Pipleine failure for x_currentOperation(pulled from Read/test/whatever method..) cuz ... not all xyz have Extract and/or need -Target";
#			}
#		}
		
		
		# 		for TEST & INVOKE: 
		# 			- make sure we have a $Model or Expect {} for EVERY prop. 
		# 			- make sure we have a $Target or Extract {} for EVERY prop.
		
		#  	further, for INVOKE: 
		# 		make sure that the -Impact of all thingies to process NOT > than ... -PipelineAllowedImpact... 
		Write-Debug "	  Pipeline Validations Complete.";
		#endregion
		
		# ====================================================================================================
		# 3. Processing (i.e., actual pipeline)
		# ====================================================================================================		
		#region Processing 
		try {
			if ($isRunbook) {
				
				# A. 
				# if there's a .Setup { } block (and... if it's applicable???)
				# then... do $runbook.Setup();
				
				# B. 
				# if there are any asserts AND if they're applicable... 
				# 	run applicable RUNBOOK asserts.
			}
			
			foreach ($surface in $surfaces) {
				
				$surfaceName = "~PLACEHOLDER_SURFACE~";
				if (-not ($surface.IsPlaceHolder)) {
					$surfaceName = $surface.Name;
				}
				Write-Debug "		Processing Surface: [$surfaceName].";
				
				if ($surface.Setup) {
					# or... do we need to check for the verb types? 
					# do setup... 
				}
				
				if ($surface.HasActiveAssertions) {
					# i.e., if any assertions exist, are not disabled, and ... apply to the verb??? we're running... 
					# 		then... do each assertion. 
				}
				
				foreach ($facet in $surface.Facets) {
					# setup facet-level context info/details... 
					# e.g., $global:PvContext.Facet.xxxx props and such. 
					
					foreach ($property in $facet.Properties) { #note that at this point we'll always have 1 or more props, even if the prop in question is anonymous... 
						
						# TODO: additional context info/setup... 

						
						if ($property.IsCohort) {
			Write-Host "I'm a cohort... "
							foreach ($nestedProperty in $property.Properties) {
								Process-PropertyOperations -Verb $Verb -Property $nestedProperty -Model $Model -Config $Config -Target $Target -Verbose:$xVerbose -Debug:$xDebug;
							}
						}
						else {
							Process-PropertyOperations -Verb $Verb -Property $property -Model $Model -Config $Config -Target $Target -Verbose:$xVerbose -Debug:$xDebug;
						}
						
						
						# free-up/clear any context info as needed. 
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
			
		}
		
		#endregion
		
		# ====================================================================================================
		# 4. Post-Processing
		# ====================================================================================================		
	}
	
	end {
		
	}
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
		
		[Object]$Model,
		
		[Object]$Config,
		
		[Object]$Target
	);
	
	
	Write-Host "	PROPERTY: $($Property.Name)";
	
	# NOTE: no need to evaluate the verb for READs - we'll ALWAYS at LEAST do READ (can't Test (Compare) or Invoke (Configure) without READ-ing).
	# TODO" remove this IF check... and just ALWAYS run this operation.
	if ($Verb -in @("Read", "Test", "Invoke")) {
		
		# extract info and ... bundle it up for output/results info... 
		Write-Debug "			Executing EXTRACT: $($Property.Extract)";
	}

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
							
							$nestedProp.Extract = Get-ReturnScript $Target;
						}
					}
				}
				else {
					if (-not ($prop.Extract)) {
						if (Is-Empty $Target) {
							throw "Runtime Validation Failure. Property [$($prop.Name)] does NOT have an explicit -Extract or Extract {} defined. Either Implement Extract or specify -Target for $($global:PvPipelineContext_CurentOperationName). ";
						}
						
						$prop.Extract = Get-ReturnScript $Target;
					}
				}
			}
		}
	}
}

function Validate-ExpectOrModelForAllProperties {
	[CmdletBinding()]
	param (
		[Parameter(Mandatory)]
		[Proviso.Core.ISurface[]]$Surfaces
	);
	
	foreach ($surface in $Surfaces) {
		foreach ($facet in $surface.Facets) {
			foreach ($prop in $facet.Properties) {
				
				if ($prop.IsCohort) {
					foreach ($nestedProp in $prop.Properties) {
						# if not EXPECT or $model... ?throw... 
						
						Write-Host "		EXPECT: ";
						
						
					}
				}
				else {
					# if not EXPECT or $model... ?throw... 	
					
					Write-Host "		EXPECT: ";
				}
			}
		}
	}
}


#
#function Extract-PropertyValue {
#	[CmdletBinding()]
#	param (
#		[Proviso.Core.Models.Property]$Property,
#		[Object]$Model
#	);
#	
#	# fun... finally 'getting there' - i.e., to actual implementation logic. 
#	# 	at a high level, that should look roughly like: 
#	# 	if there's an Extract {} block defined (either cuz there was an explicit block or ... cuz there was an explicit -Extract "xxx" defined)
#	# 		then, run that. 
#	
#	# otherwise, if there's a Model: 
#	# 		and there's a .ModelPath... 
#	# 			then extract $Model.<ModelPath>
#	# 	otherwise, 
#	# 		just return $Model. 
#	
#	# and... if there was a $Model required PRIOR to the last bit of logic, we would have THROWN earlier on in the mix. 
#}
#
#function Test-Property {
#	[CmdletBinding()]
#	param (
#		
#	);
#}
#
#function Invoke-Property {
#	[CmdletBinding()]
#	param (
#		
#	);
#}