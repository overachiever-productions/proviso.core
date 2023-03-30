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
		try {
			Write-Debug "	Adding Runbook [$Name] to Catalog.";
			[bool]$replaced = $global:PvOrthography.StoreRunbookDefinition($definition, (Allow-DefinitionReplacement));
			
			if ($replaced) {
				Write-Verbose "Runbook [$($Name)] was replaced.";
			}
		}
		catch {
			throw "$($_.Exception.Message) `r`t$($_.ScriptStackTrace) ";
		}
		
		& $RunbookBlock;
	};
	
	end {
		Exit-Block $MyInvocation.MyCommand -Name $Name -Verbose:$xVerbose -Debug:$xDebug;
	};
}