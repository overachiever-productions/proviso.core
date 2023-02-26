Set-StrictMode -Version 1.0;

function Assert {
	[CmdletBinding()]
	param (
		[string]$Name,
		[Alias("Is", "Has", "For", "Exists")]
		[switch]$That = $false, # syntactic sugar 
		[Alias("IsNot", "HasNot", "ExistsNot")]
		[switch]$ThatNot = $false, # negation + syntactic sugar		
		[string]$FailureMessage = $null,
		[switch]$Skip = $false,
		[string]$Ignore = $null,
		[switch]$ConfigureOnly = $false
	);
	
	begin {
		[bool]$xVerbose = ("Continue" -eq $global:VerbosePreference) -or ($PSBoundParameters["Verbose"] -eq $true);
		[bool]$xDebug = ("Continue" -eq $global:DebugPreference) -or ($PSBoundParameters["Debug"] -eq $true);
		
		Enter-Block $MyInvocation.MyCommand -Name $Name -Verbose:$xVerbose -Debug:$xDebug;
	};
	
	process {
		$grandParentBlockType = Get-GrandParentBlockType;
		$grandParentBlockName = Get-GrandParentBlockName;
		
		Write-Verbose "Compiling Assert for $($grandParentBlockType): [$grandParentBlockName].";
		
		[bool]$negated = $ThatNot;
		[Proviso.Core.Definitions.AssertDefinition]$assert = New-Object Proviso.Core.Definitions.AssertDefinition($Name, $FailureMessage, $negated, $ConfigureOnly);
		
		# TODO: Address Ignore/Skip. As in: 1) do I simply 'skip' adding to Runbook/Surface if 'skipped' or do I add as .Disabled (probably the latter) 
		# 			and 2) what's the best way to avoid DRY violations with the above... 
		
		# TODO: UNLESS this is an extant/explicit Assert-XyzFunc... 
		# 			then, we'll have a code-block here... 
		# 		and, that's PROBABLY the check. i.e., if we're somehow inside of Assert "Some Name" then... we'll hit this code here.
		# 		hmmm. but, if not... then... a) we won't hit this code (i.e., the "Assert" func (this) won't be called and ... b) how to fix that? 
		# 			maybe some sort of Import-Assert or Assert-That? which takes in NAMED/existing 'asserts'?
		

		
	};
	
	end {
		try {
			if ("Runbook" -eq $grandParentBlockType) {
				$runbook.AddAssert($assert);
				Write-Debug "				Adding Assert [$Name] to Runbook: [$grandParentBlockName].";
			}
			else {
				$surface.AddAssert($assert);
				Write-Debug "				Added Assert [$Name] to Surface: [$grandParentBlockName].";
			}
		}
		catch {
			throw "$($_.Exception.Message) `r`t$($_.ScriptStackTrace) ";
		}
		
		Exit-Block $MyInvocation.MyCommand -Name $Name -Verbose:$xVerbose -Debug:$xDebug;
	};
}