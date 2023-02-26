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
		# NOTE: This block IS essential. The begin/end blocks 'keep track' of where we are via the taxonomy. 
		# 		But, it doesn't really 'do' anything. It's a wrapper for individual Asserts.
		
		& $AssertionsBlock;
	};
	
	end {
		Exit-Block $MyInvocation.MyCommand -Name $null -Verbose:$xVerbose -Debug:$xDebug;
	};
}