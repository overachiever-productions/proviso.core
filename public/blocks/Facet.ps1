﻿Set-StrictMode -Version 1.0;

<#

	Import-Module -Name "D:\Dropbox\Repositories\proviso.core" -Force;

	$global:DebugPreference = "Continue";
	$global:VerbosePreference = "Continue";

#	Surface "Bigly" {
#		Facet "Child" {}
#	}

#	Facet "Host Ports" {
#		Property "ICMP" {
#		}
#		Property "RDP" {
#		}
#	}
#
#	Surface "Firewall Rules" {
#		Facet "SQL Server Ports" {
#			Property "SQL Server" {
#			}
#			Property "SQL Server - DAC" {
#			}
#			Property "SQL Server - Mirroring" { 
#			}
#			Cohort "Test Cohort" {
#				Enumerate {
#				}
#			}
#		}
#
#		Import -Facet "Host Ports";
#	}
#
#	Read-Facet "SQL Server Ports";
#	Read-Facet "Host Ports";

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
		[ScriptBlock]$FacetBlock,
		[string]$Id = $null,
		[string]$ModelPath = $null,
		[string]$TargetPath = $null,
		[string]$Path = $null,
		[ValidateSet("None", "Low", "Medium", "High")]
		[string]$Impact = "None",
		[switch]$Skip = $false,
		[string]$Ignore = $null,
		[string]$DisplayFormat = $null,
		[object]$Expect = $null,
		[object]$Extract = $null,
		[string]$ThrowOnConfig = $null
	);
	
	begin {
		$currentFacetType = "Facet";
		[bool]$xVerbose = ("Continue" -eq $global:VerbosePreference) -or ($PSBoundParameters["Verbose"] -eq $true);
		[bool]$xDebug = ("Continue" -eq $global:DebugPreference) -or ($PSBoundParameters["Debug"] -eq $true);
		
		Enter-Block ($MyInvocation.MyCommand) -Name $Name -Verbose:$xVerbose -Debug:$xDebug;
	};
	
	process {
		$parentName = $global:PvOrthography.GetParentBlockName();

		[Proviso.Core.FacetParentType]$parentType = Get-FacetParentType;
		$definition = New-Object Proviso.Core.Definitions.FacetDefinition($Name, $Id, [Proviso.Core.FacetType]"Scalar", $parentType, $parentName);
		
		Set-Definitions $definition -BlockType ($MyInvocation.MyCommand) -ModelPath $ModelPath -TargetPath $TargetPath `
						-Impact $Impact -Skip:$Skip -Ignore $Ignore -Expect $Expect -Extract $Extract -ThrowOnConfig $ThrowOnConfig `
						-DisplayFormat $DisplayFormat -Verbose:$xVerbose -Debug:$xDebug;
		
		$currentFacet = $definition;
		
		# BIND:
		Bind-Facet -Facet $definition -Verbose:$xVerbose -Debug:$xDebug;
		
		# STORE: 
		if ($global:PvOrthography.StoreFacetDefinition($definition, (Allow-DefinitionReplacement))) {
			Write-Verbose "Facet: [$Name] was replaced.";
		}
		
		& $FacetBlock;
	};
	
	end {
		Exit-Block $MyInvocation.MyCommand -Name $Name -Verbose:$xVerbose -Debug:$xDebug;
	};
}