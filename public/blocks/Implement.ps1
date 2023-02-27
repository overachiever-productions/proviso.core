Set-StrictMode -Version 1.0;

<#

	Allows 'Execution' of a Surface from within a Runbook.

	REFACTOR: MIGHT change this to 'Run' - i.e., that's what a RUNbook does... 

	TODO:
		Enable creation of 'proxy' funcs - in the form of either Implement-<RunbookName> or Run-<RunbookName>
			As in, Proviso.Core will provide 'plumbing' to make this possible. 
			Then, say, Proviso.SQL will create surfaces and ... even some basic runbooks. 
				BUT, it'll also 'dump'/create proxies for each of the surfaces defined. 
			At which point, an 'end user' of Proviso.SQL can create their OWN runbooks with 'intellisense' via the Run-SomeSurface calls vs Run "SomeSurffface" and get typos/etc. 

#>

function Implement {
	[CmdletBinding()]
	param (
		[Parameter(Mandatory, Position = 0, ParameterSetName = 'Default')]
		[Alias("Surface")]
		[string]$SurfaceName,
		# NOTE: an Implement|Run can re-specify params like displayFormats, impact, and ... paths. Some of those make tons of sense (displayFormat, Impact)
		# 		but, allowing paths to be redefined MIGHT end up being really stupid(TM) - in which case, I'll remove that options/capability.
		[string]$ModelPath = $null,
		[string]$TargetPath = $null,
		[string]$Path,
		[string]$DisplayFormat = $null,
		[ValidateSet("None", "Low", "Medium", "High")]
		[string]$Impact = "None",
		[switch]$Skip = $false,
		[string]$Ignore = $null
	);
	
	begin {
		[bool]$xVerbose = ("Continue" -eq $global:VerbosePreference) -or ($PSBoundParameters["Verbose"] -eq $true);
		[bool]$xDebug = ("Continue" -eq $global:DebugPreference) -or ($PSBoundParameters["Debug"] -eq $true);
		
		Enter-Block $MyInvocation.MyCommand -Name $SurfaceName -Verbose:$xVerbose -Debug:$xDebug;
	};
	
	process {
		$grandParentBlockType = Get-GrandParentBlockType;
		$grandParentBlockName = Get-GrandParentBlockName;
		
		Write-Verbose "Compiling Facet Inclusion for Surface [$SurfaceName] via Implement for Runbook: [$grandParentBlockName].";
		
		[Proviso.Core.Definitions.ImplementDefinition]$definition = New-Object Proviso.Core.Definitions.ImplementDefinition($SurfaceName);
		
		Set-Definitions $definition -BlockType ($MyInvocation.MyCommand) -ModelPath $ModelPath -TargetPath $TargetPath `
						-Impact $Impact -Skip:$Skip -Ignore $Ignore -Expect $Expect -Extract $Extract -ThrowOnConfig $null `
						-DisplayFormat $DisplayFormat -Verbose:$xVerbose -Debug:$xDebug;
		
		try{
			$runbook.AddFacetImplementationReference($definition);
		}
		catch {
			throw "$($_.Exception.Message) `r`t$($_.ScriptStackTrace) ";
		}
	};
	
	end {
		Exit-Block $MyInvocation.MyCommand -Name $SurfaceName -Verbose:$xVerbose -Debug:$xDebug;
	};
}