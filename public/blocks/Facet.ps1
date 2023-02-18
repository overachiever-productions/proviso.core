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
		[string]$Id = $null,
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
		
		$facetDefinition = New-Object Proviso.Core.Definitions.FacetDefinition($Name, $Id, $ModelPath, $TargetPath, $bypass, $Ignore);
		
		$facetDefinition.SurfaceName = $global:PvLexicon.GetCurrentSurface();
		$facetDefinition.AspectName = $global:PvLexicon.GetCurrentAspect();
		
		if ($Impact -ne "None") {
			$facetDefinition.Impact = [Proviso.Core.Impact]$Impact;
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
		$global:PvCatalog.AddFacetDefinition($facetDefinition);
		Exit-Block $MyInvocation.MyCommand -Name $Name -Verbose:$xVerbose -Debug:$xDebug;
	};
}