Set-StrictMode -Version 1.0;

BeforeAll {
	$UnitName = (Split-Path -Leaf $PSCommandPath).Replace(".Tests.ps1", "");
	$uut = $PSCommandPath.Replace(".Tests.ps1", ".ps1").Replace("\tests\", "\public\");
	$root = ($PSCommandPath.Split("\tests"))[0];
	
	. "$root\tests\_dependencies.ps1";
	
	. "$root\public\blocks\Facet.ps1";
	. "$root\public\blocks\Cohort.ps1";
Write-Host "uut: $uut"	
	. $uut;
}

Describe "$UnitName Tests" -Tag "UnitTests" {
	BeforeEach {
		
	}
	
	Context "Behavior Tests" {
		It "Allows Empty Script Blocks" {
			# Justification: CAN be empty/placeholder at COMPILE time; if still empty at Discovery, will throw.
			Facet "Test 1" {
				Cohort "First Test Cohort" {
					Enumerate {
					}
				}
			}
		}
		
		It "Allows Empty -Name Property" {
			# Justification: Enumerate's can be anonymous (i.e., only in scope of their parent cohort).
			Facet "Test 2" {
				Cohort "Second Test Cohort" {
					Enumerate { # there's no name for this enumerate
					}
				}
			}
		}
		
		It "Uses Cohort's -Name when -Name Empty" {
			Facet "Test 3" {
				Cohort "Another Test Cohort" {
					Enumerate {
						# no name - so, should inherit from Cohort... 
					}
				}
			}
			
			$enumerate = $global:PvCatalog.GetEnumerator("Another Test Cohort");
			
			$enumerate | Should -Not -BeNullOrEmpty;
			$enumerate.Name | Should -Be "Another Test Cohort";
		}
		
		It "Can Have an Explicit -Name Defined" {
			Facet "Test 4" {
				Cohort "Yet Another Test Cohort" {
					Enumerate "Explicitly Named" {
					}
				}
			}
		}
		
		It "Can Have Explicit -Name which is Same as Cohort" {
			Facet "Test 5" {
				Cohort "Members of SysAdmin" {
					Enumerate "Members of SysAdmin" {
					}
				}
			}
		}
		
		It "Is Global when Explicit -Name is Defined" {
			Facet "Test 6" {
				Cohort "SysAdmins" {
					Enumerate "Enumerate Members of SysAdmin" {
					}
				}
			}
			
			$extracted = $global:PvCatalog.GetEnumerator("Enumerate Members of SysAdmin");
			$extracted.IsGlobal | Should -Be $true;
		}
		
#		It "Reports When EnumeratorDefinition Is Replaced" {
#			# TODO: implement (via ... mocking calls to either: Write-Verbose or Write-PvVerbose (probably the latter makes the most sense)
#		}
	}
}