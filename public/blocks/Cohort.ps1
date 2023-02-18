Set-StrictMode -Version 1.0;

function Cohort {
	[CmdletBinding()]
	param (
		[Parameter(Mandatory, Position = 0)]
		[string]$Name,
		[Parameter(Mandatory, Position = 1)]
		[ScriptBlock]$ScriptBlock,
		[string]$ModelPath = $null,
		[string]$TargetPath = $null,
		[string]$Path,
		[string]$DisplayFormat = $null,
		[ValidateSet("None", "Low", "Medium", "High")]
		[string]$Impact = "None",
		[switch]$Skip = $false,
		[string]$Ignore = $null,
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
		$bypass = Is-ByPassed $MyInvocation.MyCommand.Name -Name $Name -Skip:$Skip -Ignore $Ignore -Verbose:$xVerbose -Debug:$xDebug;
		
		if (Should-SetPaths $MyInvocation.MyCommand.Name -Name $Name -ModelPath $ModelPath -TargetPath $TargetPath -Path $Path -Verbose:$xVerbose -Debug:$xDebug) {
			$ModelPath, $TargetPath = $Path;
		}
		
		$cohortDefinition = New-Object Proviso.Core.Definitions.CohortDefinition($Name, $ModelPath, $TargetPath, $bypass, $Ignore);
		
		$cohortDefinition.FacetName = $global:PvLexicon.GetCurrentFacet();
		
		if ($Impact -ne "None") {
			$cohortDefinition.Impact = [Proviso.Core.Impact]$Impact;
		}
		
		if ($Expect) {
			$cohortDefinition.SetExpectFromParameter($Expect);
		}
		
		if ($Extract) {
			$cohortDefinition.SetExtractFromParameter($Extract);
		}
		
		if ($ThrowOnConfig) {
			$cohortDefinition.SetThrowOnConfig($ThrowOnConfig);
		}
		
		& $ScriptBlock;
	};
	
	end {
		$global:PvCatalog.AddCohortDefinition($cohortDefinition);
		
		Exit-Block $MyInvocation.MyCommand -Name $Name -Verbose:$xVerbose -Debug:$xDebug;
	};
}