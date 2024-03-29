﻿Set-StrictMode -Version 3.0;

# Import CLR objects: 
. "$PSScriptRoot\proviso.core.meta.ps1"

# Import Private Funcs: 
foreach ($file in (@(Get-ChildItem -Path (Join-Path -Path $PSScriptRoot -ChildPath 'internal/*.ps1') -Recurse -ErrorAction Stop))) {
	try {
		. $file.FullName;
	}
	catch {
		throw "Unable to dot source INTERNAL proviso.core file: [$($file.FullName)]`rEXCEPTION: $_  `r$($_.ScriptStackTrace) ";
	}
}

# Import External Funcs: 
foreach ($file in (@(Get-ChildItem -Path (Join-Path -Path $PSScriptRoot -ChildPath 'external/*.ps1') -Recurse -ErrorAction Stop))) {
	try {
		. $file.FullName;
	}
	catch {
		throw "Unable to dot source EXTERNAL proviso.core file: [$($file.FullName)]`rEXCEPTION: $_  `r$($_.ScriptStackTrace) ";
	}
}


# Import Public Funcs: 
[string[]]$publicFuncs = @();
foreach ($file in (@(Get-ChildItem -Path (Join-Path -Path $PSScriptRoot -ChildPath 'public/blocks/*.ps1') -Recurse -ErrorAction Stop))) {
	try {
		. $file.FullName;
		$publicFuncs += $file.Basename;
	}
	catch {
		throw "Unable to dot source proviso.core file: [$($file.FullName)]`rEXCEPTION: $_  `r$($_.ScriptStackTrace) ";
	}
}

foreach ($file in (@(Get-ChildItem -Path (Join-Path -Path $PSScriptRoot -ChildPath 'public/*.ps1') -Recurse -ErrorAction Stop))) {
	try {
		. $file.FullName;
		$publicFuncs += $file.Basename;
	}
	catch {
		throw "Unable to dot source proviso.core file: [$($file.FullName)]`rEXCEPTION: $_  `r$($_.ScriptStackTrace) ";
	}
}

# Export Funcs, Aliases, and Variables:

# temporary testing hacks:
$publicFuncs += "Register-RemoteSession";

Export-ModuleMember -Function $publicFuncs;
#
#Update-ModuleManifest -Path "$PSScriptRoot\proviso.core.psd1" -FunctionsToExport $publicFuncs;