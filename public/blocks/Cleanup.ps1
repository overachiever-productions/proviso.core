Set-StrictMode -Version 1.0;

function Cleanup {
	[CmdletBinding()]
	param (
		[ScriptBlock]$CleanupBlock
	);
	
	begin {
		[bool]$xVerbose = ("Continue" -eq $global:VerbosePreference) -or ($PSBoundParameters["Verbose"] -eq $true);
		[bool]$xDebug = ("Continue" -eq $global:DebugPreference) -or ($PSBoundParameters["Debug"] -eq $true);
		
		Enter-Block $MyInvocation.MyCommand -Name $null -Verbose:$xVerbose -Debug:$xDebug;
	};
	
	process {
		
		
		
		#& $ScriptBlock;
	};
	
	end {
		Exit-Block $MyInvocation.MyCommand -Name $null -Verbose:$xVerbose -Debug:$xDebug;
	};
}