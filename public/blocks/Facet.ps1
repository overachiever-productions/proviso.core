Set-StrictMode -Version 1.0;

<#

	Import-Module -Name "D:\Dropbox\Repositories\proviso.core" -Force;

	Get-Command 

	$global:DebugPreference = "Continue";
	$global:VerbosePreference = "Continue";

#	Surface "Bigly" {
#		Facet "Child" {}
#	}

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
			Cohort "Test Cohort" {
				Enumerate {
				}
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

# REFACTOR: I can 'collapse' Surface, Aspect, Facet, etc... down to a single set of classes/bases by ... 
# 		keeping existing signatures... (params/etc. )
# 		extract $MyInvocation.MyCommand as a 'name'/type 
# 		calling into a literal, say, Block {} function (e.g., function CoreBlock { params() shared-logic-here )
# 	that'll reduce a huge amount of DRY
# 		the only real concern would be ... $definition.XyzName attributes - but I think i can 'switch' on those... 
# 		er, well... and the $defintion = new-object xyz code... 
# 			still... using 'funcs' as private helpers is a good way to reduce DRY.
# 
# 		ALSO: probably makes sense to call my 'shared blocks' (i.e., I'll have 'coreblock' for all shared things, Enumerate/Enumerator, and Iterate/Iterator blocks)
# 				something like <type>Base.ps1
# 					and keep them in the PUBLIC folder. 
# 					and, simply just EXCLUDE anything like *Base.p1 from being 'emitted' or exported as a PUBLIC func... 
# 				then again, i could put these 'base' blocks 'down' in the /internal/ folder too.. 
# 					the CONCERN is what putting these 'base' blocks in /internal/ would do to TESTING.
# 		SEE notes below... in start of Process {} block

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
		# REFACTOR: remove $bypass & path logic from .ctor of ALL .definition objects. 
		# 		then, put logic to test + set below the $definition = new-object xxx  call... 
		# 		THEN, i can put everything in the 'process' command into a helper func that ... does bypass, path assignment, impact, expect, extract, throw on config... 
		$bypass = Is-ByPassed $MyInvocation.MyCommand.Name -Name $Name -Skip:$Skip -Ignore $Ignore -Verbose:$xVerbose -Debug:$xDebug;
		
		if (Should-SetPaths $MyInvocation.MyCommand.Name -Name $Name -ModelPath $ModelPath -TargetPath $TargetPath -Path $Path -Verbose:$xVerbose -Debug:$xDebug) {
			$ModelPath, $TargetPath = $Path;
		}
		
		$definition = New-Object Proviso.Core.Definitions.FacetDefinition($Name, $Id, $ModelPath, $TargetPath, $bypass, $Ignore);
		
		$definition.SurfaceName = $global:PvLexicon.GetCurrentSurface();
		$definition.AspectName = $global:PvLexicon.GetCurrentAspect();
		
		if ($Impact -ne "None") {
			$definition.Impact = [Proviso.Core.Impact]$Impact;
		}
		
		if ($Expect) {
			$definition.SetExpectFromParameter($Expect);
		}
		
		if ($Extract) {
			$definition.SetExtractFromParameter($Extract);
		}
		
		if ($ThrowOnConfig) {
			$definition.SetThrowOnConfig($ThrowOnConfig);
		}
		
		& $ScriptBlock;
	};
	
	end {
		try {
			$global:PvCatalog.AddFacetDefinition($definition);
		}
		catch {
			throw "$($_.Exception.InnerException.Message) `r`t$($_.ScriptStackTrace) ";
		}
		
		Exit-Block $MyInvocation.MyCommand -Name $Name -Verbose:$xVerbose -Debug:$xDebug;
	};
}