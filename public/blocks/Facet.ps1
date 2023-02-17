Set-StrictMode -Version 1.0;

<#

	Import-Module -Name "D:\Dropbox\Repositories\proviso.core" -Force;

	$global:DebugPreference = "Continue";
	$global:VerbosePreference = "Continue";

	Runbook "Network Stuff" {
		Surface "Firewall Rules" {
			Aspect {
				Facet "My First Facet" {
					Property "Test Property" {
					}
				}
			}
		}
	}

	Read-Facet "My First Facet" -Verbose;

#>

function Facet {
	[CmdletBinding()]
	param (
		[Parameter(Mandatory, Position = 0)]
		[string]$Name,
		[Parameter(Mandatory, Position = 1)]
		[ScriptBlock]$ScriptBlock,
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
		
		Enter-Facet $Name -Verbose:$xVerbose -Debug:$xDebug;
	};
	
	process {
		$bypass = Is-ByPassed $MyInvocation.MyCommand.Name -Name $Name -Skip:$Skip -Ignore $Ignore -Verbose:$xVerbose -Debug:$xDebug;
		
		if (Should-SetPaths $MyInvocation.MyCommand.Name -Name $Name -ModelPath $ModelPath -TargetPath $TargetPath -Path $Path -Verbose:$xVerbose -Debug:$xDebug) {
			$ModelPath, $TargetPath = $Path;
		}
		
		$facet = New-Object Proviso.Core.Models.Facet($Name, $ModelPath, $TargetPath, $bypass, $Ignore);
		
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
#		$facet.Surface = $global:PvBuildContext.Surface;
#		$facet.Runbook = $global:PvBuildContext.Runbook;
		
		if ($Impact -ne "None") {
			$facet.Impact = $Impact; # TODO: either set parse this here and convert to Enum, or ... pass into a .SetImpact(string impact) C# method that parses + assigns.
		}
		
		if ($Expect) {
			$facet.SetExpectFromParameter($Expect);
		}
		
		if ($Extract) {
			$facet.SetExtractFromParameter($Extract);
		}
		
		if ($ThrowOnConfig) {
			$facet.SetThrowOnConfig($ThrowOnConfig);
		}
		
		& $ScriptBlock;
	};
	
	end {
		
		Write-Verbose "Adding FACET [$Name] to Catalog. My SURFACE IS: [$($global:PvBuildContext.Surface)]"
		
		$global:PvCatalog.AddFacet($facet);
		Exit-Facet $Name -Verbose:$xVerbose -Debug:$xDebug;
	};
}