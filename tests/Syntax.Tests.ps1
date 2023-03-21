Set-StrictMode -Version 1.0;

BeforeAll {
	$UnitName = (Split-Path -Leaf $PSCommandPath).Replace(".Tests.ps1", "");
	$uut = $PSCommandPath.Replace(".Tests.ps1", ".ps1").Replace("\tests\", "\");
	$root = ($PSCommandPath.Split("\tests"))[0];
	
	Import-Module -Name "$root" -Force;
}

Describe "$UnitName Tests" -Tag "SyntaxTests" {
	Context "Wrapper Tests" {
		It "Allows Global Properties" {
			Properties {}
		}
		
		It "Allows Global Cohorts" {
			Cohorts {}
		}
		
		It "Allows Global Facets" {
			Facets {}
		}
		
		It "Allows Global Iterators" {
			Iterators {}
		}
		
		It "Allows Global Enumerators" {
			Enumerators {}
		}
	}
}