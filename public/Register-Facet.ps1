Set-StrictMode -Version 1.0;

function Register-Facet {
	[CmdletBinding()]
	param (
		[Parameter(Mandatory)]
		[string]$Facet,
		[string]$Parent
	);
	
	begin {
		
	};
	
	process {
		Write-Host "Executing REGISTER_FACET.";
	};
	
	end {
		
	};
}