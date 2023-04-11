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
		Bind-Cohort -Cohort $definition -Verbose:$xVerbose -Debug:$xDebug;
			
		& $CohortBlock;
	};
	
	end {
		Exit-Block $MyInvocation.MyCommand -Name $Name -Verbose:$xVerbose -Debug:$xDebug;
	};
}

function Bind-Cohort {
	[CmdletBinding()]
	param (
		[Proviso.Core.Definitions.CohortDefinition]$Cohort
	);
	
	process {
		try {
			switch ($Cohort.ParentType) {
				"Cohorts" {
					Write-Debug "$(Get-DebugIndent)	NOT Binding Cohort: [$($Cohort.Name)] to parent, because parent is a Cohorts wrapper.";
				}
				{
					$_ -in @("Facet", "Pattern")
				} {
					$parentType = $global:PvOrthography.GetParentBlockType();
					$grandParentName = $global:PvOrthography.GetGrandParentBlockName();
					$parent = $global:PvOrthography.GetFacetDefinitionByName($Cohort.ParentName, $grandParentName);
					
					Write-Debug "$(Get-DebugIndent)	Binding Cohort [$($Cohort.Name)] to Parent of Type [$parentType], named: [$($Cohort.ParentName)], with a grandparent named: [$grandParentName].";
					
					$parent.AddChildCohort($Cohort);
				}
				default {
					throw "Proviso Framework Error. Invalid Cohort Parent: [$($Cohort.ParentType)] specified.";
				}
			}
			
			if ($global:PvOrthography.StoreCohortDefinition($definition, (Allow-DefinitionReplacement))) {
				Write-Verbose "Cohort named [$Name] (within Facet [$($global:PvOrthography.GetCurrentFacet())]) was replaced.";
			}
		}
		catch {
			throw "Exception in Bind-Cohort: $($_.Exception.Message) `r`t$($_.ScriptStackTrace) ";
		}
	}
}