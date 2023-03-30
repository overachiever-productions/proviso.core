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
		$definition = New-Object Proviso.Core.Definitions.PropertyDefinition($Name, [Proviso.Core.PropertyParentType]$parentBlockType, $parentName);
		
		Set-Definitions $definition -BlockType ($MyInvocation.MyCommand) -ModelPath $ModelPath -TargetPath $TargetPath `
						-Impact $Impact -Skip:$Skip -Ignore $Ignore -Expect $Expect -Extract $Extract -ThrowOnConfig $ThrowOnConfig `
						-DisplayFormat $DisplayFormat -Verbose:$xVerbose -Debug:$xDebug;
		
		$currentProperty = $definition;
		Bind-Property -Property $definition -Verbose:$xVerbose -Debug:$xDebug;
		
		& $PropertyBlock;
	};
	
	end {
		Exit-Block $MyInvocation.MyCommand -Name $Name -Verbose:$xVerbose -Debug:$xDebug;
	};
}

function Bind-Property {
	[CmdletBinding()]
	param (
		[Proviso.Core.Definitions.PropertyDefinition]$Property
	);
	
	process {
		try {
			switch ($Property.ParentType) {
				"Properties" {
					Write-Debug "$(Get-DebugIndent)	NOT Binding Property: [$($Property.Name)] to parent, because parent is a Properties wrapper.";
				}
				"Cohort" {
					$grandParentName = $global:PvOrthography.GetGrandParentBlockName();
					$parent = $global:PvOrthography.GetCohortDefinition($Property.ParentName, $grandParentName);
					
					Write-Debug "$(Get-DebugIndent)	Binding Property [$($Property.Name)] to parent Cohort, named: [$($Property.ParentName)], with grandparent named: [$grandParentName].";
					
					$parent.AddChildProperty($Property);
				}
				{
					$_ -in @("Facet", "Pattern")
				} {
					$parentType = $global:PvOrthography.GetParentBlockType();
					$grandParentName = $global:PvOrthography.GetGrandParentBlockName();
					$parent = $global:PvOrthography.GetFacetDefinitionByName($Property.ParentName, $grandParentName);
					
					Write-Debug "$(Get-DebugIndent)	Binding Property [$($Property.Name)] to Parent [$parentType], named: [$($Property.ParentName)], with grandparent named: [$grandParentName].";
					
					$parent.AddChildProperty($Property);
				}
				default {
					throw "Proviso Framework Error. Invalid Property Parent: [$($Property.ParentType)] specified.";
				}
			}
			
			if ($global:PvOrthography.StorePropertyDefinition($Property, (Allow-DefinitionReplacement))) {
				Write-Verbose "Property: [$Name] (within $($Property.PropertyParentType) [$($Property.ParentName)]) was replaced.";
			}
		}
		catch {
			throw "Exception in Bind-Property: $($_.Exception.Message) `r`t$($_.ScriptStackTrace) ";
		}
	}
}