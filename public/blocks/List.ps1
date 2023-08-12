Set-StrictMode -Version 1.0;

<#
	List is to Membership AND Topology as Extract is to Property. 
		i.e., it's a means of grabbing/listing/extracting enums/iterators

#>


function List {
	[CmdletBinding()]
	param (
		[Parameter(Mandatory, Position = 0, ParameterSetName = 'Named')]
		[string]$Name = $null,
		
		[Parameter(Position = 1, ParameterSetName = 'Named')]
		[parameter(Mandatory, Position = 0, ParameterSetName = 'Anonymous')]
		[ScriptBlock]$ListBlock
	);
	
	begin {
		[bool]$xVerbose = ("Continue" -eq $global:VerbosePreference) -or ($PSBoundParameters["Verbose"] -eq $true);
		[bool]$xDebug = ("Continue" -eq $global:DebugPreference) -or ($PSBoundParameters["Debug"] -eq $true);
		
		Enter-Block $MyInvocation.MyCommand -Name $Name -Verbose:$xVerbose -Debug:$xDebug;
	};
	
	process {
		# BIND:
		switch ((Get-ParentBlockType)) {
			"Instance" {
				Write-Debug "$(Get-DebugIndent)   Binding List to Pattern-Instance.";
				$currentInstance.SetListBlock($ListBlock);
			}
			"Membership" {
				Write-Debug "$(Get-DebugIndent)   Binding List to Membership.";
				$currentMembership.SetListBlock($ListBlock);
			}
			default {
				throw "Proviso Framework Error. Invalid Parent: [$($currentCohort.ParentType)] specified for List-Block.";
			}
		}
	};
	
	end {
		Exit-Block $MyInvocation.MyCommand -Name $Name -Verbose:$xVerbose -Debug:$xDebug;
	};
}