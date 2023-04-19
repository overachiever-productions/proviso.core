Set-StrictMode -Version 1.0;

function Property {
	[CmdletBinding()]
	param (
		[Parameter(Mandatory, Position = 0)]
		[string]$Name,
		[Parameter(Mandatory, Position = 1)]
		[ScriptBlock]$PropertyBlock,
		[string]$ModelPath = $null,
		[string]$TargetPath = $null,
		[string]$Path,
		[ValidateSet("None", "Low", "Medium", "High")]
		[string]$Impact = "None",
		[switch]$Skip = $false,
		[string]$Ignore = $null,
		[string]$DisplayFormat = $null,
		[object]$Expect,
		[object]$Extract,
		[string]$ThrowOnConfig = $null,
		[switch]$UsesAdd = $false,
		[switch]$UsesAddRemove = $false
	);
	
	begin {
		[bool]$xVerbose = ("Continue" -eq $global:VerbosePreference) -or ($PSBoundParameters["Verbose"] -eq $true);
		[bool]$xDebug = ("Continue" -eq $global:DebugPreference) -or ($PSBoundParameters["Debug"] -eq $true);
		Enter-Block $MyInvocation.MyCommand -Name $Name -Verbose:$xVerbose -Debug:$xDebug;
	};
	
	process {
		$parentBlockType = $global:PvOrthography.GetParentBlockType();
		$parentName = $global:PvOrthography.GetParentBlockName();
		$definition = New-Object Proviso.Core.Definitions.PropertyDefinition($Name, [Proviso.Core.PropertyType]"Property", [Proviso.Core.PropertyParentType]$parentBlockType, $parentName);
		
		Set-Definitions $definition -BlockType ($MyInvocation.MyCommand) -ModelPath $ModelPath -TargetPath $TargetPath `
						-Impact $Impact -Skip:$Skip -Ignore $Ignore -Expect $Expect -Extract $Extract -ThrowOnConfig $ThrowOnConfig `
						-DisplayFormat $DisplayFormat -Verbose:$xVerbose -Debug:$xDebug;
		
		$currentProperty = $definition;
		
		# BIND:
		switch ($parentBlockType) {
			"Properties" {
				Write-Debug "$(Get-DebugIndent)	NOT Binding Property: [$($definition.Name)] to parent, because parent is a Properties wrapper.";
			}
			"Cohort" {
				Write-Debug "$(Get-DebugIndent)	Binding Property: [$($definition.Name)] belonging to Cohort: [$($definition.ParentName)], to grandparent named: [$($currentCohort.ParentName)].";
				$grandparentBlockType = $global:PvOrthography.GetGrandParentBlockType();
				switch ($grandparentBlockType) {
					"Facet" {
						$currentFacet.AddProperty($definition);
					}
					"Pattern" {
						$currentPattern.AddProperty($definition);
					}
					default {
						throw "Proviso Framework Error. Invalid COHORT Property Parent: [$($Property.ParentType)] specified.";
					}
				}
			}
			"Facet" {
				Write-Debug "$(Get-DebugIndent)	Binding Property: [$($definition.Name)] to Facet, named: [$($definition.ParentName)], with grandparent named: [$grandParentName].";
				
				$currentFacet.AddProperty($definition);
			}
			"Pattern" {
				Write-Debug "$(Get-DebugIndent)	Binding Property: [$($definition.Name)] to Pattern, named: [$($definition.ParentName)], with grandparent named: [$grandParentName].";
				
				$currentPattern.AddProperty($definition);
			}
			default {
				throw "Proviso Framework Error. Invalid Property Parent: [$($Property.ParentType)] specified.";
			}
		}
		
		# STORE:
		# TODO: pretty sure properties NEED to be stored via their parent, right? 
		if ($global:PvOrthography.StorePropertyDefinition($definition, (Allow-DefinitionReplacement))) {
			Write-Verbose "Property: [$Name] (within $($Property.PropertyParentType) [$($Property.ParentName)]) was replaced.";
		}
		
		& $PropertyBlock;
	};
	
	end {
		Exit-Block $MyInvocation.MyCommand -Name $Name -Verbose:$xVerbose -Debug:$xDebug;
	};
}