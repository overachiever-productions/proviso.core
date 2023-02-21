Set-StrictMode -Version 1.0;

<#

	Import-Module -Name "D:\Dropbox\Repositories\proviso.core" -Force;

	$global:DebugPreference = "Continue";
	$global:VerbosePreference = "Continue";

	Runbook "Firewall Stuff" { 
		Setup {} 
		Assertions {}

		Operations {
			#Implement [-Facet] "Intellisense Name Here would be Great" -something? 
			Implement -FacetName "Facet to Process";
			Implement "My Facet Name"; # I could add -ExecutionOrder, but seems odd... 
			#Implement -Facet "facet is just a switch/syntactic sugar" -Impact/Overwrite/whatever goes here... 
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
		
		& $RunbookBlock;
	};
	
	end {
		Exit-Block $MyInvocation.MyCommand -Name $Name -Verbose:$xVerbose -Debug:$xDebug;
	};
}