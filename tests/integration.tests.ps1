Set-StrictMode -Version 1.0;

BeforeAll {
	$UnitName = (Split-Path -Leaf $PSCommandPath).Replace(".tests.ps1", "");
	$uut = $PSCommandPath.Replace(".tests.ps1", ".ps1").Replace("\tests\", "\");
	$root = ($PSCommandPath.Split("\tests"))[0];
	
	Import-Module -Name "$root" -Force;
}

Describe "Build Syntax Tests" -Tag "SyntaxValidation" {
	Context "Root-Nodes" {
		It "Allows Facets as Root Node" {
			Facets {
			}
		}
	}
	
	Context "Facet Child Nodes" {
		It "Allows Facet as a Child of Facets" {
			Facets {
				Facet "Facet-Child-Node-Test1" {
				}
			}
		}
		
		It "Allows Pattern as a Child of Facets" {
			Facets {
				Pattern "Facet-Child-Node-Pattern-Test1" {
				}
			}
		}
	}
}

Describe "Functionality Tests" -Tag "Functionality" {
	Context "Facets with Implicit Properties" {
		It "Builds Facets with Implicit Properties" {
			Facets {
				Facet "Implicit Property Test - A" -Impact High -ModelPath "Model.Attribute.A" {}
				Facet "Implicit Property Test - B" -Path "Model_And_Target.X" -Ignore "Pretend that this is Skipped for now." {}	
				Facet "Implicit Property Test - C" -Display "{SELF}.Reflexive" -Expect "elevensies" -Extract "12" {}
			}
		}
		
		It "Registers and Returns Facets with Implicit Properties" {
			$facetA = Get-Facet -Name "Implicit Property Test - A";
			$facetB = Get-Facet -Name "Implicit Property Test - B";
			$facetC = Get-Facet -Name "Implicit Property Test - C";
			
			$facetA | Should -Not -Be $null;
			$facetB | Should -Not -Be $null;
			$facetC | Should -Not -Be $null;
		}
		
		It "Sets Paths for Implicit Properties" {
			$sut = Get-Facet -Name "Implicit Property Test - A";
			$sut.ModelPath | Should -Be "Model.Attribute.A";
			
			$sut = Get-Facet -Name "Implicit Property Test - B";
			$sut.ModelPath | Should -Be "Model_And_Target.X";
			$sut.TargetPath | Should -Be "Model_And_Target.X";
		}
		
		It "Sets -Impact Values for Implicit Properties" {
			$sut = Get-Facet -Name "Implicit Property Test - A";
			
			$sut.Impact | Should -Be "High";
		}
		
		It "Sets -Display Values for Implicit Properties" {
			$sut = Get-Facet -Name "Implicit Property Test - C";
			$sut.Display | Should -Be "{SELF}.Reflexive";
		}
		
		It "Sets -Expect Values for Implicit Properties" {
			$sut = Get-Facet -Name "Implicit Property Test - C";
			$sut.Expect | Should -Contain "elevensies";
		}
		
		It "Sets -Extract Values for Implicit Properties" {
			$sut = Get-Facet -Name "Implicit Property Test - C";
			$sut.Expect | Should -Contain "12";
		}
		
		# TODO: Implement the functionality that'll make this test work:
		# It "Allows -PreventConfig to be Set for Implicit Properties" {
		# 	# create implicit facet D? (or maybe just use B?) ... and set -PreventConfig and/or one of the aliases for it... + verify that it 'sets'/sticks/etc. 
		# }
	}
	
	Context "Basic Facet Tests" {
		It "Builds a Facet with Trivial Explicit Properties" {
			Facets {
				Facet "Simple Facet with 2x Properties" {
					Property "x" { }
					Property "y" { }
				}
			}
		}
#		
#		It "Registers and Returns a Simple Facet with 2x Properties" {
#			
#		}
	}
}