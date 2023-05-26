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
		[string]$DisplayFormat = $null,
		[object]$Expect = $null,
		[object]$Extract = $null,
		[switch]$NoConfig = $false,
		[string]$ThrowOnConfigure = $null
	);
	
	if ((Is-Skipped $BlockType -Name $Name -Skip:$Skip -Ignore $Ignore -Verbose:$xVerbose -Debug:$xDebug)) {
		$iDeclarable.SetSkipped($Ignore);
	}
	
	if ((Throws-OnConfig $BlockType -Name $Name -NoConfig:$NoConfig -ThrowOnConfigure $ThrowOnConfigure -Verbose:$xVerbose -Debug:$xDebug)) {
		# NOTE: the code below is ... nuts/crazy. IDeclarable doesn't expose the methods being called - but the OBJECT being passed in does... 
		$iDeclarable.SetThrowOnConfig($ThrowOnConfigure);
	}
	
	if (Should-SetPaths $BlockType -Name $Name -ModelPath $ModelPath -TargetPath $TargetPath -Path $Path -Verbose:$xVerbose -Debug:$xDebug) {
		$ModelPath, $TargetPath = $Path, $Path;
	}
	
	$iDeclarable.SetPaths($ModelPath, $TargetPath);
	
	if ($Impact -ne "None") {
		$iDeclarable.SetImpact(([Proviso.Core.Impact]$Impact));
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

filter Get-ReturnScript {
	param (
		[Parameter(Mandatory, Position = 0)]
		[Object]$Object
	);
	
<#
	
					$expect = $facet.Expect;
					$script = "return $expect;";
					
					# NOTE: I was hoping/thinking that whatever I did via the above would let $expect be ... whatever $expect is/was - i.e., let CLR handle the type-safety and just 'forward it on'
					# 	and such. 
					# 		that won't be the case - i.e., in the code above, what if $facet.Expect = "I'm a teapot, short and stout."?
					# 			if it is... the code above will not 'compile' via Script::CREATE() below. 
					# 		so... i'm stuck with then trying to figure out if $expect is a string or not... and wrapping accordingly. 
					
					# there's ANOTHER option. 
					# 	and it's borderline insane. But, then again, maybe ... not. 
					# Assume a $global:PvDictionary<Guid, object>. 
					# 	 at which point, I could do something like: 
					$key = Add-DicoValue($facet.Expect); # which spits back a GUID... 
					$script = "return $($global:PvDictionary.GetValueByKey($key)); ";
					#  	and... bob's your uncle ...as in, the dico returns 10, "10", 'x', "I'm a teapot, short and stoute..";
					# 	etc... 
					
					# other than the SEEMING insanity of the above... I can't really think of any reason it... wouldn't work. 
					#  	er, well... if I add, say, a string into a dictionary<guid, object> ... and fetch it ... 
					# 			i don't think I get a string back, i get an object (that can, correctly, be cast to a string). 
					# 	SO. 
					# 		another option would be: 
					# 		get the TYPE of the object here... 
					# 			and... handle the whole $script = "return ($)"; via some sort of helper func. 
					# 			as in, pass $expect into Get-ReturnWhatzit ... 
					# 			and... it'll figure out what to do based on the type? 
					# 	that PROBABLY makes the most sense actually. 
					
					$prop.Expect = [ScriptBlock]::Create($script);	
	
#>
	
	# TODO: this looks pretty dope actually: 
	# 	https://github.com/iRon7/ConvertTo-Expression

	
	switch ($Object.GetType().FullName) {
		"System.String" {
			$script = "return `"$Object`";";
		}
		"System.Object[]" {
# TODO: this is a REALLY naive implementation and ... it's also casting @(10, "10") to @(10, 10) (as near as I can tell... )
			$data = $Object -join ",";
			$script = "return @(" + $data + "); ";
		}
		default {
			$script = "return $Object;";
		}
	}
	
	# TODO: should I be using a closure here??  : https://ss64.com/ps/syntax-scriptblock.html
	return [ScriptBlock]::Create($script);
}