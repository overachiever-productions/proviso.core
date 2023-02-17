Set-StrictMode -Version 1.0;

function FacetPattern {
	[CmdletBinding()]
	[Alias("Pattern")]
	param (
		[Parameter(Mandatory, Position = 0)]
		[string]$Name,
		[string]$ModelPath = $null,
		[string]$TargetPath = $null,
		[string]$Path,
		[ValidateSet("None", "Low", "Medium", "High")]
		[string]$Impact = "None",
		[switch]$Skip = $false,
		[string]$Ignore = $null,
		[object]$Expect,
		[object]$Extract,
		[string]$Iterator = $null,
		[string]$ExplicitIterator = $null,
		[ValidateSet("Naive", "Explicit")]
		[string]$ComparisonType = "Naive",
		[string]$ThrowOnConfig
	);
	
	begin {
		
	};
	
	process {
		
	};
	
	end {
		
	};
}