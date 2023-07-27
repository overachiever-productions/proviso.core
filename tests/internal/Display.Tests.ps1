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
	
	#	Context "Basic Functionality" {
#		
#	}
	
#	Context "Curly Bracket Escaping" {
#		It "Requires Matching Token for Single Curly Brackets" {
#			
#		}
#		
#		It "Escapes Doubled Curly Brackets" {
#			
#		}
#	}
}


<#

	[PSCustomObject]$global:PVCurrent = New-Object -TypeName PSCustomObject;
	[PSCustomObject]$global:PVContext = New-Object -TypeName PSCustomObject;
	Add-Member -InputObject $PVContext -MemberType NoteProperty -Name Current -Value $PVCurrent;

	Write-Host "-----------------------"
	#Validate-DisplayTokenUse -Display "does {{ have curly}} brackets for {SELF}";
	#Validate-DisplayTokenUse -Display "{COLLECTION.CURRENT.MEMBER}.IsSomething";

	Process-DisplayTokenReplacements -Display "no tokens but {{escaped curly brackets}}";

	Write-Host "-----------------------"
	Process-DisplayTokenReplacements -Display "{SELF} token AND: {{escaped curly brackets}}";


#>