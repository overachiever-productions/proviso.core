Set-StrictMode -Version 1.0;

BeforeAll {
	$UnitName = (Split-Path -Leaf $PSCommandPath).Replace(".Tests.ps1", "");
	$uut = $PSCommandPath.Replace(".Tests.ps1", ".ps1").Replace("\tests\", "\");
	$root = ($PSCommandPath.Split("\tests"))[0];
	
	Import-Module -Name "$root" -Force;
}