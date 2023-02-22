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
		
		$definition = New-Object Proviso.Core.Definitions.PropertyDefinition($Name, $ModelPath, $TargetPath, $bypass, $Ignore);
		
		$definition.FacetName = $global:PvLexicon.GetCurrentFacet();
		$definition.CohortName = $global:PvLexicon.GetCurrentCohort();

		if ($Impact -ne "None") {
			$definition.Impact = [Proviso.Core.Impact]$Impact;
		}
		
		if ($Expect) {
			$definition.SetExpectFromParameter($Expect);
		}
		
		if ($Extract) {
			$definition.SetExtractFromParameter($Extract);
		}
		
		if ($ThrowOnConfig) {
			$definition.SetThrowOnConfig($ThrowOnConfig);
		}
		
		& $PropertyBlock;
	};
	
	end {
		try {
			[bool]$replaced = $global:PvCatalog.SetPropertyDefinition($definition, (Allow-DefinitionReplacement));
			
			if ($replaced) {
				Write-Verbose "Property named [$Name] (within Facet [$($global:PvLexicon.GetCurrentFacet())]) was replaced.";
			}
		}
		catch {
			throw "$($_.Exception.InnerException.Message) `r`t$($_.ScriptStackTrace) ";
		}
		
		Exit-Block $MyInvocation.MyCommand -Name $Name -Verbose:$xVerbose -Debug:$xDebug;
	};
}