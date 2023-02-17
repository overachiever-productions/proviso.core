Set-StrictMode -Version 1.0;

BeforeAll {
	$UnitName = (Split-Path -Leaf $PSCommandPath).Replace(".Tests.ps1", "");
	$uut = $PSCommandPath.Replace(".Tests.ps1", ".ps1").Replace("\tests\", "\public\");
	$root = ($PSCommandPath.Split("\tests"))[0];
	
	. $uut;
	. "$root\private\Orthography.ps1";
	. "$root\private\HelperMethods.ps1";
}

# TODO: calls into Orthography and Catalog are ... almost integration tests... 
Describe "$UnitName Tests" -Tag "UnitTests" {
	Context "Dependency Checks" {
		BeforeEach {
			Mock -CommandName Confirm-Orthography -MockWith {
				return $null;
			};
		}
		
		It "Calls Confirm-Orthography" {
			Facet "Test Facet";
			
			Assert-MockCalled -CommandName Confirm-Orthography -Times 1 -ParameterFilter { $CurrentFunc -eq "Facet" };
		}
	}
}