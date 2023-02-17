Set-StrictMode -Version 1.0;

$global:PvOrthography = [Proviso.Core.Orthography]::Instance;

filter Confirm-Orthography {
	param (
		[string]$Current
	);
	
	# TODO: For Runbooks, Surfaces, Facets and Properties|Cohorts... I'll have the BuildContext to provide some additional info. 
	# 		but, that leaves: Iterator|Enumerator, Add, Remove, and a handful of other operations. 
	$stack = ((Get-PSCallStack).Command -join ",") -replace "Confirm-Orthography,";
	
	Write-Verbose "		Orthography. Func: $Current -> Stack: $stack";
}

<#
	Runbook
		[Assertions]
			[Assert]
		Surface
			[Setup]
			[Assertions]
				[Assert]
			[Aspect]
				Facet | Pattern 
					[Iterate] (for Pattern)
					[Add]	(Pattern)  - Install?
					[Remove] (Pattern) - Uninstall?
					Property | Cohort 
						Enumerate
						Add
						Remove
						Property (of Cohort - and... recurses)
						[Inclusion] (of Property | Cohort)
						Expect
						Extract
						[Compare]
						Configure

			[Cleanup] (Surface)
		[Cleanup] (Runbook)
					

#>