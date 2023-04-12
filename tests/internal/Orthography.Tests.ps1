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
			Facets {
				Facet "Basic Facet" { }
			}
			
			$global:PvOrthography.GetFacetDefinitionByName("Basic Facet", $null) | Should -Not -Be $null;
		}
	}
	
	# These tests are used to 'lock in' behavior - i.e., will fail if something breaks behavior.
	Context "Validation Tests " {
		It "Stores Runbooks" {
			Runbook "Firewall Stuff" {
				Setup {	}
				Assertions {
					Assert "This" { };
				}
				
				Operations {
					Implement -Surface "Intellisense Name Here would be Great";
					Implement -SurfaceName "Surface to Process" -Impact "Medium";
					Implement "My Facet Name";
				}
				
				Cleanup {}
			}
			
			$global:PvOrthography.GetRunbookDefinition("Firewall Stuff") | Should -Not -Be $null;			
		}
		
		It "Stores Surfaces (and children)" {
			Surface "Test Surface 1" {
				Facet "Test Surface 1 - Facet A" {
					Property "Basic Property" {}
				}
			}
			
			#$global:PvOrthography.GetSurfaceDefinition("Test Surface 1") | Should -Not -Be $null;
			$global:PvOrthography.GetFacetDefinitionByName("Test Surface 1 - Facet A", "Test Surface 1") | Should -Not -Be $null;
		}
		
		It "Stores Facets" {
			Facets {
				Facet "Minimally Viable - 11" {
				};
				Facet "Minimally Viable - 12" {
				};
				Facet "Minimally Viable - 13" {
					Property "Property 14" {
					};
				}
			}
			
			$global:PvOrthography.GetFacetDefinitionByName("Minimally Viable - 11", $null) | Should -Not -Be $null;
			$global:PvOrthography.GetFacetDefinitionByName("Minimally Viable - 12", $null) | Should -Not -Be $null;
			$global:PvOrthography.GetFacetDefinitionByName("Minimally Viable - 13", $null) | Should -Not -Be $null;
		}
		
		It "Stores Patterns" {
			Facets {
				Pattern "Fake Pattern 1" -Iterator "Global Iterator that does not exist" { }
			}
			
			
			$pattern = $global:PvOrthography.GetFacetDefinitionByName("Fake Pattern 1", $null);
			$pattern | Should -Not -Be $null;
		}
	}
}