Set-StrictMode -Version 1.0;

<#
	Runbook
		[Assertions]
			[Assert]
		Operations
			Run 
			Run
			Run
		[Cleanup]
		

	Surface
		[Setup]
		[Assertions]
			[Assert]
		[Aspect]
			[Import] -Pattern|Facet
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

		[Cleanup]
#>

$global:PvLexicon = [Proviso.Core.Lexicon]::Instance;

function Enter-Block {
	[CmdletBinding()]
	param (
		[Parameter(Mandatory)]
		[string]$Type,
		[Parameter(Mandatory)]
		[string]$Name
	);
	
	# STACK serialization: 	$stack = ((Get-PSCallStack).Command -join ",") -replace "Confirm-Orthography,";
	
	$tabs = "";
	switch ($Type) {
		{ $_ -in @("Facet", "Pattern") } {
			$tabs = "`t`t";
			
		}
		{ $_ -in @("Iterate", "Add", "Remove", "Property", "Cohort") } {
			$tabs = "`t`t`t";
			
		}
		{ $_ -in @("Enumerate", "Inclusion", "Expect", "Extract", "Compare", "Configure") } {
			$tabs = "`t`t`t`t";
			
		}
	}
	
	Write-Debug "$($tabs)Entered $($Type): $Name";
}

function Exit-Block {
	[CmdletBinding()]
	param (
		[Parameter(Mandatory)]
		[string]$Type,
		[Parameter(Mandatory)]
		[string]$Name
	);
	
}