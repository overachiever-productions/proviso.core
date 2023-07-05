#Set-StrictMode -Version 1.0;
#
#BeforeAll {
#	$UnitName = (Split-Path -Leaf $PSCommandPath).Replace(".Tests.ps1", "");
#	$uut = $PSCommandPath.Replace(".Tests.ps1", ".ps1").Replace("\tests\", "\public\");
#	$root = ($PSCommandPath.Split("\tests"))[0];
#	
#	. "$root\tests\_dependencies.ps1";
#	. $uut;
#}
#
#Describe "$UnitName Tests" -Tag "UnitTests" {
#	Context "Behavior Tests" {
##		It "Throws when Setup has a -Name" {
##			Surface "A Surface" {
##				Setup -Name "Should throw" { }
##				Facet "My Facet" {
##					
##				}
##			}
##		}
#	}	
#}