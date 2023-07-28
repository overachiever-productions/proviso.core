<#

	THIS is NOT a set of Unit/Integration Tests. 

	Instead, this is a number of 'tests' I can run manually to validate expectations via various scenarios. 

	It's gedanken meets implementation. 
		Eventually, I'll probably spin this up as a full-blown, additional/external (stand-alone-ish) 'project' or module (or set of scripts).
		Cuz... seriously, this'll be GREAT by way of documentation... so... maybe it'll be Proviso.Core.Scenarios/Examples or something?
				or ... Proviso.Core Examples... or whatever.


#>


<#

	SCENARIO: Minimally Viable-ISH Facets 
		VERB: READ
			- This is really just a 'wrapper' to allow Proviso.Core framework functionality to execute against 
				nothing more, really, than just a placeholder-ish/MVP Facet... 

---------------------------------------------------------------------------------------------------------------------
	
	Import-Module -Name "D:\Dropbox\Repositories\proviso.core" -Force;
$global:DebugPreference = "Continue";
	
	Facets {
		Facet "Implicit Facet - Execution A" -Display "35-Test" -Extract 35 {}
	} 

	Read-Facet "Implicit Facet - Execution A";

	write-host "-----------------------------------"

	$facet = Get-Facet -Name "Implicit Facet - Execution A";

	$facet.Display;
	$facet.Properties[0].Display;

#>

<#

	SCENARIO: Extended Event Sessions by SQL Server Instance
		VERB: READ
			- Here I'm pretending that I've got N SQL Server Instances, and that, for each, I want to iterate
				over each of their currently defined/extant XEs. 
			- The expectation is that nothing will THROW errors for, say, the X9 instance, which has NO XEs extant.
			- Test Coverage... the expectations above are MOSTLY 'covered' ... not great ... but covered-ish. 
			

		VERB: TEST
			- Obviously, the ... behavior needs to change... but I'm not 100% sure ... how... 

---------------------------------------------------------------------------------------------------------------------

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
	"X9" = @{
		# what happens when there's NOTHING for a given instance? (i.e., we're 2x levels into this - there IS an "X9" instance... but no extant XEs...
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
#				Collection {
#				}
			}
		}
	}

	Read-Facet "XE Sessions by SQL Instance";


#>

<#

	SCENARIO: Members of the Local Administrators Group... 
		VERB: READ
			- Here I'm pretending to iterate over the members of the LocalAdmins group and ... querying local/on-box users. 
			- 
			- Test Coverage: This is fairly well covered (for READs). 




---------------------------------------------------------------------------------------------------------------------

	Import-Module -Name "D:\Dropbox\Repositories\proviso.core" -Force;

	#$global:DebugPreference = "Continue";

$global:LocalUsers = @("Administrator", "Mike");
$global:LocalAdmins = @("Administrator", "BUILTIN\Admins");
	
#PRETEND FUNCTIONS: 
function Get-PrmLocalAdministrators {
	return $global:LocalUsers;
}

function Get-PrmUserExistsLocally {
	param(
		[string]$User
	);

	return $global:LocalUsers -contains $User;
}

function Get-PrmIsUserMemberOfLocalAdmins {
	param(
		[string]$User
	);

	return $global:LocalAdmins -contains $User;
}

	Facets {
		Facet "Local Administrators" {
			Collection -ModelPath "Host.LocalAdministrators" {
				Membership -Strict {
					List {
						return Get-PrmLocalAdministrators;					
					} 
#					Add {
#						# 2 steps. 1) create the user if not-exists... and 2) add to local admins.
#					}
				}
				Members {
					Property "Account Exists" -Expect $true {
						Extract {
							$target = $PVCurrent.Collection.CurrentMember;

							return Get-PrmUserExistsLocally -User $target;
						}
					}
					
					# TODO: create a unit test for this: Property "IsLocalAdmin" -Expect $true -Display "{{{COLLECTION.MEMBER}.{SELF}}}" {
					Property "IsLocalAdmin" -Expect $true -Display "{COLLECTION.MEMBER}.{SELF}" {
						Extract {
							$target = $PVCurrent.Collection.CurrentMember;
							
							return Get-PrmIsUserMemberOfLocalAdmins -User $target;
						}
					}
				}
			}
		}
	}

$global:DebugPreference = "Continue";
	Read-Facet "Local Administrators";

#>

<#

	SCENARIO: Multiple Inputs
		VERB: READ 
			- Expectations: 
				- There are 2x ways to 'iterate over' a complex property/collection like $targetObjects... 
				a) single-call to Read-Facet ... and pass in $targetObjects as the -Target 
						at which point, Proviso.Core SHOULD figure out that -Target is an array/collection and ... run a single
						operation per EACH entry in -Target. 
				b) inline - i.e., $targetObjects | Read-Facet ... 
						which is much more PowerShell-y ... 
						but, Proviso.Core SHOULD be able to determine that we're iterating over a collection of values 
						and, make a distinct call for EACH of them. 

			- Translation (of expectations):
				- Whether using option a or b from above, 
					- against $targetObjects 
					- we SHOULD see 
						1) 3x entries (1 per each collection member)
						2) the exact same behavior from one call/approach to the other (i.e., a) or b) should be identical - just a question of style/preference by users or callers). 

---------------------------------------------------------------------------------------------------------------------
	
	Import-Module -Name "D:\Dropbox\Repositories\proviso.core" -Force;
#$global:DebugPreference = "Continue";

# Spin up a 'target' with > 1x property... 
$targetObjects = @(
	[PSCustomObject]@{ ObjectName = "Object 1" }
	[PSCustomObject]@{ ObjectName = "Object 2" }
	[PSCustomObject]@{ ObjectName = "Object 3" }
);	

	Facets {
		Facet "Facet with Target Paths" -TargetPath "ObjectName" {
		}
	}

	# Single-Call Execution:
	Read-Facet "Facet with Target Paths" -Target $targetObjects;

Write-Host "-------------------------------------------------";

	# INLINE execution: 
	$targetObjects | Read-Facet "Facet with Target Paths";


#>

<# 
	
	SCENARIO: Multi-Server Execution 
		VERB: READ 
			- Expectations 
				- The Facet in question, "Passthrough" , is nothing more than ... a wrapper/Minimally viable facet
					that gives us the option to parrot/echo out whatever is sent in as the -Target. 

				- Because there are 2x servers ... 
					- Read-Facet should execute 2x times - once per each server. 
					- The 'Actual' value will be the same, canned, -Target data for each server... 
						but, the goal/expectation is that we ran the code in question 1x per EACH server. 
	
---------------------------------------------------------------------------------------------------------------------
	
	Import-Module -Name "D:\Dropbox\Repositories\proviso.core" -Force;
#$global:DebugPreference = "Continue";

	$servers = @("SQL-150-01", "SQL-150-02");

	Facets {
		Facet "Passthrough" { } 
	}

	Read-Facet "Passthrough" -Target "Canned Input" -Servers $servers;

#> 