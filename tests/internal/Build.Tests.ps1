#Set-StrictMode -Version 1.0;
#
#BeforeAll {
#	$UnitName = (Split-Path -Leaf $PSCommandPath).Replace(".Tests.ps1", "");
#	$uut = $PSCommandPath.Replace(".Tests.ps1", ".ps1").Replace("\tests\", "\");
#	$root = ($PSCommandPath.Split("\tests"))[0];
#	
#	Import-Module -Name "$root" -Force;
#}
#
#Describe "$UnitName Tests" -Tag "IntegrationTests" {
#	Context "Add Tests" {
#		It "Binds Enumerator Add to Parent Cohort" {
#			Cohorts {
#				Cohort "Global Property - Add Test 1" {
#					Enumerate { }
#					Add {
#						# code for Add implementation
#					}
#				}
#			}
#			
#			$sut = $global:PvOrthography.GetCohortDefinition("Global Property - Add Test 1", "");
#			
#			$sut | Should -Not -Be $null;
#			$add = $sut.Add;
#			
#			$add | Should -Not -Be $null;
#			$add.ScriptBlock | Should -BeLike "*Add implementation*";
#		}
#		
#		It "Does NOT Store Anonymous Add to Orthography-Store" {
#			Cohorts {
#				Cohort "Global Property - Add Test 2" {
#					Enumerate { }
#					Add {
#						# code for Add implementation
#					}
#				}
#			}
#			
#			$global:PvOrthography.GetEnumeratorAddDefinition("") | Should -Be $null;
#		}
#		
#		It "Stores Enumerator Add to Orthography-Store" {
#			Cohorts {
#				Cohort "Global Property - Add Test 3 " -Path "/something/{widget}/etc" {
#					Enumerate "widget" { }
#					Add "widget" {
#						# code for Add implementation
#					}
#				}
#			}
#			
#			$global:PvOrthography.GetEnumeratorAddDefinition("widget") | Should -Not -Be $null;
#		}
#	}
#}