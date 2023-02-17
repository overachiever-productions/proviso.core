Set-StrictMode -Version 1.0;

function Invoke-Surface {
	[CmdletBinding()]
	param (

	);
	
	begin {
		
	};
	
	process {
		# TODO: account for -WhatIf & -Confirm (SupportsShouldProcess)
		# 	Specifically, Invoke-FSR funcs allow 'ShouldProcess' functionality. 
		# 		Which means, that:
		# 		1. Specific Facets (or Surfaces or Runbooks) can be AUTHORED to include $ShouldProcess and other logic as part of their definitions. 
		# 		2. The $PVCatalog and/or $PVPipeline needs to 'know' or detect these details and ... match them with 
		# 			any specific args/directives passed into the Invoke-FSR methods... 		
	};
	
	end {
		
	};
}