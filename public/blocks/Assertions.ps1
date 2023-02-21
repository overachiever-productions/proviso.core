﻿Set-StrictMode -Version 1.0;

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
		# note: may NOT need this block at all... 
		# 		only reason I can think it might need to exist would be to set a simple 'parent' type or something... 
		
		
		# if parent is ... Runbook, then ... add... 'remember' parent... 
		# 		and... (then, down in asserts)... add each found/defined assert to Runbook.Assertions (i.e., array)
		
		# otherwise, do the same for Surface Assertions... 
		
		
		#& $ScriptBlock;
	};
	
	end {
		Exit-Block $MyInvocation.MyCommand -Name $null -Verbose:$xVerbose -Debug:$xDebug;
	};
}