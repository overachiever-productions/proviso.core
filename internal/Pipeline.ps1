Set-StrictMode -Version 1.0;

function Execute-Pipeline {
	[CmdletBinding()]
	param (
		[ValidateSet("Read", "Test", "Invoke")]
		[Parameter(Mandatory)]
		[string]$Verb,
		[ValidateSet("Facet", "Surface", "Runbook")]
		[string]$OperationType,
		[parameter(Mandatory)]
		[string]$Name,
		[object]$Model,
		[object]$Config,
		[object]$Target
	);
	
	begin {
		Write-Verbose "Starting Processing Pipeline.";
		[Proviso.Core.Catalog]$Catalog = $global:PvCatalog;
	};
	
	process {
		# ====================================================================================================
		# 1. Setup. 
		# ====================================================================================================
		#region "Setup"
		[datetime]$pipelineStart = [datetime]::Now;
		Write-Debug "	Pipeline Processing Starting. -Verb [$Verb] -OperationType [$OperationType] -Name [$Name] ";
		
		[Proviso.Core.Definitions.SurfaceDefinition[]]$surfaceDefinitions = @();
		[Proviso.Core.Definitions.FacetDefinition[]]$facetDefinitions = @();
		
		Write-Debug "		Processing Pipeline: Processing Objects Defined.";
		
		try {
			switch ($OperationType) {
				"Facet" {
					[Proviso.Core.Definitions.FacetDefinition]$targetFacet = $Catalog.GetFacetByName($Name);
					if ($null -eq $targetFacet) {
						throw "Could not find [Facet] with name: [$Name].";
					}
					
					$facetDefinitions += $targetFacet;
					Write-Debug "		Processing Pipeline: Target is Facet with name: [$Name].";
				}
				"Surface" {
					[Proviso.Core.Definitions.SurfaceDefinition]$targetSurface = $Catalog.GetSurface($Name);
					
					if ($null -eq $targetSurface) {
						throw "Could not find [Surface] with name: [$Name].";
					}
					
					$surfaceDefinitions += $targetSurface;
					Write-Debug "		Processing Pipeline: Target is Surface with name: [$Name]";
				}
				"Runbook" {
					[Proviso.Core.Definitions.RunbookDefinition]$targetRunbook = $Catalog.GetRunbook($Name);
					
					if ($null -eq $targetSurface) {
						throw "Could not find [Runbook] with name: [$Name].";
					}
					
					foreach ($surface in $targetRunbook.GetSurfaces()) {
						$surfaceDefinitions += $surface;
					}
					
					Write-Debug "		Processing Pipeline: Target is Runbook with name: [$Name]";
				}
				default {
					throw "Invalid -OperationType: [$OperationType] specified for Execute-Pipeline.";
				}
			}
		}
		catch {
			Write-Debug "		Processing Pipeline: Exception during Setup: $($_.Exception.InnerException.Message) -Stack: $($_.ScriptStackTrace)";
			throw "$($_.Exception.InnerException.Message) `r`t$($_.ScriptStackTrace) ";
		}
		
		[Proviso.Core.Processing.ProcessingManifest]$manifest = New-Object Proviso.Core.Processing.ProcessingManifest([Proviso.Core.OperationType]$OperationType, [Proviso.Core.Verb]$Verb, $Name);
		$manifest.PipelineStart = $pipelineStart;
		$manifest.HostName = "$((Get-CimInstance Win32_ComputerSystem -Verbose:$false).Domain)\$([System.Net.Dns]::GetHostName())";
		#endregion
		
		# ====================================================================================================
		# 2. Discovery 
		# ====================================================================================================
		#region "Discovery"
		Write-Verbose "Processing Pipeline: Executing Discovery...";
		$manifest.DiscoveryStart = [datetime]::Now;
		
		# Initial Expansion:
		foreach ($surface in $surfaceDefinitions) {
			Write-Host "		Processing Pipeline: Expanding Runbook Surface: [$($surface.Name)].";
			$manifest.AddSurfaceDefinition($surface);
		}
		
		foreach ($facet in $facetDefinitions) {
			Write-Debug "		Processing Pipeline: Expanding Facet: [$($facet.Name)]."
			$manifest.AddFacetDefinition($facet);
		}
		
		# Validation & Binding (via CLR Discovery operations):
		Write-Debug "			Processing Pipeline: ProcessingManifest.FacetDefinitionsCount = [$($manifest.FacetDefinitionsCount)].";
		try {
			Write-Debug "		Processing Pipeline: Starting Discovery.";
			switch ($OperationType) {
				"Runbook" {
					Write-Debug "			Processing Pipeline: Validation and Binding for Runbook: [$Name].";
					[Proviso.Core.Definitions.RunbookDefinition]$runbookDef = $Catalog.GetRunbook($Name);
					if ($null -eq $runbookDef) {
						throw "Proviso Framework Error. Runbook [$Name] not found in PVCatalog.";
					}
					
					[Proviso.Core.Models.Runbook]$runbook = New-Object Provis.Core.Models.Runbook($runbookDef.Name, $runbookDef.Setup, $runbookDef.Cleanup);
					
					foreach ($aDef in $runbookDef.AssertDefinitions) {
						
					}
					
					foreach ($implementDefinition in $runbookDef.Implements) {
						$surfaceDefinition = $Catalog.GetSurface($implementDefinition.SurfaceName);
						if ($null -eq $surfaceDefinition) {
							throw "Proviso Framework Error. A Surface with the name of [$($implementDefinition.SurfaceName)] could not be found in the PvCatalog.";
						}
						
						
						# TODO:
						# now ... convert the surfaceDefinition to ... a Surface... 
						# and... i THINK the currentCatalog should have, maybe?, already done this with all Surfaces?
						# so that I'm not 'double-creating' or converting surfaces/etc.						
					}
					
					$manifest.TargetRunbook = $runbook;					
				}
				"Surface" {
					Write-Debug "			Processing Pipeline: Validation and Binding for Surface: [$Name].";
					
					
				}
				"Facet" {
					Write-Debug "			Processing Pipeline: Validation and Binding for Facet: [$Name].";
					[Proviso.Core.Definitions.FacetDefinition]$facetDef = $Catalog.GetFacetByName($Name);
					if ($null -eq $facetDef) {
						throw "Proviso Framework Error. Facet [$Name] not found in PVCatalog.";
					}
					
					[Proviso.Core.Models.Facet]$facet = New-Object Proviso.Core.Models.Facet($facetDef.Name, $facetDef.Id, $facetDef.FacetType, $facetDef.AspectName, $facetDef.SurfaceName, $null)
					$manifest.AddFacet($facet);
					$manifest.AddSurface((New-Object Proviso.Core.Models.PlaceHolderSurface($facet)));
				}
				default {
					throw "Proviso Framework Error. Invalid -OperationType: [$OperationType] encountered in Execute-Pipeline.";
				}
			}
			
			foreach ($facet in $manifest.Facets) {
				Write-Host "i'm a facet!"
				
				if ("Pattern" -eq $facet.FacetType) {
					
					Write-Host "i'm a pattern!"
					
					# make sure we've got an iterator. 
					# and that paths match up as they should/need-to. 
					#      er, make sure we've got 1 iterator per each path-indication of an iterator, right?
					#
					# also see if we've got ANY properties. 
					#  if we don't that's 'fine'. we just can't READ against this thing... 
					#      i.e., ONLY if there's a -Target ... then, the ... 'read' or 'extract' becomes, literally: $target. 
					#      so, there needs to be some way to specify that. 					
				}
				
				
				# foreach (Cohort c in f.RawCohorts ?)
				#{
				#    //     make sure we've got an Enumerate(or)
				#}				
				
			}
			
			
			# 		 3. For each Facet:
            # 		      a) dump into _facetsToProcess. 
            # 		      b) also link <aspectName, facet> ?? 
            # 		      c) and ditto for <surface, facet> as well... so'z, when processing, we can get all facets by surface/aspect. 
			# 		
            # 		      d) if Pattern (vs 'facet') 
            # 		          then expand/extract and verify we've got an iterator. 
            # 		              note: either ... run the ACTUAL expansion here? (not ideal) 
            # 		              or just 'tell' (via meta-data/etc.) the facet what to 'expect' at run-time. 
            # 		          as in, this'll be SIMILAR to what old-proviso did at COMPILE time - only, I'll be doing that same 'stuff' during discovery. 
            # 		              i assume discovery will work well enough... 
			# 		
			# 		
            # 		      e) also. if pattern, make sure we've got the Iterate|Iterator and applicable add/remove for the .verb (or throw).
			# 		
            # 		 4. for each property in the facet... 
            # 		      scalar or cohort? 
            # 		          if cohort, 'discovery' of paths and details? 
            # 		          verify that we'll have the Enumerate|Enumerator and Add/Remove needed. 
            # 		      again, rather than running full-blown/actual expansion here, would prefer to 'indicate' to processing what to expect here. 
            # 		      similar to how old proviso handled ... compile-time stuff. 
			# 		
            # 		 done, right? 
			
			
			
		}
		catch {
			Write-Debug "		Processing Pipeline: Exception During Discovery: $($_.Exception.Message) -Stack: $($_.ScriptStackTrace)";
			throw "$($_.Exception.Message) `r`t$($_.ScriptStackTrace) ";
		}
		finally {
			$manifest.DiscoveryEnd = [datetime]::Now;
			Write-Debug "		  Processing Pipeline: Discovery Complete.";
		}
		#endregion
		
		# ====================================================================================================
		# 3. Processing
		# ====================================================================================================
		#region "Processing"
		Write-Verbose "Processing Pipeline: Executing Processing Phase...";
		$manifest.ProcessingStart = [datetime]::Now;
		
		try {
			if ($manifest.HasRunbookSetup) {
				Write-Debug "		Processing Pipeline: Starting Runbook.Setup() codeblock.";
				[scriptblock]$runbookSetup = $manifest.TargetRunbook.Setup;
				Write-Host "Would be running: |$runbookSetup|";
				
				Write-Debug "		  Processing Pipeline: Runbook.Setup() codeblock complete.";
			}
			
			if ($manifest.HasRunbookAssertions) {
				Write-Debug "		Processing Pipeline: Starting Runbook.Assertions() codeblock.";
				foreach ($assert in $manifest.TargetRunbook.Assertions) {
					if ($assert.Enabled) {
						# run the assert.
					}
					else {
						# disabled or ... config-only? and report on it... 
					}
				}
				Write-Debug "		  Processing Pipeline: Runbook.Assertions() complete.";
			}
			
			# NOTE: Theres' a cheat/hack in the CLR Processing Manifest that makes it so that there will always be at least 1x SURFACE
			# 		to 'loop through' here. It 'marks' said surface as a 'marker/fake/placeholder' but this approach seemed better than 2x pipeline 'paths'
			foreach ($surface in $manifest.Surfaces) {
				# TODO: update any Context object here that needs updating... 
			
				if ($surface.Setup) {
					# do setup and handle errors/results
				}
				
				if ($surface.HasActiveAssertions) {
					# not just IF there's an Asertions {} block, but if: a) there are Asserts and b) they're NOT all disabled and/or Configure-Only/etc. 
					# Assert + handle results.
				}
				
				foreach ($facet in $surface.Facets) {
					Write-Verbose "Starting Processing of Facet [$($facet.FacetName)].";
					
					#$global:PvFacetContext = $manifest.GetCurrentFacetContextInstance();
					# TODO: update other contexts as well... i.e., Current.Facet/Surface and stuff... 
					
					
					if (0 -eq $facet.Properties.Count) {
						# this can sorta be fine... 
						# 	as in... $Target becomes the 'Read'/extract, $Model becomes the expect, Test = (does $target -eq $model), and Configure = (make $target become $model).
						Write-Verbose "Facet [$($facet.FacetName)] has NO properties";
						
						if ($Verb -in @("Read", "Test", "Invoke")) {
							Write-Debug "				Executing -Read with NO PROPERTY (returning -Target).";
							
						}
						
						if ($Verb -in ("Test", "Invoke")) {
							Write-Debug "				Executing -Compare with NO PROPERTY (comparing -Model vs -Target).";
						}
						
						if ("Invoke" -eq $Verb) {
							Write-Debug "				Executing -Invoke with NO PROPERTY (comparing -Model vs -Target, setting -Target = -Model (if not equal) + recomparing).";
							
						}
					}
					else {
						foreach ($facetProperty in $facet.Properties) {
							Write-Host "in ur props"
							if ($Verb -in @("Read", "Test", "Invoke")) {
								Write-Debug "				Executing -Read for Property [$($facetProperty.Name)]."
							}
							
							if ($Verb -in ("Test", "Invoke")) {
								# do compare stuff. 
								# 	 specifically: 
								# 		a. expect. 
								# 		b. compare.
							}
							
							if ("Invoke" -eq $Verb) {
								# do configure stuff - on things that need configure. 
								
								# do re-extract 
								
								# do re-compare.
								# 		meaning, we need to re-grab expect (if it's not stored already (and... arguably, it should already be stored))
							}
						}
					}
					
					#$global:PvFacetContext = $null;
				}
				
				if ($surface.Cleanup) {
					# run cleanup + handle errors/results.
				}
			}
			
			if ($manifest.HasRunbookCleanup) {
				Write-Debug "		Processing Pipeline: Starting Runbook.Cleanup() codeblock.";
				# execute runbook cleanup.
				Write-Debug "		  Processing Pipeline: Runbook.Cleanup() codeblock complete.";
			}
		}
		catch {
			Write-Debug "		Processing Pipeline: Exception During Processing: $($_.Exception.Message) -Stack: $($_.ScriptStackTrace)";
			throw "$($_.Exception.Message) `r`t$($_.ScriptStackTrace) ";
		}
		finally {
			$manifest.ProcessingEnd = [datetime]::Now;
			Write-Debug "		  Processing Pipeline: Processing Phase Complete.";
		}
		#endregion
		
		# ====================================================================================================
		# 4. Post-Processing
		# ====================================================================================================
		#region "Post-Processing"
		Write-Verbose "Processing Pipeline: Finalizing Outputs...";
		
		# switch on verb type and ... return $manifest.[Verb]Result as necessary.
		#endregion
	};
	
	end {
		$manifest.PipelineEnd = [datetime]::Now;
		Write-Debug "	Pipeline Processing Complete.";
		Write-Verbose "Processing Pipeline Complete.";
	};
}