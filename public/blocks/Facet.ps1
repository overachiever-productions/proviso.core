Set-StrictMode -Version 1.0;

<# 
	PSEUDO SIGNATURES 

#	Surface "Firewall Rules" {
#		Facet "SQL Server Ports" {
#			Property "SQL Server" {	}
#			Property "SQL Server - DAC" {}
#			Property "SQL Server - Mirroring" { }
#			Cohort "Test Cohort" {
#				List {
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
		[string]$Display = $null,
		[object]$Expect = $null,
		[object]$Extract = $null,
		[Alias('PreventConfig', 'PreventConfiguration', 'DisableConfig')]
		[switch]$NoConfig = $false,
		[Alias('ThrowOnConfig', 'ThrowOnConfiguration')]
		[string]$ThrowOnConfigure = $null
	);
	
	begin {
		[bool]$xVerbose = ("Continue" -eq $global:VerbosePreference) -or ($PSBoundParameters["Verbose"] -eq $true);
		[bool]$xDebug = ("Continue" -eq $global:DebugPreference) -or ($PSBoundParameters["Debug"] -eq $true);
		
		Enter-Block ($MyInvocation.MyCommand) -Name $Name -Verbose:$xVerbose -Debug:$xDebug;
	};
	
	process {
		$currentFacet = New-Object Proviso.Core.Models.Facet($Name, $Id, ([Proviso.Core.FacetParentType](Get-ParentBlockType)), (Get-ParentBlockName));
		
		Set-Declarations $currentFacet -BlockType ($MyInvocation.MyCommand) -ModelPath $ModelPath -TargetPath $TargetPath `
						 -Impact $Impact -Skip:$Skip -Ignore $Ignore -Expect $Expect -Extract $Extract -NoConfig:$NoConfig `
						 -ThrowOnConfigure $ThrowOnConfigure -Display $Display -Verbose:$xVerbose -Debug:$xDebug;
		
		# BIND:
		switch ((Get-ParentBlockType)) {
			"Facets" {
				Write-Debug "$(Get-DebugIndent)Bypassing Binding of Facet: [$($currentFacet.Name)] to Parent, because Parent is a Facets wrapper.";
			}
#			"Aspect" {
#				Write-Debug "$(Get-DebugIndent) Binding Facet: [$($currentFacet.Name)] to Aspect: [$($currentAspect.Name)].";
#				$currentAspect.AddFacet($currentFacet);
#			}
			"Surface" {
				Write-Debug "$(Get-DebugIndent)	Binding Facet: [$($currentFacet.Name)] to Surface: [$($currentSurface.Name)].";
				$currentSurface.AddFacet($currentFacet);
			}
			default {
				throw;
			}
		}
		
		# STORE: 
		Add-FacetToBlockStore $currentFacet -AllowReplace (Allow-BlockReplacement) -Verbose:$xVerbose -Debug:$xDebug;
		
		& $FacetBlock;
	};
	
	end {
		Exit-Block $MyInvocation.MyCommand -Name $Name -Verbose:$xVerbose -Debug:$xDebug;
	};
}