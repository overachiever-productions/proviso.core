Set-StrictMode -Version 1.0;

<# 
	
	MIGHT still end up calling this a toplogy instead. 

	Otherwise, it's the wrapper around enumerator/add/etc... 

#>

function Membership {
	[CmdletBinding()]
	param (
		[Parameter(Mandatory, Position = 0, ParameterSetName = 'Named')]
		[string]$Name = $null,
		
		[Parameter(Position = 1, ParameterSetName = 'Named')]
		[parameter(Mandatory, Position = 0, ParameterSetName = 'Anonymous')]
		[ScriptBlock]$MembershipBlock,
		
		[Switch]$Naive = $true,
		[Switch]$Strict = $false,
		
		# TODO: this might not even make sense. It's implemented as a STRING for now.
		[string]$OrderBy = $null 
	);
	
	begin {
		[bool]$xVerbose = ("Continue" -eq $global:VerbosePreference) -or ($PSBoundParameters["Verbose"] -eq $true);
		[bool]$xDebug = ("Continue" -eq $global:DebugPreference) -or ($PSBoundParameters["Debug"] -eq $true);
		
		Enter-Block $MyInvocation.MyCommand -Name $Name -Verbose:$xVerbose -Debug:$xDebug;
	};
	
	process {
		if ($Naive -and $Strict) {
			throw "ruh row!!";
		}
		
		
		$currentMembership = New-Object Proviso.Core.Models.Membership($Name, (Get-ParentBlockName));
		
		
		
		
		# STORE:
		# TODO: if/when I allow 'global' Memberships (topologies?) ... then, a) the .ctor for Membership will need to know that parentType = "Memberships" and b) I'll need to store the current membership in the Build-Store.
		
		# BIND: 
		# TODO: If/when I allow global memberships ... then, change this assignment to use a switch or if/else/etc.  
		$grandParentName = Get-GrandParentBlockName;
		Write-Debug "$(Get-DebugIndent)	Binding Membership: [$Name] to parent Collection: [$($currentMembership.Name)], with grandparent named: [$grandParentName].";
		$currentCollection.SetMembership($currentMembership);
		
		& $MembershipBlock;
	};
	
	end {
		Exit-Block $MyInvocation.MyCommand -Name $Name -Verbose:$xVerbose -Debug:$xDebug;
	};
}