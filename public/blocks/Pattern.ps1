Set-StrictMode -Version 1.0;

<# 
	
	The 'same' as a Facet, but acts as a 'template' against Iterator-filled 'versions' ... 

#>

function Pattern {
	[CmdletBinding()]
	[Alias("FacetPattern")]
	param (
		[Parameter(Mandatory, Position = 0)]
		[string]$Name,
		[Parameter(Mandatory, Position = 1)]
		[ScriptBlock]$PatternBlock,
		[string]$Id = $null,
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
		$parentName = $global:PvLexicon.GetParentBlockName();
		[Proviso.Core.FacetParentType]$parentType = Get-FacetParentType -FacetType ([Proviso.Core.FacetType]"Pattern");
		$definition = New-Object Proviso.Core.Definitions.FacetDefinition($Name, $Id, [Proviso.Core.FacetType]"Pattern", $parentType, $parentName);
		
		$definition.SetPatternMembershipType(([Proviso.Core.Membership]$ComparisonType));
		if ((Has-ArrayValue $Iterator) -and (Has-ArrayValue $ExplicitIterator)) {
			throw "Invalid Pattern: [$Name]. Specify either -[Naive]Iterator or -ExplicitIterator depending upon membership expectations. Only ONE option can be specifiied.";
		}
		if ((Has-ArrayValue $Iterator) -or (Has-ArrayValue $ExplicitIterator)) {
			$definition.SetPatternIteratorFromParameter((Collapse-Arguments -Arg1 $Iterator -Arg2 $ExplicitIterator));
		}
		
		Set-Definitions $definition -BlockType ($MyInvocation.MyCommand) -ModelPath $ModelPath -TargetPath $TargetPath `
						-Impact $Impact -Skip:$Skip -Ignore $Ignore -Expect $Expect -Extract $Extract -ThrowOnConfig $ThrowOnConfig `
						-DisplayFormat $DisplayFormat -Verbose:$xVerbose -Debug:$xDebug;
		
		try {
			Bind-Facet -Facet $definition -Verbose:$xVerbose -Debug:$xDebug;
			
			[bool]$replaced = $global:PvCatalog.StoreFacetDefinition($definition, (Allow-DefinitionReplacement));
			
			if ($replaced) {
				Write-Verbose "Facet named [$Name] was replaced.";
			}
			
			Write-Verbose "Facet [$($definition.Name)] added to PvCatalog.";
		}
		catch {
			throw "$($_.Exception.Message) `r`t$($_.ScriptStackTrace) ";
		}
		
		& $PatternBlock;
	};
	
	end {
		Exit-Block $MyInvocation.MyCommand -Name $Name -Verbose:$xVerbose -Debug:$xDebug;
	};
}