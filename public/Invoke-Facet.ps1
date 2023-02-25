Set-StrictMode -Version 1.0;

function Invoke-Facet {
	[CmdletBinding(SupportsShouldProcess)]
	param (

	);
	
	begin {
		
	};
	
	process {
		# TODO: account for -WhatIf & -Confirm (SupportsShouldProcess)
		# 	Specifically, Invoke-FSR funcs allow 'ShouldProcess' functionality. 
		# 		Which means, that:
		# 		1. Specific Facets (or Surfaces or Runbooks) can be AUTHORED to include $ShouldProcess and other logic as part of their definitions. 
		# 				ACTUALLY. NOPE. 
		# 					instead, facets/etc. are authored with the ABILITY to specify an Impact of None, Low, Med, High... 
		# 					where, obviously, the impact ONLY applies to the CONFIG operations (including Remove or even ... Add (think of disks/nics, new members of sysadmins, etc.)))
		# 						and... then, all of the INVOKE-FSR func pass in an optional 'ConfirmLevel' or something similar... and/or the 'confirm level' is (like -Verbose and -Debug)
		# 						'evaluated' in the start of each 'invoke-FSR' func as being either: what was explicitly sent in, OR the global preference/etc. 
		# 						and then, for each CONFIGURE (configure, remove, add) that value gets COMPARED to whatever was defined as a definition for the -Impact
		# 							along the way. e.g., a PROPERTY might have -Impact High. whereas it's facet, surface, runbook would be low. 
		# 							likewise, a facet might mark ALL properties as -Medium (or whatever) and I just need to 
		# 						ensure to a) apply said 'default' for the SURFACE in this case 'down' to cohorts/properties and their Configure/Add/Remve operations 
		# 							when not specified as Medium or whatever else is ALREADY defined at the lower leves that's HIGHER than Medium... 
		# 					so that when I get to an individual property via a CONFIGURE... 
		# 						either: there's no impact cuz nothing was specified - anywhere, or there's an EXPLICIT -Impace on a Property. 
		# 							OR, the -Impact applied 'higher up' than a property has 'inherited DOWN' to the property in question... 
		# 					meaning... that if my pref is LOW... and I run a facet marked HIGH...(or even medium) and the facet has 8 properties, I'm going to be 
		# 						prompted for "Should Continue" for each of those 8x properties. 
		# 		2. The $PVCatalog and/or $PVPipeline needs to 'know' or detect these details and ... match them with 
		# 			any specific args/directives passed into the Invoke-FSR methods... 
	};
	
	end {
		
	};
}