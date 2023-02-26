Set-StrictMode -Version 1.0;

BeforeAll {
	$UnitName = (Split-Path -Leaf $PSCommandPath).Replace(".Tests.ps1", "");
	$uut = $PSCommandPath.Replace(".Tests.ps1", ".ps1").Replace("\tests\", "\");
	$root = ($PSCommandPath.Split("\tests"))[0];

	. $uut;
}

Describe "$UnitName Tests" -Tag "UnitTests" {
	
	Context "Has-ArrayValue Tests" {
		It "Returns False for Nulls" {
			Has-ArrayValue $null | Should -Be $false;
		}
		
		It "Returns False for Array of Empty Strings" {
			Has-ArrayValue -Value @("", "") | Should -Be $false;
		}
		
		It "Returns True for Value Found in One of Array Members" {
			Has-ArrayValue @("", "yup", "") | Should -Be $true;
		}
	}
	
	Context "Collapse-Arguments Tests" {
		It "Returns Nothing When Both Inputs are Empty/Null" {
			Collapse-Arguments $null $null | Should -Be $null;
		}
		
		It "Returns Empty String when Present" {
			Collapse-Arguments -Arg1 "" -Arg2 $null | Should -Be "";
		}
		
		It "Skips Empty Strings When -IgnoreEmptyStrings is True"{
			Collapse-Arguments -Arg1 "" -Arg2 $null -IgnoreEmptyStrings | Should -Be $null;
		}

		It "Returns First Value When Non-Empty" {
			Collapse-Arguments -Arg1 "10.10.0.128" -Arg2 "10.10.0.86" | Should -Be "10.10.0.128";
		}
		
		It "Returns Second Value When First Is Empty" {
			Collapse-Arguments -Arg1 "" -Arg2 "Found" -IgnoreEmptyStrings | Should -Be "Found";
		}
	}
}