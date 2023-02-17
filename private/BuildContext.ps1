Set-StrictMode -Version 1.0;

$global:PvBuildContext = [Proviso.Core.BuildContext]::Instance;

function Enter-Runbook {
	[CmdletBinding()]
	param (
		[string]$Name
	);
	
	$PvBuildContext.Runbook = $Name;
	
	Write-Debug "Entered Runbook: $Name";
}

function Enter-Surface {
	[CmdletBinding()]
	param (
		[string]$Name
	);
	
	$PvBuildContext.Surface = $Name;
	
	Write-Debug "	Entered Surface: $Name";
}

function Enter-Aspect {
	[CmdletBinding()]
	param (
		[string]$Name
	);
	
#	Confirm-Orthography "Aspect";
	$PvBuildContext.Aspect = $Name;
	
	Write-Debug "	Entered Aspect: $Name";
}

function Enter-Facet {
	[CmdletBinding()]
	param (
		[string]$Name
	);
	
#	Confirm-Orthography "Facet";
	$PvBuildContext.Facet = $Name;
	
	Write-Debug "		Entered Facet: $Name"; 
}

function Enter-Property {
	[CmdletBinding()]
	param (
		[string]$Name
	);
	
	$PvBuildContext.Property = $Name;
	
	Write-Debug "			Entered Property: $Name";
}

function Exit-Runbook {
	[CmdletBinding()]
	param (
		[string]$Name
	);
	
	$PVBuildContext.Runbook = $null;
	
	Write-Debug "Exited Runbook: $Name";
}

function Exit-Surface {
	[CmdletBinding()]
	param (
		[string]$Name
	);
	
	$PVBuildContext.Surface = $null;
	
	Write-Debug "	Exited Surface: $Name";
}

function Exit-Aspect {
	[CmdletBinding()]
	param (
		[string]$Name
	);
	
	$PVBuildContext.Aspect = $null;
	
	Write-Debug "	Exited Aspect: $Name";
}

function Exit-Facet {
	[CmdletBinding()]
	param (
		[string]$Name
	);
	
	$PvBuildContext.Facet = $null;
	
	Write-Debug "		Exited Facet: $Name";
}

function Exit-Property {
	[CmdletBinding()]
	param (
		[string]$Name
	);
	
	$PvBuildContext.Property = $null;
	
	Write-Debug "			Exited Property: $Name";
}

