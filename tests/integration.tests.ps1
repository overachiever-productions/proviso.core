Set-StrictMode -Version 1.0;

BeforeAll {
	$UnitName = (Split-Path -Leaf $PSCommandPath).Replace(".tests.ps1", "");
	$uut = $PSCommandPath.Replace(".tests.ps1", ".ps1").Replace("\tests\", "\");
	$root = ($PSCommandPath.Split("\tests"))[0];
	
	Import-Module -Name "$root" -Force;
}

Describe "Syntax-Validation Tests" -Tag "SyntaxValidation" {
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
	
	Context "Collections and Properties" {
		It "Allows Collections as Child of Facet" {
			Facets {
				Facet "Collection As Child - Test 1" {
					Collection {
						Membership {
							
						}
						Members {
							
						}
					}
				}
			}
		}
		
		It "Allows Collections as Child of Pattern" {
			Facets {
				Pattern "Collection As Child - Test2" {
					Topology {}
					Properties {
						Property "Collection-Child-Test2 - Prop A" {}
						Collection {
							Membership {}
							Members {}
						}
					}
				}
			}
		}
	}
}

Describe "Build Tests" -Tag "Build" {
	Context "Facets with Implicit Properties" {
		It "Builds Facets with Implicit Properties" {
			Facets {
				Facet "Implicit Property Test - A" -Impact High -ModelPath "Model.Attribute.A" {
				}
				Facet "Implicit Property Test - B" -Path "Model_And_Target.X" -Ignore "Pretend that this is Skipped for now." {
				}
				Facet "Implicit Property Test - C" -Display "{SELF}.Reflexive" -Expect "elevensies" -Extract "12" {
				}
				Facet "Implicit Property Test - D" -PreventConfig {}
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
			
			$sut.Properties[0].ModelPath | Should -Be "Model.Attribute.A";
			
			$sut = Get-Facet -Name "Implicit Property Test - B";
			$sut.ModelPath | Should -Be "Model_And_Target.X";
			$sut.TargetPath | Should -Be "Model_And_Target.X";
			
			$sut.Properties[0].TargetPath | Should -Be "Model_And_Target.X";
		}
		
		It "Sets -Impact Values for Implicit Properties" {
			$sut = Get-Facet -Name "Implicit Property Test - A";
			$sut.Impact | Should -Be "High";
			
			$sut.Properties[0].Impact | Should -Be "High";
		}
		
		It "Sets -Display Values for Implicit Properties" {
			$sut = Get-Facet -Name "Implicit Property Test - C";
			$sut.Display | Should -Be "{SELF}.Reflexive";
			
			$sut.Properties[0].Display | Should -Be "{SELF}.Reflexive";
		}
		
		It "Sets -Expect Values for Implicit Properties" {
			$sut = Get-Facet -Name "Implicit Property Test - C";
			$sut.Expect | Should -Be "return `"elevensies`";";
			
			$sut.Properties[0].Expect | Should -Be "return `"elevensies`";";
		}
		
		It "Sets -Extract Values for Implicit Properties" {
			$sut = Get-Facet -Name "Implicit Property Test - C";
			$sut.Extract | Should -BeLike "*12*";
			
			$sut.Properties[0].Extract | Should -BeLike "*12*";
		}
		
		It "Allows -PreventConfig to be Set for Implicit Properties" {
			$sut = Get-Facet -Name "Implicit Property Test - A";
			$sut.ThrowOnConfig | Should -Be $false;
			$sut.Properties[0].ThrowOnConfig | Should -Be $false;
			
			$sut = Get-Facet -Name "Implicit Property Test - D";
			$sut.ThrowOnConfig | Should -Be $true;
			$sut.Properties[0].ThrowOnConfig | Should -Be $true;
		}
	}
	
	Context "Basic Facet Tests" {
		It "Builds a Facet with Trivial Explicit Properties" {
			Facets {
				Facet "Simple Facet with 2x Properties" {
					Property "x" {
					}
					Property "y" {
					}
				}
			}
		}
				
		#It "Registers and Returns a Simple Facet with 2x Explicit Properties" {
		#	
		#}
		
		# It "Builds a Collection with a -Name"   # think I might remove ability to specify names for collections. Though... actually.. why NOT just LET them be there or not and Proviso simply doesn't DO anything with them - ever?
		# It "Builds a Collection WITHOUT a -Name"
		# It "Builds a Collection WITHOUT a -List (but requires a -TargetPath instead)?"
		# It "Builds a Collection With Explicit -List" (but what happens if there's also a -TargetPath?)
		# It "Builds a Collection With Explicit -Enumerate (again, what happens if there's a -ModelPath?"
		# 	etc.
	}
}

Describe "Block Tests" -Tag "Blocks" {
	Context "Properties" {
		It "Executes Very Simple Properties" {
			Facets {
				Facet "Very Basic" {
					Property "Very Basic - Canned" { }
				}
			}
			
			$outcome = Read-Facet "Very Basic" -Target "Canned Data";
			$outcome | Should -Not -Be $null;
			$outcome | Should -BeOfType Proviso.Core.FacetReadResult;
			
			$outcome.PropertyReadResults.Count | Should -Be 1;
			$outcome.PropertyReadResults[0].ExtractionResult.Result | Should -Be "Canned Data";
		}
		
		It "Can Extract -Path Values from Explicit Targets" {
			Facets {
				Facet "Basic Pathing" {
					Property "Uses Path" -Path "Username" { }
				}
			}
			
			$target = @{
				UserName = "Bilbo"
			};
			
			$outcome = Read-Facet "Basic Pathing" -Target $target;
			$outcome | Should -Not -Be $null;
			$outcome | Should -BeOfType Proviso.Core.FacetReadResult;
			
			$outcome.PropertyReadResults.Count | Should -Be 1;
			$outcome.PropertyReadResults[0].ExtractionResult.Result | Should -Be "Bilbo";
		}
		
		It "Throws When Attempting to Use a Path that -Target does NOT Contain" {
			{
				$outcome = Read-Facet "Basic Pathing" -Target "This a scalar string - but the Property itself has a Path expecting 'Username'.";
			} | Should -Throw "*does not have a property that matches*"
		}
		
		It "Does NOT execute Properties Marked with -Skip" {
			Facets {
				Facet "One shoe on, one shoe off" {
					Property "Shoe On" {}
					Property "Shoe Off" -Skip {}
				}
			}
			
			$outcome = Read-Facet "One shoe on, one shoe off" -Target "My son John.";
			$outcome | Should -Not -Be $null;
			$outcome | Should -BeOfType Proviso.Core.FacetReadResult;
			
			$outcome.PropertyReadResults.Count | Should -Be 1;
		}
		
		It "Treats -Ignore the same as -Skip" {
			Facets {
				Facet "Three blind mice" {
					Property "See how this one runs" {} 
					Property "This one runs too" {}
					Property "This one would run, except... " -Ignore "...the butcher's wife got it"	{}
				}
			}
			
			$outcome = Read-Facet "Three blind mice" -Target "Weird nursery rhyme";
			
			$outcome.PropertyReadResults.Count | Should -Be 2;
		}
		
	}
	
	Context "Collections" {
		
		
		It "Ignores all Collection Properties for a Collection marked -Skip/-Ignore" {
			# TODO: Implement this. 
			#  and make sure there's some similar bit of handling for ... facets or whatever? (can a facet be completely ignored?)
			# 		and... if it is... does that just mean "write-verbose: skipping this, skipping that, skipping N ... over and over - for each prop in the facet?"
			# 			or does it mean something different?
		}
	}
}


Describe "Functionality Tests" -Tag "Execution" {
	Context "Implicit Facets" {
		It "Executes Implicit Facets" {
			Facets {
				Facet "Implicit Facet - Execution A" -Display "35-Test" -Extract 35 {}
			}
			
			$outcome = Read-Facet "Implicit Facet - Execution A";
			$outcome | Should -Not -Be $null;
			$outcome | Should -BeOfType Proviso.Core.FacetReadResult;
			
			$outcome.PropertyReadResults.Count | Should -Be 1;
			$outcome.PropertyReadResults[0].Display | Should -Be "35-Test";
			
			$outcome.PropertyReadResults[0].ExtractionResult.Result | Should -Be 35;
		}
	}
}