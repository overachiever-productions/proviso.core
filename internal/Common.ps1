Set-StrictMode -Version 1.0;

# REFACTOR: _MIGHT_ make sense to call this Utility or even Proviso.Core.Utility.ps ... 
# 		though, since writing the above, I've added a  new Utilities.cs / ps1 file... but, still, I could 'lump' THESE funcs in with those... 

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
			$verbose = $verbose.Replace(" -Skip Enabled", "'$Ignore'");
		}
		
		Write-Verbose $verbose;
	}
	
	return $bypass;
}

function Throws-OnConfig {
	[CmdletBinding()]
	param (
		[Parameter(Mandatory, Position = 0)]
		[string]$ObjectType,
		[string]$Name,
		[switch]$NoConfig,
		[string]$ThrowOnConfigure
	);
	
	$throws = $false;
	if ($NoConfig -or (Has-Value $ThrowOnConfigure)) {
		$throws = $true;
		
		$verbose = "Configuring $(): [$Name] to Throw on attempt to use Configure (-NoConfig Enabled).";
		
		if (Has-Value $ThrowOnConfigure) {
			$verbose = $verbose.Replace("-NoConfig Enabled", "'$ThrowOnConfigure'");
		}
		
		Write-Verbose $verbose;
	}
	
	return $throws;
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

filter Inherit {
	param (
		$Parent,
		$Child,
		$Property
	);
	
	if (Has-Value $Parent.$Property) {
		if (Is-Empty $Child.$Property) {
			$Child.$Property = $Parent.$Property;
		}
	}
}

filter Override-Impact {
	param (
		$Parent,
		$Child
	);
	
	if ($Parent -is [Proviso.Core.IPotent]) {
		if ("None" -ne $Parent.Impact) {
			if ("None" -eq $Child.Impact) {
				$Child.Impact = $Parent.Impact; # er, well... is this correct? 2 ways to look at this... a) if facet has a 'higher' impact than a child, it should override? or b) if there's an EXPLICIT "low" prop for a facet with "high"... then, we have to assume that the prop and facet are both correct (vs thinking that prop now becomes "High", right?)
			}
		}
	}
}

filter Override-Skip {
	param (
		$Parent,
		$Child
	);
	
	if ($Parent.Skip) {
		$Child.Skip = $true;
		$Child.SkipReason = $Parent.SkipReason;
	}
}

filter Override-ThrowOnConfig {
	param (
		$Parent,
		$Child
	);
	
	if ($Parent -is [Proviso.Core.IPotent]) {
		if ($Parent.ThrowOnConfig) {
			$Child.SetThrowOnConfig($Parent.MessageToThrow);
		}
	}
}

filter Extract-ValueFromObjectByPath {
	param (
		[Parameter(Mandatory)]
		[Object]$Object,
		[Parameter(Mandatory)]
		[string]$Path
	);
	
	$keys = $Path -split "\.";
	$output = $null;
	# this isn't SUPER elegant ... but it works (and perf is not an issue).
	switch ($keys.Count) {
		1 {
			$output = $Object.($keys[0]);
		}
		2 {
			$output = $Object.($keys[0]).($keys[1]);
		}
		3 {
			$output = $Object.($keys[0]).($keys[1]).($keys[2]);
		}
		4 {
			$output = $Object.($keys[0]).($keys[1]).($keys[2]).($keys[3]);
		}
		5 {
			$output = $Object.($keys[0]).($keys[1]).($keys[2]).($keys[3]).($keys[4]);
		}
		6 {
			$output = $Object.($keys[0]).($keys[1]).($keys[2]).($keys[3]).($keys[4]).($keys[5]);
		}
		7 {
			$output = $Object.($keys[0]).($keys[1]).($keys[2]).($keys[3]).($keys[4]).($keys[5]).($keys[6]);
		}
		8 {
			$output = $Object.($keys[0]).($keys[1]).($keys[2]).($keys[3]).($keys[4]).($keys[5]).($keys[6]).($keys[7]);
		}
		9 {
			$output = $Object.($keys[0]).($keys[1]).($keys[2]).($keys[3]).($keys[4]).($keys[5]).($keys[6]).($keys[7]).($keys[8]);
		}
		10 {
			$output = $Object.($keys[0]).($keys[1]).($keys[2]).($keys[3]).($keys[4]).($keys[5]).($keys[6]).($keys[7]).($keys[8]).($keys[9]);
		}
		default {
			throw "Invalid Key. Too many key segments defined.";
		}
	}
	
	return $output;
}

filter Object-SupportsPropertyAtPathLevel {
	param (
		[Parameter(Mandatory)]
		[Object]$Object,
		[Parameter(Mandatory)]
		[string]$Path
	);
	
	# as with Extract-ValueFromObjectByPath, this isn't very elegant ... but it works and it's fine/fast.... 	
	
	$keys = $Path -split "\.";
	$property = $keys[$keys.Count - 1];
	try {
		switch ($keys.Count) {
			1 {
				return $Object.PSObject.Properties -contains $property;
			}
			2 {
				$child = $Object.($keys[0]);
			}
			3 {
				$child = $Object.($keys[0]).($keys[1]);
			}
			4 {
				$child = $Object.($keys[0]).($keys[1]).($keys[2]);
			}
			5 {
				$child = $Object.($keys[0]).($keys[1]).($keys[2]).($keys[3]);
			}
			6 {
				$child = $Object.($keys[0]).($keys[1]).($keys[2]).($keys[3]).($keys[4]);
			}
			7 {
				$child = $Object.($keys[0]).($keys[1]).($keys[2]).($keys[3]).($keys[4]).($keys[5]);
			}
			8 {
				$child = $Object.($keys[0]).($keys[1]).($keys[2]).($keys[3]).($keys[4]).($keys[5]).($keys[6]);
			}
			9 {
				$child = $Object.($keys[0]).($keys[1]).($keys[2]).($keys[3]).($keys[4]).($keys[5]).($keys[6]).($keys[7]);
			}
			10 {
				$child = $Object.($keys[0]).($keys[1]).($keys[2]).($keys[3]).($keys[4]).($keys[5]).($keys[6]).($keys[7]).($keys[8]);
			}
			default {
				throw "Cannot process object support for path: [$Path]. Too many key segments defined.";
			}
		}
		
		return $child.PSObject.Properties.Name -contains $property;
	}
	catch {
		return $false;
	}
}