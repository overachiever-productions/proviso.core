Set-StrictMode -Version 1.0;

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
	
	# TODO: add a 'Verboser' object that is, effectively, an IDENTITY/SEQUENCE - calling it increments. 
	# 		and ... with that, verbose will prefix all calls with # ... as in: 
	# 		0001. Starting up blah blah blah
	# 		0002. doing yada yada
	# 		0003. Compiling xyz... 
	
	
	# ACTUALLY. Might make this public?
	
	# spits stuff out to the console if -Verbose
	# always spits stuff out to the PvLog. 	
}

filter Is-Empty {
	param (
		[Parameter(Position = 0)]
		[string]$Value
	);
	
	return [string]::IsNullOrWhiteSpace($Value);
}

filter Has-Value {
	param (
		[Parameter(Position = 0)]
		[string]$Value
	);
	
	return (-not ([string]::IsNullOrEmpty($Value)));
}

filter Has-ArrayValue {
	param (
		[Parameter(Position = 0)]
		[string[]]$Value		# NOTE: any STRING passed in will... be converted to @("string") 
	)
	
	if ($null -eq $Value) {
		return $false;
	}
	
	foreach ($s in $Value) {
		if (Has-Value $s) {
			return $true;
		}		
	}
	
	return $false
}

filter Collapse-Arguments {
	param (
		[object]$Arg1,
		[object]$Arg2,
		[switch]$IgnoreEmptyStrings = $false # need to determine IF "" should be output when found... 
	);
	
	if ($Arg1) {
		return $Arg1;
	}
	elseif (-not $IgnoreEmptyStrings) {
		if ((Is-Empty $Arg1)) {
			return $Arg1;
		}
	}
	
	return $Arg2;
}

function Is-Skipped {
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

filter Allow-DefinitionReplacement {
	# TODO: set some sort of global preference or whatever. 
	# 	and, it has to be set to some sort of explicit option like { Yes | No | Time-Based }
	
	# otherwise, use compilation vs 'now' times:
	# TODO: implement time-checks... 
	
	return $false;
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

function Set-Definitions {
	[CmdletBinding()]
	param (
		[Parameter(Mandatory, Position = 0)]
		[Proviso.Core.Definitions.IDefinable]$iDefinable,
		[parameter(Mandatory)]
		[string]$BlockType, 
		[string]$ModelPath = $null,
		[string]$TargetPath = $null,
		[ValidateSet("None", "Low", "Medium", "High")]
		[string]$Impact = "None",
		[switch]$Skip = $false,
		[string]$Ignore = $null,
		[string]$DisplayFormat = $null,
		[object]$Expect = $null,
		[object]$Extract = $null,
		[string]$ThrowOnConfig = $null
	);
	
	if ((Is-Skipped $BlockType -Name $Name -Skip:$Skip -Ignore $Ignore -Verbose:$xVerbose -Debug:$xDebug)) {
		$iDefinable.SetSkipped($Ignore);
	}
	
	if (Should-SetPaths $BlockType -Name $Name -ModelPath $ModelPath -TargetPath $TargetPath -Path $Path -Verbose:$xVerbose -Debug:$xDebug) {
		$ModelPath, $TargetPath = $Path;
	}
	
	$iDefinable.SetPaths($ModelPath, $TargetPath);
	
	if ($Impact -ne "None") {
		$iDefinable.SetImpact(([Proviso.Core.Impact]$Impact));
	}
	
	if ($Expect) {
		$iDefinable.SetExpectFromParameter($Expect);
	}
	
	if ($Extract) {
		$iDefinable.SetExtractFromParameter($Extract);
	}
	
	if ($ThrowOnConfig) {
		$iDefinable.SetThrowOnConfig($ThrowOnConfig);
	}
	
	# TODO: Comparison... 
	# TODO: Processing Order? 
	
}