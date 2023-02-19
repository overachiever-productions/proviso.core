﻿Set-StrictMode -Version 1.0;

function Write-PvDebug {
	[CmdletBinding()]
	param (
		[string]$Message #,
		#[switch]$Debug
	);
	
	# ACTUALLY. Might make this public?
	
	# spits stuff out to the console if -Debug
	# always spits stuff out to the PvLog. 
	
}

function Write-PvVerbose {
	[CmdletBinding()]
	param (
		[string]$Message #,
		#[switch]$Verbose
	);
	
	# ACTUALLY. Might make this public?
	
	# spits stuff out to the console if -Verbose
	# always spits stuff out to the PvLog. 	
}

filter Has-Value {
	param (
		[Parameter(Position = 0)]
		[string]$Value
	);
	
	return (-not ([string]::IsNullOrEmpty($Value)));
}

filter Is-Empty {
	param (
		[Parameter(Position = 0)]
		[string]$Value
	);
	
	return [string]::IsNullOrWhiteSpace($Value);
}

function Is-ByPassed {
	[CmdletBinding()]
	param (
		[Parameter(Mandatory, Position = 0)]
		[string]$ObjectType,
		[string]$Name,
		[switch]$Skip,
		[string]$Ignore
	);
	
	$bypass = $false;
	if ($Skip -or (Has-Value $Ignore)) {
		$bypass = $true;
		
		$verbose = "Bypassing $($ObjectType): [$Name]. Reason: -Skip Enabled.";
		
		if (Has-Value $Ignore) {
			$verbose = $verbose.Replace(" -Skip Enabled", " '$Ignore'");
		}
		
		Write-Verbose $verbose;
	}
}

function Should-SetPaths {
	[CmdletBinding()]
	param (
		[Parameter(Mandatory, Position = 0)]
		[string]$ObjectType,
		[string]$Name,
		[string]$ModelPath,
		[string]$TargetPath,
		[string]$Path
	);
	
	if (Has-Value $Path) {
		if ((Has-Value $ModelPath) -or (Has-Value $TargetPath)) {
			throw "Invalid $($ObjectType): [$Name]. -Path can only be used when both -ModelPath and -TargetPath are empty.";
		}
		
		return $true;
	}
	
	return $false;
}

filter Allow-DefinitionReplacement {
	# TODO: set some sort of global preference or whatever. 
	# 	and, it has to be set to some sort of explicit option like { Yes | No | Time-Based }
	
	# otherwise, use compilation vs 'now' times:
	# TODO: implement time-checks... 
	
	return $false;
}