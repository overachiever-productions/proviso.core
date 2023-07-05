Set-StrictMode -Version 1.0;

BeforeAll {
	$UnitName = (Split-Path -Leaf $PSCommandPath).Replace(".tests.ps1", "");
	$uut = $PSCommandPath.Replace(".tests.ps1", ".ps1").Replace("\tests\", "\");
	$root = ($PSCommandPath.Split("\tests"))[0];
}

Describe "$UnitName Tests" -Tag "UnitTests" {
	It "Correctly Compares Static Content" {
		"Static" | Should -Be "Static";
	}
	
	It "Correctly Maps Command Name from Path" {
		$UnitName | Should -Be "environment";
	}
	
	It "Correctly Derives UUT Path" {
		$uut | Should -BeLike "*environment.ps1";
	}
}