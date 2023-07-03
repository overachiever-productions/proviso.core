Set-StrictMode -Version 1.0;

<#

	Import-Module -Name "D:\Dropbox\Repositories\proviso.core" -Force;

	$global:DebugPreference = "Continue";


$global:PretendActualXeSessions = @{
	"BlockedProcesses" = @{
		StartWithOS = $true	
		Enabled = $true
		Definition = "Pretend SQL Would Go Here"
		XelFilePath = "D:\Traces\blocked_processes.xel"
	}
	
	"Long-RunningOperations" = @{
		StartWithOS = $true
		Enabled = $false
		Definition = "Pretend SQL def here too"
		XelFilePath = "G:\Traces\long.xel"
	}
}

	Facets {
		Pattern "My First Pattern" {
			Instances -DefaultInstance "BlockedProcesses" {
				List {
					# pretend this is a func that iterates over all, actual/existing (vs desired or expected) XeSessions on the box:
					#return $global:PretendActualXeSessions.Keys;

					return $null;
				}
				#Define {
				#}
				# Add {}
				# Remove {}
			}
			Properties {
#				Property "something" -Extract 11 -Display "hard-coded 11 thing" {
#				}
#				Property "something else" -Extract 12 {
#				}
				Property "Xe Session Name" -Extract "name goes here" {
				}
				Property "StartsWithOS" -Extract $true {
				}
				Property "Enabled" -Extract $true {
				}
			}
		}
	}

	Read-Facet "My First Pattern";

#>

function Pattern {
	[CmdletBinding()]
	param (
		[Parameter(Mandatory, Position = 0)]
		[string]$Name,
		[Parameter(Mandatory, Position = 1)]
		[ScriptBlock]$PatternBlock,
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
		$currentPattern = New-Object Proviso.Core.Models.Pattern($Name, $Id, ([Proviso.Core.FacetParentType](Get-ParentBlockType)), (Get-ParentBlockName));
		
		Set-Declarations $currentPattern -BlockType ($MyInvocation.MyCommand) -ModelPath $ModelPath -TargetPath $TargetPath `
						 -Impact $Impact -Skip:$Skip -Ignore $Ignore -Expect $Expect -Extract $Extract -NoConfig:$NoConfig `
						 -ThrowOnConfigure $ThrowOnConfigure -Display $Display -Verbose:$xVerbose -Debug:$xDebug;
		
		# BIND:
		switch ((Get-ParentBlockType)) {
			"Facets" {
				Write-Debug "$(Get-DebugIndent)Bypassing Binding of Facet: [$($currentFacet.Name)] to Parent, because Parent is a Facets wrapper.";
			}
			"Surface" {
				Write-Debug "$(Get-DebugIndent)	Binding Facet: [$($currentFacet.Name)] to Surface: [$($currentSurface.Name)].";
				$currentSurface.AddFacet($currentFacet);
			}
			default {
				throw; # TODO: standardize error message here... 
			}
		}
		
		# STORE:
		Add-FacetToBlockStore $currentPattern -AllowReplace (Allow-BlockReplacement) -Verbose:$xVerbose -Debug:$xDebug;
		
		& $PatternBlock;
	};
	
	end {
		Exit-Block $MyInvocation.MyCommand -Name $Name -Verbose:$xVerbose -Debug:$xDebug;
	};
}