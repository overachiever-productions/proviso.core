Set-StrictMode -Version 1.0;

<#

	Import-Module -Name "D:\Dropbox\Repositories\proviso.core" -Force;

	$global:DebugPreference = "Continue";
	$global:VerbosePreference = "Continue";

	Runbook "Firewall Stuff" { 
		Setup {} 
		Assertions {
			Assert "This";
		}

		Operations {
			Implement -Surface "Intellisense Name Here would be Great";
			Implement -SurfaceName "Surface to Process" -Impact "Medium";
			Implement "My Facet Name"; 
		}

		Cleanup { }
	}

#>

function Runbook {
	[CmdletBinding()]
	param (
		[Parameter(Mandatory, Position = 0)]
		[string]$Name,
		[Parameter(Mandatory, Position = 1)]
		[ScriptBlock]$RunbookBlock
		
		# TODO: other params as per ... https://www.notion.so/overachiever/APIs-9c34b68d4f68476aaa15476d27c06596?pvs=4#ca18489538424ca3a5ebd6a9728b7e39
	);
	
	begin {
		[bool]$xVerbose = ("Continue" -eq $global:VerbosePreference) -or ($PSBoundParameters["Verbose"] -eq $true);
		[bool]$xDebug = ("Continue" -eq $global:DebugPreference) -or ($PSBoundParameters["Debug"] -eq $true);
		
		Enter-Block $MyInvocation.MyCommand -Name $Name -Verbose:$xVerbose -Debug:$xDebug;
	};
	
	process {
		Write-Verbose "Compiling Runbook [$Name].";
		
		[Proviso.Core.Definitions.RunbookDefinition]$definition = New-Object Proviso.Core.Definitions.RunbookDefinition($Name);
		
		$currentRunbook = $definition;
		Store-Runbook -Runbook $definition -Verbose:$xVerbose -Debug:$xDebug;
		
		& $RunbookBlock;
	};
	
	end {
		Exit-Block $MyInvocation.MyCommand -Name $Name -Verbose:$xVerbose -Debug:$xDebug;
	};
}

function Store-Runbook {
	[CmdletBinding()]
	param (
		[Proviso.Core.Definitions.RunbookDefinition]$Runbook
	);
	
	process {
		try {
			Write-Debug "	Adding Runbook [$($Runbook.Name)] to Catalog.";
			if ($global:PvOrthography.StoreRunbookDefinition($Runbook, (Allow-DefinitionReplacement))) {
				Write-Verbose "Runbook [$($Runbook.Name)] was replaced.";
			}
		}
		catch {
			throw "Exception storing Runbook: $($_.Exception.Message) `r`t$($_.ScriptStackTrace) ";
		}
	}
}