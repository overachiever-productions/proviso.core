Set-StrictMode -Version 1.0;

function Setup {
	[CmdletBinding()]
	param (
		[switch]$Skip = $false,
		[string]$Ignore = $null,
		[ScriptBlock]$SetupBlock
	);
	
	begin {
		[bool]$xVerbose = ("Continue" -eq $global:VerbosePreference) -or ($PSBoundParameters["Verbose"] -eq $true);
		[bool]$xDebug = ("Continue" -eq $global:DebugPreference) -or ($PSBoundParameters["Debug"] -eq $true);
		
		Enter-Block $MyInvocation.MyCommand -Name $null -Verbose:$xVerbose -Debug:$xDebug;
	};
	
	process {
		$parentBlockType = Get-ParentBlockType;
		$parentBlockName = Get-ParentBlockName;
		
		Write-Verbose "Compiling .Setup{} for $parentBlockType named [$parentBlockName].";
		
		$type = [Proviso.Core.SetupOrCleanup]::Setup;
		
		# TODO: move this logic into Bind-Setup (even though we won't be 'binding' to orthography... we're still binding to parent... and the logic should be encapsulated)
		try {
			switch ($parentBlockType) {
				"Runbook" {
					$definition = New-Object Proviso.Core.Definitions.SetupOrCleanupDefinition([Proviso.Core.RunbookOrSurface]::Runbook, $type, $parentBlockName);
					$currentRunbook.Setup = $definition;
					
					Write-Debug "		Added Setup{ } to Runbook: [$parentBlockName].";
				}
				"Surface" {
					$definition = New-Object Proviso.Core.Definitions.SetupOrCleanupDefinition([Proviso.Core.RunbookOrSurface]::Surface, $type, $parentBlockName);
					$currentSurface.Setup = $definition;
					
					Write-Debug "		Added Setup{ } to Surface: [$parentBlockName].";
				}
				default {
					throw "Syntax Error. Setup can ONLY be a member of Runbooks and Surfaces.";
				}
			}
			
			# set 'common properties':
			$definition.ScriptBlock = $SetupBlock;
			
			if ((Is-Skipped -ObjectType ($MyInvocation.MyCommand) -Name "_Setup_" -Skip:$Skip -Ignore $Ignore)) {
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