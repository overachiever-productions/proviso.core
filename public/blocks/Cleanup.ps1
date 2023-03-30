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
		
		# TODO: move this logic into Bind-Cleanup (even though we won't be 'binding' to orthography... we're still binding to parent... and the logic should be encapsulated)
		try {
			switch ($parentBlockType) {
				"Runbook" {
					$definition = New-Object Proviso.Core.Definitions.SetupOrCleanupDefinition([Proviso.Core.RunbookOrSurface]::Runbook, $type, $parentBlockName);
					$currentRunbook.Cleanup = $definition;
					
					Write-Debug "$(Get-DebugIndent)	Added Cleanup{ } to Runbook: [$parentBlockName].";
				}
				"Surface" {
					$definition = New-Object Proviso.Core.Definitions.SetupOrCleanupDefinition([Proviso.Core.RunbookOrSurface]::Surface, $type, $parentBlockName);
					$currentSurface.Cleanup = $definition;
					
					Write-Debug "$(Get-DebugIndent)	Added Cleanup{ } to Surface: [$parentBlockName].";
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
		}
		catch {
			throw "$($_.Exception.Message) `r`t$($_.ScriptStackTrace) ";
		}
	};
		
	end {
		Exit-Block $MyInvocation.MyCommand -Name $null -Verbose:$xVerbose -Debug:$xDebug;
	};
}