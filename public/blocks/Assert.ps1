Set-StrictMode -Version 1.0;

function Assert {
	[CmdletBinding()]
	param (
		[string]$Name,
		[Alias("Is", "Has", "For", "Exists")]
		[switch]$That = $false, # syntactic sugar 
		[Alias("IsNot", "HasNot", "ExistsNot")]
		[switch]$ThatNot = $false, # negation + syntactic sugar		
		[string]$FailureMessage = $null,
		[switch]$Skip = $false,
		[string]$Ignore = $null,
		[switch]$ConfigureOnly = $false
	);
	
	begin {
		
	};
	
	process {
		
	};
	
	end {
		
	};
}