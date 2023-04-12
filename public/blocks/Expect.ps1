Set-StrictMode -Version 1.0;

function Expect {
	[CmdletBinding()]
	param (
		[ScriptBlock]$ExpectBlock
	);
	
	begin {
		[bool]$xVerbose = ("Continue" -eq $global:VerbosePreference) -or ($PSBoundParameters["Verbose"] -eq $true);
		[bool]$xDebug = ("Continue" -eq $global:DebugPreference) -or ($PSBoundParameters["Debug"] -eq $true);
		
		Enter-Block $MyInvocation.MyCommand -Name $Name -Verbose:$xVerbose -Debug:$xDebug;
	};
	
	process {
		
		# BIND: 
		$parentBlockType = $global:PvOrthography.GetParentBlockType();
		$parentName = $global:PvOrthography.GetParentBlockName();
		
		switch ($parentBlockType) {
			"Inclusion" {
				throw "Inclusion BINDING not yet implemented";
			}
			"Property" {
				Write-Debug "$(Get-DebugIndent)		Binding Expect to Property: [$($parentName)].";
				$currentProperty.Expect = $ExpectBlock;
			}
			default {
				throw "Proviso Framework Error. Invalid Parent Block Type: [$($parentBlockType)] specified for Expect Block.";
			}
		}
	};
	
	end {
		Exit-Block $MyInvocation.MyCommand -Name $Name -Verbose:$xVerbose -Debug:$xDebug;
	};
}