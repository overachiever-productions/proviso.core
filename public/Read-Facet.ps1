Set-StrictMode -Version 1.0;

<#

	Import-Module -Name "D:\Dropbox\Repositories\proviso.core" -Force;

	Facet "My First Facet" { }
	Read-Facet "My First Facet" -Verbose -Debug;

write-host "--------------------------------------------------"

	Facet "My Second Facet" { }

	$facets = @(
		[PSCustomObject]@{ Name = "My First Facet" }
		[PSCustomObject]@{ Name = "My Second Facet" }
	)

	$facets | Read-Facet -Verbose;

#>


function Read-Facet {
	[CmdletBinding()]
	[Alias("Read-Pattern")]
	param (
		#[ValidateNotNullOrEmpty()]
		[Parameter(ValueFromPipelineByPropertyName)]
		[Alias("FacetName", "PatternName")]
		[string]$Name,
		[Alias("Targets")]
		[object]$Target = $null,
		[object]$Extract = $null,
		[string]$Servers = $null,
		[switch]$AsPSON = $false
	);
	
	begin {
		Write-Verbose "BEGIN: $Name"
		
		# So, in terms of -Target(s) being an array:
		# 		what if I want to actually 'target' a single array of values - to tackle my READ operation. i.e., MAYBE -Extract is simply $Target.Count ??? right?
		# 		how can i tell the difference between the above, and, say... a scenario where I want to get $Target.Length() - but I want to do it against MULTIPLE targets?
		# 			I don't think i CAN actually differentiate between the two. 
		# 		the ONLY thing I can think of would be something like -Target and -[Multiple]Targets
		
		# TODO: address -Servers. 
		# TODO: address $Targets (array)
	};
	
	process {
		Write-Verbose "PROCESS: $Name"

		$facet = $global:PVCatalog.GetFacetByName($Name);
		if ($null -eq $facet) {
			throw "Error. No Facet or Pattern with the name [$Name] was found.";
		}		

		
		# after proxying for above ... 
		# 	hand off to the pipeline
		
		Write-Host "	Facet Name: $($facet.Name)" -ForegroundColor Cyan;
	};
	
	end {
		
	};
}