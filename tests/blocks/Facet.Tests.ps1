Set-StrictMode -Version 1.0;

BeforeAll {
	$UnitName = (Split-Path -Leaf $PSCommandPath).Replace(".Tests.ps1", "");
	$uut = $PSCommandPath.Replace(".Tests.ps1", ".ps1").Replace("\tests\", "\public\");
	$root = ($PSCommandPath.Split("\tests"))[0];
	
	. "$root\tests\_dependencies.ps1";
	. "$root\public\blocks\Facets.ps1";
	. $uut;
}

Describe "$UnitName Tests" -Tag "UnitTests" {
	Context "Dependency Checks" {
		BeforeEach {
#			Mock -CommandName Enter-Block -ParameterFilter { $Type -eq "Facets" } -MockWith {
#				Write-Host "calling for Facets... "
#				return $null;
#			}
			
			Mock -CommandName Enter-Block <#-ParameterFilter { $Type -eq "Facet" } #> -MockWith {
				#Write-Host "calling for Facet"
				return $null;
			};
			
			Mock -CommandName Exit-Block -MockWith {
				return $null;
			}
			
			Mock -CommandName Get-FacetParentType -MockWith {
				return "Facets";
			}
		}
		
		It "Calls Enter-Block" {
			Facets {
				Facet "Test Facet" { };
			}
			
			Assert-MockCalled -CommandName Enter-Block -Times 1 -ParameterFilter { $Type -eq "Facet" };
		}
	}
}