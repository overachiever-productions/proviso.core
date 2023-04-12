Set-StrictMode -Version 1.0;

function Cohort {
	[CmdletBinding()]
	param (
		[Parameter(Mandatory, Position = 0)]
		[string]$Name,
		[Parameter(Mandatory, Position = 1)]
		[ScriptBlock]$CohortBlock,
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
		$definition = New-Object Proviso.Core.Definitions.CohortDefinition($Name, [Proviso.Core.PropertyParentType]$parentBlockType, $parentName);
		
		Set-Definitions $definition -BlockType ($MyInvocation.MyCommand) -ModelPath $ModelPath -TargetPath $TargetPath `
						-Impact $Impact -Skip:$Skip -Ignore $Ignore -Expect $Expect -Extract $Extract -ThrowOnConfig $null `
						-DisplayFormat $DisplayFormat -Verbose:$xVerbose -Debug:$xDebug;
		
		$currentCohort = $definition;
		
		# BIND: 
		switch ($definition.ParentType) {
			"Cohorts" {
				Write-Debug "$(Get-DebugIndent)	NOT Binding Cohort: [$($definition.Name)] to parent, because parent is a Cohorts wrapper.";
			}
			"Facet" {
				Write-Debug "$(Get-DebugIndent)	Binding Cohort [$($definition.Name)] to Parent of Type [$parentType], named: [$($definition.ParentName)], with a grandparent named: [$($currentFacet.ParentName)].";
				
				$currentFacet.AddChildCohort($definition);
			}
			"Pattern" {
				Write-Debug "$(Get-DebugIndent)	Binding Cohort [$($definition.Name)] to Parent of Type [$parentType], named: [$($definition.ParentName)], with a grandparent named: [$($currentPattern.ParentName)].";
				
				$currentPattern.AddChildCohort($definition);
			}
			default {
				throw "Proviso Framework Error. Invalid Cohort Parent: [$($definition.ParentType)] specified.";
			}
		}
		
		# STORE: 
		if ($global:PvOrthography.StoreCohortDefinition($definition, (Allow-DefinitionReplacement))) {
			Write-Verbose "Cohort named [$Name] (within Facet [$($global:PvOrthography.GetCurrentFacet())]) was replaced.";
		}
		
		& $CohortBlock;
	};
	
	end {
		Exit-Block $MyInvocation.MyCommand -Name $Name -Verbose:$xVerbose -Debug:$xDebug;
	};
}