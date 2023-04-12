Set-StrictMode -Version 1.0;

function Cleanup {
	[CmdletBinding()]
	param (
		[switch]$Skip = $false,
		[string]$Ignore = $null,
		[ScriptBlock]$CleanupBlock
	);
	
	begin {
		[bool]$xVerbose = ("Continue" -eq $global:VerbosePreference) -or ($PSBoundParameters["Verbose"] -eq $true);
		[bool]$xDebug = ("Continue" -eq $global:DebugPreference) -or ($PSBoundParameters["Debug"] -eq $true);
		
		Enter-Block $MyInvocation.MyCommand -Name $null -Verbose:$xVerbose -Debug:$xDebug;
	};
	
	process {
		$parentBlockType = Get-ParentBlockType;
		$parentBlockName = Get-ParentBlockName;
		
		Write-Verbose "$(Get-DebugIndent)Compiling .Cleanup{} for $parentBlockType named [$parentBlockName].";
		
		$type = [Proviso.Core.SetupOrCleanup]::Cleanup;
		
		# BIND (and build/define):
		switch ($parentBlockType) {
			"Runbook" {
				$definition = New-Object Proviso.Core.Definitions.SetupOrCleanupDefinition([Proviso.Core.RunbookOrSurface]::Runbook, $type, $parentBlockName);
				
				Write-Debug "$(Get-DebugIndent)	Adding Cleanup to Runbook: [$parentBlockName].";
				$currentRunbook.Cleanup = $definition;
			}
			"Surface" {
				$definition = New-Object Proviso.Core.Definitions.SetupOrCleanupDefinition([Proviso.Core.RunbookOrSurface]::Surface, $type, $parentBlockName);
				
				Write-Debug "$(Get-DebugIndent)	Adding Cleanup to Surface: [$parentBlockName].";
				$currentSurface.Cleanup = $definition;
			}
			default {
				throw "Syntax Error. Cleanup can ONLY be a member of Runbooks and Surfaces.";
			}
		}
		
		# set 'common properties':
		$definition.ScriptBlock = $CleanupBlock;
		
		if ((Is-Skipped -ObjectType ($MyInvocation.MyCommand) -Name "_Cleanup_" -Skip:$Skip -Ignore $Ignore)) {
			$definition.SetSkipped($Ignore);
		}
	};
		
	end {
		Exit-Block $MyInvocation.MyCommand -Name $null -Verbose:$xVerbose -Debug:$xDebug;
	};
}