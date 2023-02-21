Set-StrictMode -Version 1.0;

function Remove {
	[CmdletBinding()]
	param (
		[string]$Name = $null,
		# TODO: still not sure this is even remotely close to right:
		[ValidateSet("ConfirmLow", "ConfirmMedium", "ConfirmHigh")]
		[string]$ConfirmationLevel,
		[ScriptBlock]$RemoveBlock
	);
	
	begin {
		
	};
	
	process {
		
	};
	
	end {
		
	};
}