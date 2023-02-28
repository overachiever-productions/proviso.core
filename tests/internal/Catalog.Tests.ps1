Set-StrictMode -Version 1.0;

BeforeAll {
	$UnitName = (Split-Path -Leaf $PSCommandPath).Replace(".Tests.ps1", "");
	$uut = $PSCommandPath.Replace(".Tests.ps1", ".ps1").Replace("\tests\", "\");
	$root = ($PSCommandPath.Split("\tests"))[0];
	
	Import-Module -Name "$root" -Force;
}

Describe "$UnitName Tests" -Tag "IntegrationTests" {
	Context "Behavior Tests" {
		It "Stores Basic Details For Retrieval" {
			Facet "Basic Facet" { }
			
			$global:PvCatalog.GetFacetDefinitionByName("Basic Facet") | Should -Not -Be $null;
		}
	}
	
	# 'candy shell' to help surface anything that breaks functionality during future dev.
	Context "Validation Tests " {
		It "Stores Facets As Expected" {
			Surface "Test Surface 1" {
				Facet "Test Surface 1 - Facet A" {
					Property "Basic Property" {}
				}
			}
			
			$global:PvCatalog.GetSurfaceDefinition("Test Surface 1") | Should -Not -Be $null;
			$global:PvCatalog.GetFacetDefinitionByName("Test Surface 1 - Facet A") | Should -Not -Be $null;
		}
	}
	
}