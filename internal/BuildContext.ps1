Set-StrictMode -Version 1.0;

<#
	Runbook
		[Setup]
		[Assertions]
			[Assert]
		Operations
			Implement 
			Implement
			Implement
		[Cleanup]

	Surface
		[Setup]
		[Assertions]
			[Assert]
		[Aspect]
			Facet | Pattern | [Import] -Pattern|Facet
				[Iterate] (for Pattern)
				[Add]	(Pattern)  - Install?
				[Remove] (Pattern) - Uninstall?
				Property | Cohort 
					Enumerate
					Add
					Remove
					Property (of Cohort - and... recurses)
					[Inclusion] (of Property | Cohort)
					Expect
					Extract
					[Compare]
					Configure

		[Cleanup]
#>

# REFACTOR: call this ... BuildManager or BlockManager or maybe ... SyntaxManager... 

$global:PvBuildContext = [Proviso.Core.BuildContext]::Current;

function Enter-Block {
	[CmdletBinding()]
	param (
		[Parameter(Mandatory)]
		[string]$Type,
		[string]$Name = $null
	);
	
	try {
		$PvBuildContext.EnterBlock($Type, $Name);
	}
	catch {
		throw "Proviso Exception: $($_.Exception.Message) `r`t$($_.ScriptStackTrace) ";
	}
	
	Write-Debug "$(Get-DebugIndent)Entered $($Type): [$Name]";
}

function Exit-Block {
	[CmdletBinding()]
	param (
		[Parameter(Mandatory)]
		[string]$Type,
		[string]$Name = $null
	);
	
	Write-Debug "$(Get-DebugIndent) Exiting $($Type): [$Name]";
	
	try {
		$PvBuildContext.ExitBlock($Type, $Name);
	}
	catch {
		throw "Proviso Exception: $($_.Exception.InnerException.Message) `r`t$($_.ScriptStackTrace) ";
	}
}

filter Get-CurrentBlockType {
	return $PvBuildContext.GetCurrentBlockType();
}

filter Get-ParentBlockType {
	return $PvBuildContext.GetParentBlockType();
}

filter Get-ParentBlockName {
	return $PvBuildContext.GetParentBlockName();
}

filter Get-GrandParentBlockType {
	return $PvBuildContext.GetGrandParentBlockType();
}

filter Get-GrandParentBlockName {
	return $PvBuildContext.GetGrandParentBlockName();
}

filter Get-DebugIndent {
	return "`t" * $PvBuildContext.CurrentDepth;
}

filter Get-FacetParentType {
	$ParentBlockType = $PvBuildContext.GetParentBlockType();
	try {
		return [Proviso.Core.FacetParentType]$ParentBlockType;
	}
	catch {
		# MKC: It APPEARs that I only need this additional bit of error handling for Pester tests:
		# 		Specifically: I can NOT get 'stand-alone' Facets|Patterns to reach this logic in anything other than Pester.
		throw "Compilation Exception. [$currentFacetType] can NOT be a stand-alone (root-level) block (must be inside either an Aspect, Surface, or $($currentFacetType)s block).";
	}
}

function Set-Declarations {
	[CmdletBinding()]
	param (
		[Parameter(Mandatory, Position = 0)]
		[Proviso.Core.IDeclarable]$iDeclarable,
		[parameter(Mandatory)]
		[string]$BlockType,
		[string]$ModelPath = $null,
		[string]$TargetPath = $null,
		[ValidateSet("None", "Low", "Medium", "High")]
		[string]$Impact = "None",
		[switch]$Skip = $false,
		[string]$Ignore = $null,
		[string]$Display = $null,
		[object]$Expect = $null,
		[object]$Extract = $null,
		[switch]$NoConfig = $false,
		[string]$ThrowOnConfigure = $null
	);
	
	if ((Is-Skipped $BlockType -Name $Name -Skip:$Skip -Ignore $Ignore -Verbose:$xVerbose -Debug:$xDebug)) {
		$iDeclarable.SetSkipped($Ignore);
	}
	
	if ((Throws-OnConfig $BlockType -Name $Name -NoConfig:$NoConfig -ThrowOnConfigure $ThrowOnConfigure -Verbose:$xVerbose -Debug:$xDebug)) {
		# NOTE: the code below is ... nuts/crazy. IDeclarable doesn't expose the .SetThrowOnConfig - but the OBJECT being passed in does... 
		$iDeclarable.SetThrowOnConfig($ThrowOnConfigure);
	}
	
	if (Should-SetPaths $BlockType -Name $Name -ModelPath $ModelPath -TargetPath $TargetPath -Path $Path -Verbose:$xVerbose -Debug:$xDebug) {
		$ModelPath, $TargetPath = $Path, $Path;
	}
	
	# TODO: send in $PvPreferences.PathSeparators as ... a 3rd argument here ... where "." is the default, but things like "\" and "/" could be legit options... 
	# 		.SetPaths is already set up to handle this, i just need to pass in the actual options (and spin up defaults + ways to set them, etc.)
	$iDeclarable.SetPaths($ModelPath, $TargetPath);
	
	if ($Impact -ne "None") {
		$iDeclarable.SetImpact(([Proviso.Core.Impact]$Impact));
	}
	
	if ($Display) {
		$iDeclarable.Display = $Display;
	}
	
	if ($Expect) {
		$iDeclarable.Expect = (Get-ReturnScript $Expect);
	}
	
	if ($Extract) {
		$iDeclarable.Extract = (Get-ReturnScript $Extract);
	}

	#$stack = ((Get-PSCallStack).Command -join ",") -replace "Enter-Block,"
	
	# TODO: Implement this LATER. It's a 'nice to have' - not something core/critical.
	# also... $PSCmdlet.MyInvocation.ScriptName? might be a better way? 
	# this is ... close. 
	# 		what I might actually want to do is ... 
	# 		in Enter-Block... capture the 'current (caller)' script-name/source via this approach (i.e., basically [1] vs [0])
	# 			and shove it into a variable... 
	# 			that I can then call via a func in Orthography.ps ... e.g., Get-CurrentBlockDefinitionScriptThingy... 
	# 		and then call that here... and ... shove it into $iDeclarable.SetSourceMetaDataAndOtherStuff($x, $y, $z-etc)
	#	$stack = (Get-PSCallStack).ScriptName -join "`n";
	#	
	
	# TODO: Comparison... 
	# TODO: Processing Order? 
}