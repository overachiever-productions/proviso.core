Set-StrictMode -Version 1.0;

$global:PvUtility = [Proviso.Core.Utilities]::Instance;

<#
	PICKUP/NEXT:
		- Remote Sessions pass OBJECTS back and forth as PSCustomObject - with ONLY data, NO METHODS. 
		- So, I'm getting a 'FacetReadResult' back... only, it's SANS functions/methods (i.e., JUST raw data). 

		- Ultimately, this means I have, roughly, 3 options for handling remoting operations: 
			1. try converting the PSObject we get back from the remote session BACK into something 'native' (c#). 
				e.g., assume a FacetReadResults() .ctor for my c# object that takes in a PSObject. 
					I've started this - and, it actually is aboutr 90% of the way there. 
					I just need to figure out what working with CHILD objects is going to look like... 
						i.e., how do i deserialize PropertyReadResults and their underlying ExtractResults and on and on. 

			2. I COULD use JSON. 
				I've started this. 
					System.Text.Json is pretty heavily baked into the CLR ... such that I can get access to it natively from 
					within PowerShell via `using namespace System.Text.Json'` and... it's there. 
					OR, i can throw a using System.Text.Json right into my c# code and ... get the current version during build/compilation. 
				The RUB is I can't quite seem to figure out the right args for .Serialize()... 
					but, that's a problem from within PowerShell... 
						MAYBE I could create a translator/factory-ish method in C# where I passed in a PSObject and
							1. had it cast stuff to JSON (i.e., .Serialize<x>(etc)). 
							2. use the output of the above and route it into .Deserialize<x>(json);
							3. map properties back and forth as needed.
				ANOTHER rub here, too, is that I THINK that JSON deserialization requires public .ctors and/or public methods and stuff? 
					so, this is something to look into. 

			3. The option I'll probably go with: 
				a. for EVERY THING that needs to be serialized/deserialized (i.e., facets, surfaces, runbooks? (seriously, not sure I want to 'go there' with all of these)
					and 'Read|Test|Invoke Results' ... 
						use an 'internal' data-object or, basically, DTO/sub/core class with state. 
				b. each of these 'objects' is then an internal data-objects + bridge/facet-for-funcs. 
					Or, more specifically, a FacetReadResult is, currently: 
						- a 'union' of props and functions. where Posh Remoting only 'preserves' the props and drops the funcs. 
				    Whereas, what I will probably have will be: 
						- a FacetReadResultData class/object. 
						- a FacetReadResult object that has methods - which 'proxy' or 'relay' data from the FacetReadResultData object. 		
						- 2 ctors for the FacetReadResult
							- i. One that spins up a new FacetReadResultData object and spams in details as needed. 
							- ii. one that can take in a FacetReadResultsData object (from serialization or otherwise). 
								OR, hell: a variant that takes in JSON or XML or whatever... 


	JSON Serialization: 
		- Some decent examples: 
			- https://dexterposh.github.io/posts/010-dotnet-pwsh-json/ 

		- C# Documentation: 
			- https://learn.microsoft.com/en-us/dotnet/standard/serialization/system-text-json/how-to?pivots=dotnet-8-0	

		- Some other fodder: 
			- https://stackoverflow.com/questions/58141125/understanding-newtonsoft-in-powershell 

		NOTE about PowerShell 7.1+ 
			- As of 7.1+, you can no longer use a single object SANS entire namespace reference
				e.g., can't use [JsonSerializer]. have to use: [System.Text.Json.JsonSerializer] instead. 
				Source:
					- https://stackoverflow.com/questions/65645394/what-is-the-scope-of-using-namespace-in-powershell 
			



#>



<#

	Import-Module -Name "D:\Dropbox\Repositories\proviso.core" -Force;
$global:DebugPreference = "Continue";

	write-host "Make sure SQL-160.01.sqlserver.id is up/running/etc.";

	$cred = Get-Credential -UserName "Administrator";
	$conn = Register-RemoteSession -ServerName "sql-160-01.sqlserver.id" -Credential $cred;
	if($conn.Connected) {
		$session = $conn.Session;
		
		# establish a remote (faked) Facet:
		$payloadBlock = { Facets { Facet "Implicit Facet - Execution A" -Display "35-Test" -Extract 35 {} } }
		Invoke-Command -Session $session -ScriptBlock $payloadBlock;

		$results = Invoke-Command -Session $session -ScriptBlock { Read-Facet "Implicit Facet - Execution A"; };

		$results | ConvertTo-Xml -As Stream;
	write-host "-----------------------";
		$results.PropertyReadResults[0] | ConvertTo-Xml -As Stream;

	}
	else {
		Write-Host "Failed To Connect. Error: $($conn.ErrorText)";
	}

write-host "--0000000000000000000000000000000000000";

	Facets { Facet "Implicit Facet - Execution A" -Display "35-Test" -Extract 35 {} }
	$results = Read-Facet "Implicit Facet - Execution A";

	$results | ConvertTo-Xml -As Stream; 
write-host "-----------------------";
	$results.PropertyReadResults[0] | ConvertTo-Xml -As Stream;	


#>

function Register-RemoteSession {
	[CmdletBinding()]
	param (
		[Parameter(Mandatory)]
		[string]$ServerName = $null,
		[PSCredential]$Credential
	);
	
	begin {
		$result = @{
			Session   = $null
			PowerShellVersion = $null
			ProvisoVersion = $null
			Configuration = $null
			ErrorText = $null
			Connected = $false
		};
		
		# NOTE: try/catch is DESIGNED to not work here: https://serverfault.com/questions/551247/testing-if-enter-pssession-is-successful
		$connectionError = $null;
		if ($null -eq $Credential) {
			$testSession = New-PSSession -ComputerName $ServerName -ErrorAction SilentlyContinue -ErrorVariable connectionError;
		}
		else {
			$testSession = New-PSSession -ComputerName $ServerName -Credential $Credential -ErrorAction SilentlyContinue -ErrorVariable connectionError;
		}
		
		# TODO: look for common-ish error types (bad password or ... no kerberos, etc.) and try to intercept/help
		if (-not($testSession)) {
			$result.ErrorText = $connectionError;
			return;
		}
		
		$version = Invoke-Command -Session $testSession -ScriptBlock {
			$PSVersionTable.PSVersion.ToString();
		};
		
		$result.PowerShellVersion = $version;
		
		$sessions = Invoke-Command -Session $testSession -ScriptBlock {
			Get-PSSessionConfiguration | Select-Object "Name", "PSVersion";
		}
		
		if ($sessions) {
			$target = $sessions | Where-Object -Property "Name" -EQ "PowerShell.7";
			
			if ($target) {
				$result.PowerShellVersion = $target.PSVersion;
				$result.Configuration = $target.Name;
				
				if ($null -eq $Credential) {
					$targetSession = New-PSSession -ComputerName $ServerName -ConfigurationName ($result.Configuration) -ErrorAction SilentlyContinue -ErrorVariable connectionError;
				}
				else {
					$targetSession = New-PSSession -ComputerName $ServerName -ConfigurationName ($result.Configuration) -Credential $Credential -ErrorAction SilentlyContinue -ErrorVariable connectionError;
				}
				
				if (-not ($targetSession)) {
					$result.ErrorText = $connectionError;
				}
			}
		}
	};
	
	process {
		if ($testSession) {
			if ($targetSession) {
				$moduleError = $null;
				
				Invoke-Command -Session $targetSession -ErrorAction SilentlyContinue -ErrorVariable moduleError -ScriptBlock {
					Import-Module -Name "proviso.core" -Force -DisableNameChecking;
				};
				
				if ($moduleError) {
					$result.ErrorText = $moduleError;
				}
				else {
					$moduleVersion = Invoke-Command -Session $targetSession -ScriptBlock {
						Get-Module -Name "proviso.core" | Select-Object "Version";
					};
					
					$result.ProvisoVersion = $moduleVersion.Version;
					
					$localProvisoVersion = $MyInvocation.MyCommand.ScriptBlock.Module.Version;
					
					# NOTE: this -eq comparison is against .Version objects... it'll fail if one of the sides is a 'string'.
					if ($result.ProvisoVersion -eq $localProvisoVersion) {
						$result.Connected = $true;
						$result.Session = $targetSession;
					}
					else {
						# TODO: need to look at what kinds of version differences can/will be allowed. 
						$result.ErrorText = "Remote and Local Versions of proviso.core are NOT identical. Local: [$localProvisoVersion] -> Remote: [$($result.ProvisoVersion)].";
					}
				}
			}
			else {
				if ($null -eq $result.ErrorText) {
					$result.ErrorText = "Proviso Remoting Failure. Expected Error or Remote Connection to PowerShell 7.2. Got NEITHER.";
				}
			}
		}
		else {
			if ($null -eq $result.ErrorText) {
				$result.ErrorText = "Proviso Remoting Failure. Expected Error or Remote Connection to Default PowerShell Configuration. Got NEITHER.";
			}
		}
	};
	
	end {
		return $result;
	};
}