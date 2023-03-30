Set-StrictMode -Version 1.0;

function Compare {
	[CmdletBinding()]
	param (
		[ScriptBlock]$CompareBlock
	);
	
	begin {
		[bool]$xVerbose = ("Continue" -eq $global:VerbosePreference) -or ($PSBoundParameters["Verbose"] -eq $true);
		[bool]$xDebug = ("Continue" -eq $global:DebugPreference) -or ($PSBoundParameters["Debug"] -eq $true);
		
		Enter-Block $MyInvocation.MyCommand -Name $Name -Verbose:$xVerbose -Debug:$xDebug;
	};
	
	process {
		Bind-Compare -CompareBlock $CompareBlock -Verbose:$xVerbose -Debug:$xDebug;
	};
	
	end {
		Exit-Block $MyInvocation.MyCommand -Name $Name -Verbose:$xVerbose -Debug:$xDebug;
	};
}

function Bind-Compare {
	[CmdletBinding()]
	param (
		[ScriptBlock]$CompareBlock
	);
	
	process {
		$parentBlockType = $global:PvOrthography.GetParentBlockType();
		$parentName = $global:PvOrthography.GetParentBlockName();
		
		switch ($parentBlockType) {
			"Inclusion" {
				throw "Inclusiong BINDING not yet implemented";
			}
			"Property" {
				Write-Debug "$(Get-DebugIndent)		Binding Compare to Property: [$($parentName)].";
				$currentProperty.Compare = $CompareBlock;
			}
			default {
				throw "Proviso Framework Error. Invalid Parent Block Type: [$($parentBlockType)] specified for Compare Block.";
			}
		}
	}
}