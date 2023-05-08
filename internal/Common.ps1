Set-StrictMode -Version 1.0;

# REFACTOR: _MIGHT_ make sense to call this Utility or even Proviso.Core.Utility.ps ... 

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
	
	return (-not ([string]::IsNullOrWhiteSpace($Value)));
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
		
		$verbose = "Configuring $($ObjectType): [$Name] for bypass (-Skip Enabled).";
		
		if (Has-Value $Ignore) {
			$verbose = $verbose.Replace(" -Skip Enabled", " '$Ignore'");
		}
		
		Write-Verbose $verbose;
	}
	
	return $bypass;
}

filter Allow-DefinitionReplacement {
	# TODO: set some sort of global preference or whatever. 
	# 	and, it has to be set to some sort of explicit option like { Yes | No | Time-Based }
	
	# otherwise, use compilation vs 'now' times:
	# TODO: implement time-checks... 
	
	return $false;
}

filter Allow-BlockReplacement {
	# TODO: this is simply a side-by-side func/filter for Allow-DefinitionReplacement.
	# 	i.e., once there's enough of a critical-mass of blocks using THIS func vs the above... delete the above...
	
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

#function Set-Definitions {
#	[CmdletBinding()]
#	param (
#		[Parameter(Mandatory, Position = 0)]
#		[Proviso.Core.IDeclarable]$iDeclarable,
#		[parameter(Mandatory)]
#		[string]$BlockType, 
#		[string]$ModelPath = $null,
#		[string]$TargetPath = $null,
#		[ValidateSet("None", "Low", "Medium", "High")]
#		[string]$Impact = "None",
#		[switch]$Skip = $false,
#		[string]$Ignore = $null,
#		[string]$DisplayFormat = $null,
#		[object]$Expect = $null,
#		[object]$Extract = $null,
#		[string]$ThrowOnConfig = $null
#	);
#
#	if ((Is-Skipped $BlockType -Name $Name -Skip:$Skip -Ignore $Ignore -Verbose:$xVerbose -Debug:$xDebug)) {
#		$iDeclarable.SetSkipped($Ignore);
#	}
#	
#	if (Should-SetPaths $BlockType -Name $Name -ModelPath $ModelPath -TargetPath $TargetPath -Path $Path -Verbose:$xVerbose -Debug:$xDebug) {
#		$ModelPath, $TargetPath = $Path, $Path;
#	}
#	
#	$iDeclarable.SetPaths($ModelPath, $TargetPath);
#	
#	if ($Impact -ne "None") {
#		$iDeclarable.SetImpact(([Proviso.Core.Impact]$Impact));
#	}
#	
#	if ($Expect) {
#		$iDeclarable.SetExpectFromParameter($Expect);
#	}
#	
#	if ($Extract) {
#		$iDeclarable.SetExtractFromParameter($Extract);
#	}
#	
#	if ($ThrowOnConfig) {
#		$iDeclarable.SetThrowOnConfig($ThrowOnConfig);
#	}
#	
#	
#	
#	#$stack = ((Get-PSCallStack).Command -join ",") -replace "Enter-Block,"
#	
#	
#	# TODO: Implement this LATER. I't s a 'nice to have' - not something core/critical.
#	# also... $PSCmdlet.MyInvocation.ScriptName? might be a better way? 
#	# this is ... close. 
#	# 		what I might actually want to do is ... 
#	# 		in Enter-Block... capture the 'current (caller)' script-name/source via this approach (i.e., basically [1] vs [0])
#	# 			and shove it into a variable... 
#	# 			that I can then call via a func in Orthography.ps ... e.g., Get-CurrentBlockDefinitionScriptThingy... 
#	# 		and then call that here... and ... shove it into $iDeclarable.SetSourceMetaDataAndOtherStuff($x, $y, $z-etc)
##	$stack = (Get-PSCallStack).ScriptName -join "`n";
##	
#	
#	# TODO: Comparison... 
#	# TODO: Processing Order? 
#	
#	
#}