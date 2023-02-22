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
		
		[Proviso.Core.Definitions.FacetDefinition]$targetFacet = $null;
		[Proviso.Core.Definitions.SurfaceDefinition]$targetSurface = $null;
		[Proviso.Core.Definitions.RunbookDefinition]$targetRunbook = $null;
		Write-Debug "		Processing Pipeline: Processing Objects Defined.";
		
		try {
			switch ($OperationType) {
				"Facet" {
					$targetFacet = $Catalog.GetFacetByName($Name);
					if ($null -eq $targetFacet) {
						throw "Could not find [Facet] with name: [$Name].";
					}
					
					$facetDefinitions += $targetFacet;
					Write-Debug "		Processing Pipeline: Target is Facet with name: [$Name].";
				}
				"Surface" {
					$targetSurface = $Catalog.GetSurface($Name);
					
					if ($null -eq $targetSurface) {
						throw "Could not find [Surface] with name: [$Name].";
					}
					
					$surfaceDefinitions += $targetSurface;
					Write-Debug "		Processing Pipeline: Target is Surface with name: [$Name]";
				}
				"Runbook" {
					$targetRunbook = $Catalog.GetRunbook($Name);
					
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
			$manifest.ExecuteDiscovery($Catalog);
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