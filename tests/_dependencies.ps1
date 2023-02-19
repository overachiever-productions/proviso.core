Set-StrictMode -Version 1.0;

<#

	Loads all of the core/internals code (including CLR types) needed by public code. 

#>

$root = ($PSCommandPath.Split("\tests"))[0];

. "$root\proviso.core.meta.ps1";
. "$root\internal\BlockBases.ps1";
. "$root\internal\Common.ps1";
. "$root\internal\Lexicon.ps1";
. "$root\internal\Catalog.ps1";