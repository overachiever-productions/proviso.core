Set-StrictMode -Version 1.0;

<#
	
	'Wrapper' within a Pattern block - to house 1 - N Instance (Iterator) blocks.

	NOTE: this is, effectively, a 'pass-through' block (it doesn't STORE or BIND); it's JUST a wrapper for Instance blocks.
#>

function Topology {
	[CmdletBinding()]
	param (
		[parameter(Mandatory, Position = 0)]
		[ScriptBlock]$TopologyBlock
	);
	
	begin {
		[bool]$xVerbose = ("Continue" -eq $global:VerbosePreference) -or ($PSBoundParameters["Verbose"] -eq $true);
		[bool]$xDebug = ("Continue" -eq $global:DebugPreference) -or ($PSBoundParameters["Debug"] -eq $true);
		
		Enter-Block ($MyInvocation.MyCommand) -Name $null -Verbose:$xVerbose -Debug:$xDebug;
	};
	
	process {
		
		& $TopologyBlock;
	};
	
	end {
		Exit-Block $MyInvocation.MyCommand -Name $null -Verbose:$xVerbose -Debug:$xDebug;
	};
}