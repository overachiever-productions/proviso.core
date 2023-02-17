Set-StrictMode -Version 1.0;

$global:PvCompilationMonitor = [Proviso.Core.CompilationMonitor]::Instance;

function Enter-Runbook {
	[CmdletBinding()]
	param (
		[string]$Name
	);
	
	$PvCompilationMonitor.Runbook = $Name;
	
	Write-Debug "Entered Runbook: $Name";
}

function Enter-Surface {
	[CmdletBinding()]
	param (
		[string]$Name
	);
	
	$PvCompilationMonitor.Surface = $Name;
	
	Write-Debug "	Entered Surface: $Name";
}

function Enter-Aspect {
	[CmdletBinding()]
	param (
		[string]$Name
	);
	
#	Confirm-Orthography "Aspect";
	$PvCompilationMonitor.Aspect = $Name;
	
	Write-Debug "	Entered Aspect: $Name";
}

function Enter-Facet {
	[CmdletBinding()]
	param (
		[string]$Name
	);
	
#	Confirm-Orthography "Facet";
	$PvCompilationMonitor.Facet = $Name;
	
	Write-Debug "		Entered Facet: $Name"; 
}

function Enter-Property {
	[CmdletBinding()]
	param (
		[string]$Name
	);
	
	$PvCompilationMonitor.Property = $Name;
	
	Write-Debug "			Entered Property: $Name";
}

function Exit-Runbook {
	[CmdletBinding()]
	param (
		[string]$Name
	);
	
	$PvCompilationMonitor.Runbook = $null;
	
	Write-Debug "Exited Runbook: $Name";
}

function Exit-Surface {
	[CmdletBinding()]
	param (
		[string]$Name
	);
	
	$PvCompilationMonitor.Surface = $null;
	
	Write-Debug "	Exited Surface: $Name";
}

function Exit-Aspect {
	[CmdletBinding()]
	param (
		[string]$Name
	);
	
	$PvCompilationMonitor.Aspect = $null;
	
	Write-Debug "	Exited Aspect: $Name";
}

function Exit-Facet {
	[CmdletBinding()]
	param (
		[string]$Name
	);
	
	$PvCompilationMonitor.Facet = $null;
	
	Write-Debug "		Exited Facet: $Name";
}

function Exit-Property {
	[CmdletBinding()]
	param (
		[string]$Name
	);
	
	$PvCompilationMonitor.Property = $null;
	
	Write-Debug "			Exited Property: $Name";
}

