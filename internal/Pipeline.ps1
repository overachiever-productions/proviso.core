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
		
		# TODO: impact and other options/etc. 
	);
	
	begin {
		# not sure I want to put any logic in here... given how the PowerShell pipeline works...
		
		[Proviso.Core.Catalog]$Catalog = $global:PvCatalog;
	};
	
	process {
		# ====================================================================================================
		# 1. Setup. 
		# ====================================================================================================
		[datetime]$processingStart = [datetime]::Now;
		[Proviso.Core.Definitions.FacetDefinition[]]$facetDefinitions = @();
		[Proviso.Core.Definitions.SurfaceDefinition[]]$surfaceDefinitions = @();
		
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
			}
		}
		catch {
			Write-Debug "		Processing Pipeline: Exception during Setup: $($_.Exception.InnerException.Message) -Stack: $($_.ScriptStackTrace)";
			throw "$($_.Exception.InnerException.Message) `r`t$($_.ScriptStackTrace) ";
		}
		
		[Proviso.Core.Processing.ProcessingManifest]$manifest = New-Object Proviso.Core.Processing.ProcessingManifest([Proviso.Core.OperationType]$OperationType, [Proviso.Core.Verb]$Verb);
		$manifest.ProcessingStart = $processingStart;
		$manifest.HostName = "$((Get-CimInstance Win32_ComputerSystem -Verbose:$false).Domain)\$([System.Net.Dns]::GetHostName())";
		
		# ====================================================================================================
		# 2. Discovery 
		# ====================================================================================================
		# Additional Expansion:
		foreach ($surface in $surfaceDefinitions) {
			Write-Host "		Processing Pipeline: Expanding Runbook Surface: [$($surface.Name)].";
			$manifest.AddSurfaceDefinition($surface);
		}
		
		foreach ($facet in $facetDefinitions) {
			Write-Debug "		Processing Pipeline: Expanding Surface Facet: [$($facet.Name)]."
			$manifest.AddFacetDefinition($facet);
		}
		
		# Validation & Binding (via CLR Discovery operations):
		try {
			Write-Debug "		Processing Pipeline: ProcessingManifest.FacetDefinitionsCount = [$($manifest.FacetDefinitionsCount)].";
			
			Write-Debug "		Processing Pipeline: Starting Discovery.";
			$manifest.ExecuteDiscovery($Catalog);
			Write-Debug "		Processing Pipeline: Discovery Complete!";
		}
		catch {
			Write-Debug "		Processing Pipeline: Exception During Discovery: $($_.Exception.Message) -Stack: $($_.ScriptStackTrace)"; throw "$($_.Exception.InnerException.Message) `r`t$($_.ScriptStackTrace) ";
			throw "$($_.Exception.Message) `r`t$($_.ScriptStackTrace) ";
		}
		
		# ====================================================================================================
		# 3. Processing
		# ====================================================================================================
# TODO: set ProcessingStarted = NOW... 
#  i.e., previous/extant "processingStarted" should be discovery info/etc. 
		try {
			if ($manifest.HasRunbookSetup) {
				# do the runbook setup
			}
			
			if ($manifest.HasRunbookAssertions) {
				# do the assertions
			}
			
			foreach ($surface in $manifest.Surfaces) {
				# TODO: update any Context object here that needs updating... 
				
				if ($surface.Setup) {
					# do setup and handle errors/results
				}
				
				if ($surface.HasActiveAssertions) {
					# not just IF there's an Asertions {} block, but if: a) there are Asserts and b) they're NOT all disabled and/or Configure-Only/etc. 
					# Assert + handle results.
				}
				
				# ahhh... bug/problem. 
				# 		if there's no Surface... then ... we'll never process Facets.
				# 		i can/could do them in another spot... but... that seems like it'd lead to DRY violations. 
				# INSANELY, might actually make sense to create an anonymous Surface which'll return FALSE on all of the if($surface.X) operations above/below (setup, assertions, cleanup)
				# 		and simply handle the idea of if($surface.IsPlaceHolderOnly) in the few spots where I need to do so. 
				foreach ($facet in $surface.Facets) {
					$global:PvFacetContext = $manifest.GetCurrentFacetContextInstance();
					# TODO: update other contexts as well... i.e., Current.Facet/Surface and stuff... 
					
					foreach ($facetProperty in $facet.Properties) {
						if ($Verb -in @("Read", "Test", "Invoke")) {
							# do read stuff... 
							# 	which is JUST extract. 
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
					
					$global.PvFacetContext = $null;
				}
				
				if ($surface.Cleanup) {
					# run cleanup + handle errors/results.
				}
			}
			
			if ($manifest.HasRunbookCleanup) {
				# to runbook cleanup.
			}
		}
		catch {
			throw "Ruh roh! Processing Exception."
		}
		
		# ====================================================================================================
		# 4. Post-Processing
		# ====================================================================================================
		
		# switch on verb type and ... return $manifest.[Verb]Result as necessary.
		
	};
	
	end {
		
	};
}