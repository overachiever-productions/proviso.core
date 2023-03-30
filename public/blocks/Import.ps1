Set-StrictMode -Version 1.0;

<#

	Used to allow the 'import' of a Facet (or Pattern) defined globally or from another Surface.

#>

function Import {
	[CmdletBinding()]
	param (
		# TODO: it MIGHT make sense to allow Imports via Facet -Id? (or maybe just check Id for a match if NAME isn't a match?)
		[Parameter(Mandatory, Position = 0)]
		[Alias("Facet", "Pattern", "FacetName", "PatternName")]
		[string]$Name,
		[string]$ModelPath = $null,
		[string]$TargetPath = $null,
		[string]$Path = $null,
		[ValidateSet("None", "Low", "Medium", "High")]
		[string]$Impact = "None",
		[switch]$Skip = $false,
		[string]$Ignore = $null,
		[string]$DisplayFormat = $null,
		[object]$Expect = $null,
		[object]$Extract = $null,
		[string]$ThrowOnConfig = $null,
		[Alias("NaiveIterator", "NaiveIterators")]
		[string[]]$Iterator = $null,
		[string[]]$ExplicitIterator = $null,
		[ValidateSet("Naive", "Explicit")]
		[string]$ComparisonType = "Naive"
	);
	
	begin {
		[bool]$xVerbose = ("Continue" -eq $global:VerbosePreference) -or ($PSBoundParameters["Verbose"] -eq $true);
		[bool]$xDebug = ("Continue" -eq $global:DebugPreference) -or ($PSBoundParameters["Debug"] -eq $true);
		
		Enter-Block ($MyInvocation.MyCommand) -Name $Name -Verbose:$xVerbose -Debug:$xDebug;
	};
	
	process {
		$definition = New-Object Proviso.Core.Definitions.FacetDefinition($Name, $Id, [Proviso.Core.FacetType]"Import");
		
		$definition.SurfaceName = $global:PvOrthography.GetCurrentSurface();
		$definition.AspectName = $global:PvOrthography.GetCurrentAspect();
		
		if ((Has-ArrayValue $Iterator) -or (Has-ArrayValue $ExplicitIterator)) {
			$definition.SetPatternMembershipType(([Proviso.Core.Membership]$ComparisonType));
			if ((Has-ArrayValue $Iterator) -and (Has-ArrayValue $ExplicitIterator)) {
				throw "Invalid Import (of Pattern): [$Name]. Specify either -[Naive]Iterator or -ExplicitIterator depending upon membership expectations. Only ONE option can be specifiied.";
			}
			if ((Has-ArrayValue $Iterator) -or (Has-ArrayValue $ExplicitIterator)) {
				$definition.SetPatternIteratorFromParameter((Collapse-Arguments -Arg1 $Iterator -Arg2 $ExplicitIterator));
			}
		}
		
		Set-Definitions $definition -BlockType ($MyInvocation.MyCommand) -ModelPath $ModelPath -TargetPath $TargetPath `
						-Impact $Impact -Skip:$Skip -Ignore $Ignore -Expect $Expect -Extract $Extract -ThrowOnConfig $ThrowOnConfig `
						-DisplayFormat $DisplayFormat -Verbose:$xVerbose -Debug:$xDebug;
		
		try {
			# TODO: 'imports' aren't being defined, they're being included/added to a surface.
			# 	so, these (like Facets|Patterns) HAVE to be added to the parent surface. period. 
			# 		Facets|Patterns ALSO have to be added to the $PvCatalog as well.
			
			throw "Import Logic NOT yet implemented.";
			
			Write-Verbose "Facet [$($definition.Name)] added to xxx.";
		}
		catch {
			throw "$($_.Exception.Message) `r`t$($_.ScriptStackTrace) ";
		}
	};
	
	end {
		Exit-Block $MyInvocation.MyCommand -Name $Name -Verbose:$xVerbose -Debug:$xDebug;
	};
}