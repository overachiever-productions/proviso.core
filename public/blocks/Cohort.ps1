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
		$parentBlockType = $global:PvLexicon.GetParentBlockType();
		$parentName = $global:PvLexicon.GetParentBlockName();
		$definition = New-Object Proviso.Core.Definitions.CohortDefinition($Name, [Proviso.Core.PropertyParentType]$parentBlockType, $parentName);
		
		Set-Definitions $definition -BlockType ($MyInvocation.MyCommand) -ModelPath $ModelPath -TargetPath $TargetPath `
						-Impact $Impact -Skip:$Skip -Ignore $Ignore -Expect $Expect -Extract $Extract -ThrowOnConfig $ThrowOnConfig `
						-DisplayFormat $DisplayFormat -Verbose:$xVerbose -Debug:$xDebug;
		
		try {
			Bind-Cohort -Cohort $definition -Verbose:$xVerbose -Debug:$xDebug;
			
			# TODO: verify that cohorts are stored in catalog via name + PARENT-name
			[bool]$replaced = $global:PvCatalog.StoreCohortDefinition($definition, (Allow-DefinitionReplacement));
			
			if ($replaced) {
				Write-Verbose "Cohort named [$Name] (within Facet [$($global:PvLexicon.GetCurrentFacet())]) was replaced.";
			}
		}
		catch {
			throw "$($_.Exception.InnerException.Message) `r`t$($_.ScriptStackTrace) ";
		}
		
		& $CohortBlock;
	};
	
	end {
		Exit-Block $MyInvocation.MyCommand -Name $Name -Verbose:$xVerbose -Debug:$xDebug;
	};
}