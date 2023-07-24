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
				
		It "Registers and Returns a Simple Facet with 2x Explicit Properties" {
			$sut = Get-Facet -Name "Simple Facet with 2x Properties";
			$sut | Should -Not -Be $null;
			$sut.Properties.Count | Should -Be 2;
		}
		
		It "Builds a Collection WITHOUT a -Name" {
			Facets {
				Facet "Nameless Collection" {
					Collection {
						Membership {}
						Members {
							Property "Nameless - A" {}
							Property "Nameless - B" {}
						}
					}
				}
			}
		}
		
		# REFACTOR: should I REMOVE the ability to have names for Collection Blocks? - as in THROW or not build if they're present?
		# I honestly can't see ANY reason to technically ALLOW names for Collection blocks. But, there's also no 'harm' in having them. 
		It "Builds a Collection with a -Name" { 
			Facets {
				Facet "Named Collection" {
					Collection "Named" {
						Membership {
						}
						Members {
							Property "Namee - A" {
							}
							Property "Named - B" {
							}
						}
					}
				}
			}
		}
		
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

Describe "Functionality Tests::Read" -Tag "Execution" {
	Context "Implicit Facets" {
		It "Reads Implicit Facets" {
			Facets {
				Facet "Implicit Facet - Execution A" -Display "35-Test" -Extract 35 {
				}
			}
			
			$outcome = Read-Facet "Implicit Facet - Execution A";
			$outcome | Should -Not -Be $null;
			$outcome | Should -BeOfType Proviso.Core.FacetReadResult;
			
			$outcome.PropertyReadResults.Count | Should -Be 1;
			$outcome.PropertyReadResults[0].Display | Should -Be "35-Test";
			
			$outcome.PropertyReadResults[0].ExtractionResult.Result | Should -Be 35;
		}
		
		# TODO: Test-Facet tests...
		
		# TODO: Invoke-Facet tests....
	}
	
	Context "Explicit Facets - With Simple Properties" {
		It "Reads Simple Facets with Simple Properties" {
			Facets {
				Facet "Simple Facet - With Simple Properties" {
					Property "Simple::Simple:A" {
					}
					Property "Simple::Simple:B" {
					}
				}
			}
			
			$outcome = Read-Facet "Simple Facet - With Simple Properties" -Target "Simple_Value";
			$outcome | Should -Not -Be $null;
			$outcome | Should -BeOfType Proviso.Core.FacetReadResult;
			
			$outcome.PropertyReadResults.Count | Should -Be 2;
			
			$outcome.PropertyReadResults[0].ExtractionResult.Result | Should -Be "Simple_Value";
			$outcome.PropertyReadResults[1].ExtractionResult.Result | Should -Be "Simple_Value";
		}
	}
	
	Context "Explicit Facets - With Collections" {
		It "Reads Simple Facets with Simple Collections" {
			Facets {
				Facet "Simple Facet - With a Simple Collection" {
					Collection {
						Membership {
							List {
								return @("A", "B");
							}
						}
						Members {
							Property "PropName" -Display "{COLLECTION.MEMBER}-{SELF}" {
							}
						}
					}
				}
			}
			
			$outcome = Read-Facet "Simple Facet - With a Simple Collection" -Target "Collection-A";
			$outcome | Should -Not -Be $null;
			$outcome | Should -BeOfType Proviso.Core.FacetReadResult;
			
			$outcome.PropertyReadResults.Count | Should -Be 2;
			
			$outcome.PropertyReadResults[0].ExtractionResult.Result | Should -Be "Collection-A";
			$outcome.PropertyReadResults[1].ExtractionResult.Result | Should -Be "Collection-A";
		}
		
		It "Processes -Display Properties for Collection Members" {
			$outcome = Read-Facet "Simple Facet - With a Simple Collection" -Target "Collection-A";
			
			$outcome.PropertyReadResults[0].Display | Should -Be "A-PropName";
			$outcome.PropertyReadResults[1].Display | Should -Be "B-PropName";
		}
		
		It "Enumerates Collection Items" {
			$global:LocalUsers = @("Administrator", "Mike");
			$global:LocalAdmins = @("Administrator", "BUILTIN\Admins");
			
			Facets {
				Facet "Local Admins - Enum Test" {
					Collection -ModelPath "Host.LocalAdministrators" {
						Membership -Strict {
							List {
								return $global:LocalAdmins;
							}
						}
						Members {
							Property "Enum-Test: Account Exists" -Expect $true {
								Extract {
									$target = $PVCurrent.Collection.CurrentMember;
									
									return $global:LocalUsers -contains $target;
								}
							}
							Property "IsLocalAdmin" -Expect $true -Display "{COLLECTION.MEMBER}.{SELF}" {
								Extract {
									$target = $PVCurrent.Collection.CurrentMember;
									
									return $global:LocalAdmins -contains $target;
								}
							}
						}
					}
				}
			}
			
			$outcome = Read-Facet "Local Admins - Enum Test";
			$outcome | Should -Not -Be $null;
			$outcome | Should -BeOfType Proviso.Core.FacetReadResult;
			
			$outcome.PropertyReadResults.Count | Should -Be 4;
		}
		
		It "Binds -Display Properties to Enumeration Items" {
			$outcome = Read-Facet "Local Admins - Enum Test";
			
			$outcome.PropertyReadResults[1].Display | Should -Be "Administrator.IsLocalAdmin";
			$outcome.PropertyReadResults[3].Display | Should -Be "BUILTIN\Admins.IsLocalAdmin";
		}
	}
	
	Context "Explicit Facets - With Collections and Properties" {
		
	}
	
	Context "Explicit Patterns - With Properties" {
		It "Iterates Pattern Instances" {
			$global:PretendActualXeSessions = @{
				"MSSQLSERVER" = @{
					"BlockedProcesses" = @{
						Name	    = "blocked_processes"
						StartWithOS = $true
						Enabled	    = $true
						Definition  = "Pretend SQL Would Go Here"
						XelFilePath = "D:\Traces\blocked_processes.xel"
					}
					
					"LongRunningOperations" = @{
						Name	    = "long_running_operations"
						StartWithOS = $true
						Enabled	    = $false
						Definition  = "Pretend SQL def here too"
						XelFilePath = "G:\Traces\long.xel"
					}
				}
				"X3"		  = @{
					"BlockedProcesses" = @{
						Name	    = "BlockedProcesses"
						StartWithOS = $true
						Enabled	    = $true
						Definition  = "Pretend SQL Would Go Here"
						XelFilePath = "D:\Traces\blocked_processes.xel"
					}
				}
			}
			
			# PRETEND FUNCTIONS. (i.e., pretend that these interact with an actual OS and such...)
			function Get-PrmInstalledSqlInstances {
				return $global:PretendActualXeSessions.Keys;
			}
			
			function Get-PrmXeSessionNamesBySqlInstance {
				param (
					[string]$SqlInstance
				);
				return $global:PretendActualXeSessions[$sqlInstance].Keys;
			}
			
			function Get-PrmXeSessionDetailsForSqlInstance {
				param (
					[string]$SqlInstance,
					[string]$XeSessionName
				);
				
				# obviously, the logic for this 'in the real world' would be a bit more complex... 
				return $global:PretendActualXeSessions.$SqlInstance.$XeSessionName;
			};
			
			Facets {
				Pattern "Fake XE Sessions By SQL Instance" {
					Topology {
						Instance "SQLInstances" -DefaultInstance "MSSQLSERVER" {
							List {
								return Get-PrmInstalledSqlInstances;
							}
						}
						
						Instance "XeSessions" {
							List {
								# NOTE: Because this is the SECOND instance defined, it's a CHILD, and requires that we enumerate values from/for the current PARENT instance:
								$sqlInstance = $PvCurrent.SqlInstances.Name;
								
								return Get-PrmXeSessionNamesBySqlInstance -SqlInstance $sqlInstance;
								# and... note that the above COULD, in theory, be EMPTY. As in, I need to determine how to let 'authors' specify that or not. 								
							}
						}
					}
					Properties {
						# TODO: turn this into an inclusion... 
						Property "Exists" -Display "{INSTANCE[SqlInstances].NAME}.{INSTANCE[XeSessions].NAME}.SessionName" {
							Extract {
								$session = Get-PrmXeSessionDetailsForSqlInstance -SqlInstance ($PvCurrent.SqlInstances.Name) -XeSessionName ($PvCurrent.XeSessions.Name);
								return $session.Name;
							}
						}
						Property "StartsWithOS" -Display "{INSTANCE[SqlInstances].NAME}.{INSTANCE[XeSessions].NAME}.{SELF}" {
							Extract {
								$session = Get-PrmXeSessionDetailsForSqlInstance -SqlInstance ($PvCurrent.SqlInstances.Name) -XeSessionName ($PvCurrent.XeSessions.Name);
								return $session.StartWithOS;
							}
						}
						Property "Enabled" -Display "{INSTANCE[SqlInstances].NAME}.{INSTANCE[XeSessions].NAME}.{SELF}"{
							Extract {
								$session = Get-PrmXeSessionDetailsForSqlInstance -SqlInstance ($PvCurrent.SqlInstances.Name) -XeSessionName ($PvCurrent.XeSessions.Name);
								return $session.Enabled;
							}
						}
#						Collection {
#						}
					}
				}
			}
			
			$outcome = Read-Facet "Fake XE Sessions By SQL Instance";
			$outcome | Should -Not -Be $null;
			$outcome | Should -BeOfType Proviso.Core.FacetReadResult;
			
			$outcome.PropertyReadResults.Count | Should -Be 9;
		}
		
		It "Uses -DefaultInstance when No Other Instances Present" {
			Facets {
				Pattern "Default Instance Test" {
					Topology {
						Instance "SQLInstances" -DefaultInstance "MSSQLSERVER" {
							List {
								# pretend function to return all SQL Instances... only, there are NONE (currently): 
								return @();
							}
						}
					}
					Properties {
						# we'd expect this to be installed, but... it isn't (yet). 
						Property "IsInstalled" -Expect $true -Display "{INSTANCE[SqlInstances].NAME}.{SELF}" {
							Extract {
								$sqlInstance = $PvCurrent.SqlInstances.Name;
								
								# pretend func to return $true/$false for Is-SqlInstanceInstalled -Name $sqlInstance: 
								return $false;
							}
						}
					}
				}
			}
			
			$outcome = Read-Facet "Default Instance Test";
			$outcome | Should -Not -Be $null;
			$outcome | Should -BeOfType Proviso.Core.FacetReadResult;
			
			$outcome.PropertyReadResults.Count | Should -Be 1;
			
			$outcome.PropertyReadResults[0].Display | Should -Be "MSSQLSERVER.IsInstalled";
			$outcome.PropertyReadResults[0].ExtractionResult.Result | Should -Be $false;
		}
		
		It "Throws when No Instances Found and -DefaultInstance is not Specified" {
			Facets {
				Pattern "Default Instance Test - Without -DefaultInstance Specified" {
					Topology {
						Instance "SQLInstances" {
							List {
								# pretend function to return all SQL Instances... only, there are NONE (currently): 
								return @();
							}
						}
					}
					Properties {
						Property "IsInstalled" -Expect $true -Display "{INSTANCE[SqlInstances].NAME}.{SELF}" {
							Extract {
								return $false;
							}
						}
					}
				}
			}
			
			{ Read-Facet "Default Instance Test - Without -DefaultInstance Specified"; } | Should -Throw "*and a -DefaultInstance was not specified*"
		}
	}
	
	Context "Explicit Patterns - With Collections and Properties" {
		
	}
}

# TODO: Test-Facet tests...

# TODO: Invoke-Facet tests....