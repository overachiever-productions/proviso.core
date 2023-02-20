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
		[Proviso.Core.Definitions.FacetDefinition[]]$facetDefinitions = @();
		[Proviso.Core.Definitions.SurfaceDefinition[]]$surfaceDefinitions = @();
		
		[Proviso.Core.Definitions.FacetDefinition]$targetFacet = $null;
		[Proviso.Core.Definitions.SurfaceDefinition]$targetSurface = $null;
		[Proviso.Core.Definitions.RunbookDefinition]$targetRunbook = $null;
		
		try {
			switch ($OperationType) {
				"Facet" {
					$targetFacet = $Catalog.GetFacetByName($Name);
					if ($null -eq $targetFacet) {
						throw "Could not find [Facet] with name: [$Name].";
					}
					
					$facetDefinitions += $targetFacet;
				}
				"Surface" {
					$targetSurface = $Catalog.GetSurface($Name);
					
					if ($null -eq $targetSurface) {
						throw "Could not find [Surface] with name: [$Name].";
					}
					
					$surfaceDefinitions += $targetSurface;
				}
				"Runbook" {
					$targetRunbook = $Catalog.GetRunbook($Name);
					
					if ($null -eq $targetSurface) {
						throw "Could not find [Runbook] with name: [$Name].";
					}
					
					foreach ($surface in $targetRunbook.GetSurfaces()) {
						$surfaceDefinitions += $surface;
					}
				}
			}
		}
		catch {
			throw "$($_.Exception.InnerException.Message) `r`t$($_.ScriptStackTrace) ";
		}
		
#		$result = "some sort of processing object? or ... a distinct XResult object?";
#		$startTime = "startTime"; # property of result/processing thingy
#		$machineName = "machineName"; # property of result/processing thingy		
		
		# ====================================================================================================
		# 2. Discovery 
		# ====================================================================================================
		[Proviso.Core.Processing.ProcessingManifest]$manifest = New-Object Proviso.Core.Processing.ProcessingManifest([Proviso.Core.OperationType]$OperationType, [Proviso.Core.Verb]$Verb);
		
		
		# Finalize Expansion:
		foreach ($surface in $surfaceDefinitions) {
			
		}

		
#		foreach ($surface in $surfaces) {
#			# need to address ... Setup
#			# need to address ... 		Assertions + assert operations
#			# need to address ... Cleanup 
#			
#			# Hmmm. Need to work on aspects here too... 
#		}
		
		# Modality 
#		foreach ($facet in $facets) {
#			
#		}
		
		# Validation 
		
		# Binding 
		
		# ====================================================================================================
		# 3. Processing
		# ====================================================================================================
		
		# TODO: create a context per each Facet we're processing. 
		# 	also, probably need other contexts at this point as well. 
		
		# ====================================================================================================
		# 4. Post-Processing
		# ====================================================================================================
	};
	
	end {
		
	};
}