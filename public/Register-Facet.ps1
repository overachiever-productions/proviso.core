Set-StrictMode -Version 1.0;

function Register-Facet {
	[CmdletBinding()]
	param (
		[Parameter(Mandatory)]
		[string]$Facet,
		[string]$Parent,
		[switch]$OverWrite = $false		# synonyms or better names might be: $Replace, $Force? etc... 
	);
	
	begin {
		
	};
	
	process {
		Write-Host "Executing REGISTER_FACET.";
		
		
		# NOTES from Read-Facet:
		# ---------------------------------------------------------------------------------------------
		# options here: Register-Facet (probably my best option)... or: Import-Facet, or even Assert-Facet or ... Initialize-Facet or ... Confirm-Facet. 
		# 			confirm sucks... and ... initialize works... but isn't exactly what I'm shooting for. 
		#   and... maybe what I need to do here is: 
		#    	a) PvCatalog ends up being a registry/catalog of 'COMPILED' things - like facets, surfaces, runbooks and any other resources. 
		# 		b) what I'm CURRENTLY calling the PvCatalog could be more of a dictionary/lexicon/register... that is used ONLY for build operations? 
		#  			and, yeah, the above is what I need to do... 
		# 				as in: BUILD is 'my problem/domain' - something that I have to tackle as the framework author... 
		# 				but the $PvCatalog is what 'users' can/will use to register  (or unregister) any of their objects and so on... 
		# 				as in: 'my' stuff/dictionary/whatever is hidden and internal ... whereas the 'catalog' is public and can have objects added/removed.		
		# ---------------------------------------------------------------------------------------------
	};
	
	end {
		
	};
}