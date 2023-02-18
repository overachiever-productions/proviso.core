Set-StrictMode -Version 1.0;

<#

	Import-Module -Name "D:\Dropbox\Repositories\proviso.core" -Force;

	$global:DebugPreference = "Continue";
	$global:VerbosePreference = "Continue";


	Surface "Bigly" {
		Facet "Child" {}
	}


	Facet "Host Ports" {
		Property "ICMP" {
		}
		Property "RDP" {
		}
	}

	Surface "Firewall Rules" {
		Facet "SQL Server Ports" {
			Property "SQL Server" {
			}
			Property "SQL Server - DAC" {
			}
			Property "SQL Server - Mirroring" { 
			}
		}

		Import -Facet "Host Ports";
	}

	Read-Facet "SQL Server Ports";
	Read-Facet "Host Ports";

	# Get this to work 'better' - i.e., the error I'm getting now is FUGLY: 
	Read-Facet "This face does not exist";

	Runbook "Firewall Stuff" { 
		Setup {} 
		Assertions {}

		Operations {
			Run [-Facet] "Intellisense Name Here would be Great" -something? 
			Run "Another Facet Name here" -Impact "overwritten from source"

			Run "etc..." -ExecutionOrder 1 -Comment "not sure why not up top... but... this is an option."

		}

		Cleanup { }
	}



#>

function Facet {
	[CmdletBinding()]
	param (
		[Parameter(Mandatory, Position = 0)]
		[string]$Name,
		[Parameter(Mandatory, Position = 1)]
		[ScriptBlock]$ScriptBlock,
		[string]$Id = $null,    # will be a GUID if not explicitly defined. But can be a 'rule number' or something  ... and can be a 'token' in -DisplayFormats. 
		[string]$ModelPath = $null,
		[string]$TargetPath = $null,
		[string]$Path = $null,
		[ValidateSet("None", "Low", "Medium", "High")]
		[string]$Impact = "None",
		[switch]$Skip = $false,
		[string]$Ignore = $null,
		[object]$Expect = $null,
		[object]$Extract = $null,
		[string]$ThrowOnConfig = $null
	);
	
	begin {
		[bool]$xVerbose = ("Continue" -eq $global:VerbosePreference) -or ($PSBoundParameters["Verbose"] -eq $true);
		[bool]$xDebug = ("Continue" -eq $global:DebugPreference) -or ($PSBoundParameters["Debug"] -eq $true);
		
		Enter-Block $MyInvocation.MyCommand -Name $Name -Verbose:$xVerbose -Debug:$xDebug;
	};
	
	process {
		$bypass = Is-ByPassed $MyInvocation.MyCommand.Name -Name $Name -Skip:$Skip -Ignore $Ignore -Verbose:$xVerbose -Debug:$xDebug;
		
		if (Should-SetPaths $MyInvocation.MyCommand.Name -Name $Name -ModelPath $ModelPath -TargetPath $TargetPath -Path $Path -Verbose:$xVerbose -Debug:$xDebug) {
			$ModelPath, $TargetPath = $Path;
		}
		
		$facetDefinition = New-Object Proviso.Core.Definitions.FacetDefinition($Name, $ModelPath, $TargetPath, $bypass, $Ignore);
		
		# TODO: the following is DAMNED close to what I want/need:
		# 		it ... assigns values ONLY if they're present ... 
		# 		the RUB is ... that it doesn't assign OBJECTs ... it assigns strings ... 
		# 			so, maybe I need to build a helper func (or set of helper funcs) that can bind these details and ... will do lookups if/as needded?
		# 		OR... 
		# 			maybe the BuildContext can/does/will keep not only "Semantics" or "which func-name" we're currently in. But will also keep the ACTUAL object in question?
		# 			yeah. that starts to get pretty cool... 
		# 				and... NO: not going to be able to have the ACTUAL parent objects in play at this time. 
		# 				the HANDS-DOWN best I can do is have their NAMES (strings). Cuz of how things transpire. 
		# 				so, what I'm going to have to do is: 
		# 						1. bind names to the facets at THIS point (compile time)
		# 						2. I'll have the actual OBJECTS in the catalog. AFTER compilation is done. 
		# 						3. During 'discovery' phase, I can create new objects or whatever makes sense and BIND the actual objects
		# 							into a true 'graph' of what's needed. 
		# 				Otherwise, I CAN, at this point (i.e., compile time) work on orthography. 
		# 				And, I think I'm either going to: 
		# 						A) 100% nest orthography calls into BuildContext calls/operations (and throw from in there)
		# 						or 
		# 						B) move orthography OUT of C# and into a set of 'helper' funcs (maybe in common.ps1 or maybe still in orthography.ps1)
		# 							and just tackled things there. 
		# 					Point being, orthography WILL still be handled. But it'll be transparent from the perspective of my 'blocks'.
		#		$facetDefinition.Surface = $global:PvBuildContext.Surface;
		#		$facetDefinition.Runbook = $global:PvBuildContext.Runbook;
		
		if ($Impact -ne "None") {
			$facetDefinition.Impact = $Impact; # TODO: either set parse this here and convert to Enum, or ... pass into a .SetImpact(string impact) C# method that parses + assigns.
		}
		
		if ($Expect) {
			$facetDefinition.SetExpectFromParameter($Expect);
		}
		
		if ($Extract) {
			$facetDefinition.SetExtractFromParameter($Extract);
		}
		
		if ($ThrowOnConfig) {
			$facetDefinition.SetThrowOnConfig($ThrowOnConfig);
		}
		
		& $ScriptBlock;
	};
	
	end {
		
		Write-Debug "			Adding FACET [$Name] to Catalog. My SURFACE IS: [$($global:PvLexicon.GetCurrentBlockNameByType("Surface"))]"
		
		$global:PvCatalog.AddFacetDefinition($facetDefinition);
		Exit-Block $MyInvocation.MyCommand -Name $Name -Verbose:$xVerbose -Debug:$xDebug;
	};
}