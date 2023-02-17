Set-StrictMode -Version 1.0;

function Enumerate {
	[CmdletBinding()]
	param (
		[Parameter(Mandatory, Position = 0)]
		[string]$Name = $null,
		[Parameter(Mandatory, Position = 1)]
		[ScriptBlock]$ScriptBlock,
		[string]$OrderBy = $null
	);
	
	begin {
		
	};
	
	process {
		
		# NOTE: $ScriptBlock here is the script to ... add as the Enumerator... 
	};
	
	end {
		
	};
}