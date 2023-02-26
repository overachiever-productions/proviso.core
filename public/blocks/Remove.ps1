Set-StrictMode -Version 1.0;

function Remove {
	[CmdletBinding()]
	param (
		[string]$Name = $null,
		# TODO: still not sure this is even remotely close to right:
		[ValidateSet("ConfirmLow", "ConfirmMedium", "ConfirmHigh")]
		[string]$ConfirmationLevel,
		[ScriptBlock]$RemoveBlock
	);
	
	begin {
		[bool]$xVerbose = ("Continue" -eq $global:VerbosePreference) -or ($PSBoundParameters["Verbose"] -eq $true);
		[bool]$xDebug = ("Continue" -eq $global:DebugPreference) -or ($PSBoundParameters["Debug"] -eq $true);
		
		# NOTE: a BIT confusing to call 'current' but we HAVEN'T YET 'entered' this Add block yet.
		[string]$parentBlockType = $global:PvLexicon.GetCurrentBlockType();
		[string]$parentBlockName = $global:PvLexicon.GetCurrentBlockName();
		
		Enter-Block ($MyInvocation.MyCommand) -Name (Collapse-Arguments -Arg1 $Name -Arg2 $parentBlockName -IgnoreEmptyStrings) -Verbose:$xVerbose -Debug:$xDebug;
	};
	
	process {
		
	};
	
	end {
		Exit-Block $MyInvocation.MyCommand -Name $Name -Verbose:$xVerbose -Debug:$xDebug;
	};
}