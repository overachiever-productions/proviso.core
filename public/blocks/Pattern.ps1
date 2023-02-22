Set-StrictMode -Version 1.0;

# Ths SHOULD be nothing more than: 
# 	1) a CLR FacetDefinition with FacetType.Pattern. 
# 	2) some slightly different taxonomy/rules that allow for an Iterate/Iterator and Add/Remove children. 
# 		
# 	as in, there MIGHT be more differences than what I'm thinking about above... 
# 		but, the goal will be to ENCAPSULATE commonality between Facet|Pattern and then just address ONLY what differs.S


#function FacetPattern {
#	[CmdletBinding()]
#	[Alias("Pattern")]
#	param (
#		[Parameter(Mandatory, Position = 0)]
#		[string]$Name,
#		[string]$ModelPath = $null,
#		[string]$TargetPath = $null,
#		[string]$Path,
#		[ValidateSet("None", "Low", "Medium", "High")]
#		[string]$Impact = "None",
#		[switch]$Skip = $false,
#		[string]$Ignore = $null,
#		[object]$Expect,
#		[object]$Extract,
#		[string]$Iterator = $null,
#		[string]$ExplicitIterator = $null,
#		[ValidateSet("Naive", "Explicit")]
#		[string]$ComparisonType = "Naive",
#		[string]$ThrowOnConfig
#	);
#	
#	begin {
#		
#	};
#	
#	process {
#		
#	};
#	
#	end {
#		
#	};
#}