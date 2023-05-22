Set-StrictMode -Version 1.0;

function Extract {
	[CmdletBinding()]
	param (
		[ScriptBlock]$ExtractBlock
	);
	
	begin {
		[bool]$xVerbose = ("Continue" -eq $global:VerbosePreference) -or ($PSBoundParameters["Verbose"] -eq $true);
		[bool]$xDebug = ("Continue" -eq $global:DebugPreference) -or ($PSBoundParameters["Debug"] -eq $true);
		
		Enter-Block $MyInvocation.MyCommand -Name $Name -Verbose:$xVerbose -Debug:$xDebug;
	};
	
	process {
		switch ((Get-ParentBlockType)) {
			"Inclusion" {
				throw "Inclusiong BINDING not yet implemented";
			}
			"Property" {
				Write-Debug "$(Get-DebugIndent)		Binding Extract to Property: [$((Get-ParentBlockName))].";
				$currentProperty.Extract = $ExtractBlock;
			}
			default {
				throw "Proviso Framework Error. Invalid Parent Block Type: [$((Get-ParentBlockType))] specified for Extract Block.";
			}
		}
	};
	
	end {
		Exit-Block $MyInvocation.MyCommand -Name $Name -Verbose:$xVerbose -Debug:$xDebug;
	};
}