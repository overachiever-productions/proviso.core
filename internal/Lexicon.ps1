Set-StrictMode -Version 1.0;

<#
	Runbook
		[Setup]
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
		[string]$Name = $null
	);
	
	# $stack = (Get-PSCallStack).Command -join ",";
	try {
		$PvLexicon.EnterBlock($Type, $Name);
	}
	catch {
		throw "Proviso Exception: $($_.Exception.InnerException.Message) `r`t$($_.ScriptStackTrace) ";
	}

	Write-Debug "$("`t" * $PvLexicon.CurrentDepth)Entered $($Type): $Name";
}

function Exit-Block {
	[CmdletBinding()]
	param (
		[Parameter(Mandatory)]
		[string]$Type,
		[string]$Name = $null
	);
	
	Write-Debug "$("`t" * $PvLexicon.CurrentDepth) Exiting $($Type): $Name";
	
	try {
		$PvLexicon.ExitBlock($Type, $Name);
	}
	catch {
		throw "Proviso Exception: $($_.Exception.InnerException.Message) `r`t$($_.ScriptStackTrace) ";
	}
}

filter Get-PreviousBlockType {
	return $PvLexicon.GetPreviousBlockType();
}