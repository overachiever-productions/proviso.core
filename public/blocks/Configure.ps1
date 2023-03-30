Set-StrictMode -Version 1.0;

function Configure {
	[CmdletBinding()]
	param (
		[ScriptBlock]$ConfigureBlock
	);
	
	begin {
		[bool]$xVerbose = ("Continue" -eq $global:VerbosePreference) -or ($PSBoundParameters["Verbose"] -eq $true);
		[bool]$xDebug = ("Continue" -eq $global:DebugPreference) -or ($PSBoundParameters["Debug"] -eq $true);
		
		Enter-Block $MyInvocation.MyCommand -Name $Name -Verbose:$xVerbose -Debug:$xDebug;
	};
	
	process {
		Bind-Configure -ConfigureBlock $ConfigureBlock -Verbose:$xVerbose -Debug:$xDebug;
	};
	
	end {
		Exit-Block $MyInvocation.MyCommand -Name $Name -Verbose:$xVerbose -Debug:$xDebug;
	};
}

function Bind-Configure {
	[CmdletBinding()]
	param (
		[ScriptBlock]$ConfigureBlock
	);
	
	process {
		$parentBlockType = $global:PvOrthography.GetParentBlockType();
		$parentName = $global:PvOrthography.GetParentBlockName();
		$grandParentName = $global:PvOrthography.GetGrandParentBlockName();
		
		switch ($parentBlockType) {
			"Inclusion" {
				throw "Inclusiong BINDING not yet implemented";
			}
			"Property" {
				Write-Debug "$(Get-DebugIndent)		Binding Configure to Property: [$($parentName)].";
				$currentProperty.Configure = $ConfigureBlock;
			}
			default {
				throw "Proviso Framework Error. Invalid Parent Block Type: [$($parentBlockType)] specified for Configure Block.";
			}
		}
	}
}