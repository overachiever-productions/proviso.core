Set-StrictMode -Version 1.0;

<#

	Import-Module -Name "D:\Dropbox\Repositories\proviso.core" -Force;
	$global:DebugPreference = "Continue";

$global:PretendActualXeSessions = @{
	"MSSQLSERVER" = @{
		"BlockedProcesses" = @{
			Name = "blocked_processes"
			StartWithOS = $true	
			Enabled = $true
			Definition = "Pretend SQL Would Go Here"
			XelFilePath = "D:\Traces\blocked_processes.xel"
		}
		
		"LongRunningOperations" = @{
			Name = "long_running_operations"
			StartWithOS = $true
			Enabled = $false
			Definition = "Pretend SQL def here too"
			XelFilePath = "G:\Traces\long.xel"
		}
	}
	"X3" = @{
		"BlockedProcesses" = @{
			Name = "BlockedProcesses"  
			StartWithOS = $true	
			Enabled = $true
			Definition = "Pretend SQL Would Go Here"
			XelFilePath = "D:\Traces\blocked_processes.xel"
		}
	}
}

# PRETEND FUNCTIONS. (i.e., pretend that these interact with an actual OS and such...)
function Get-PrmInstalledSqlInstances {
	return $global:PretendActualXeSessions.Keys;
}

function Get-PrmXeSessionNamesBySqlInstance {
	param(
		[string]$SqlInstance
	);
	return $global:PretendActualXeSessions[$sqlInstance].Keys;
}

function Get-PrmXeSessionDetailsForSqlInstance {
	param(
		[string]$SqlInstance, 
		[string]$XeSessionName
	); 

	# obviously, the logic for this 'in the real world' would be a bit more complex... 
	return $global:PretendActualXeSessions.$SqlInstance.$XeSessionName;
};

	Facets {
		Pattern "XE Sessions by SQL Instance" {
			Topology {
				Instance "SQLInstances" -DefaultInstance "MSSQLSERVER" {
					List {
						return Get-PrmInstalledSqlInstances;
					}
				}

				Instance "XeSessions" {
					List {
						# NOTE: Because this is the SECOND instance defined, it's a CHILD, and requires that we enumerate values from/for the current PARENT instance:
						$sqlInstance = $PvCurrent.SqlInstances.Name;
						
						return Get-PrmXeSessionNamesBySqlInstance -SqlInstance $sqlInstance;
						# and... note that the above COULD, in theory, be EMPTY. As in, I need to determine how to let 'authors' specify that or not. 
					}
				}
			}
			Properties {
				# TODO: turn this into an inclusion... 
				Property "Exists" -Display "{INSTANCE[SqlInstances].NAME}.{INSTANCE[XeSessions].NAME}.SessionName" {
					Extract {
						$session = Get-PrmXeSessionDetailsForSqlInstance -SqlInstance ($PvCurrent.SqlInstances.Name) -XeSessionName ($PvCurrent.XeSessions.Name);
						return $session.Name;
					}
				}
				Property "StartsWithOS" -Display "{INSTANCE[SqlInstances].NAME}.{INSTANCE[XeSessions].NAME}.{SELF}" {
					Extract {
						$session = Get-PrmXeSessionDetailsForSqlInstance -SqlInstance ($PvCurrent.SqlInstances.Name) -XeSessionName ($PvCurrent.XeSessions.Name);
						return $session.StartWithOS;
					}
				}
				Property "Enabled" -Display "{INSTANCE[SqlInstances].NAME}.{INSTANCE[XeSessions].NAME}.{SELF}"{
					Extract {
						$session = Get-PrmXeSessionDetailsForSqlInstance -SqlInstance ($PvCurrent.SqlInstances.Name) -XeSessionName ($PvCurrent.XeSessions.Name);
						return $session.Enabled;
					}
				}
			}
		}
	}

	Read-Facet "XE Sessions by SQL Instance";

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