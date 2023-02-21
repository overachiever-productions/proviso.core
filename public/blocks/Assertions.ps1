Set-StrictMode -Version 1.0;

function Assertions {
	[CmdletBinding()]
	param (
		[ScriptBlock]$AssertionsBlock
	);
	
	begin {
		[bool]$xVerbose = ("Continue" -eq $global:VerbosePreference) -or ($PSBoundParameters["Verbose"] -eq $true);
		[bool]$xDebug = ("Continue" -eq $global:DebugPreference) -or ($PSBoundParameters["Debug"] -eq $true);
		
		Enter-Block $MyInvocation.MyCommand -Name $null -Verbose:$xVerbose -Debug:$xDebug;
	};
	
	process {
		# NOTE: this block IS essential. The begin/end blocks 'keep track' of where we are via the taxonomy. 
		# 		other than that, this is JUST a wrapper - that, in turn, runs its $AssertionsBlock (so that Asserts can be loaded into a surface or runbook).
		
		& $AssertionsBlock;
	};
	
	end {
		Exit-Block $MyInvocation.MyCommand -Name $null -Verbose:$xVerbose -Debug:$xDebug;
	};
}