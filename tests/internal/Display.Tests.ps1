Set-StrictMode -Version 1.0;

BeforeAll {
	$UnitName = (Split-Path -Leaf $PSCommandPath).Replace(".Tests.ps1", "");
	$uut = $PSCommandPath.Replace(".Tests.ps1", ".ps1").Replace("\tests\", "\");
	$root = ($PSCommandPath.Split("\tests"))[0];
	
	. "$root\internal\Common.ps1";
	. $uut;
}

Describe "$UnitName Tests" -Tag "UnitTests" {
	Context "Validation Behaviors" {
		It "Requires defined Token when Single Curly Brackets Present" {
			{ Validate-DisplayTokenUse -Display "This {Token} is Not Defined."; } | Should -Throw "*does not match a defined Token*";
		}
		
		It "Ignores Double/Escaped Curly Brackets" {
			Validate-DisplayTokenUse -Display "This is NOT a {{TOKEN}} and should be ignored.";
		}
	}
	
	# NOTE: 
	# 	There are a few other unit tests I 'should' implement here - like confirming that {legit} tokens are replaced as expected. 
	# 	ONLY: that'd require fakes/mocks and/or importing .Context.ps1 and so on... 
	# 	ALL of which is more EFFORT than necessary when "integration.Tests.ps1" already TESTS this behavior soup to nuts.
}

