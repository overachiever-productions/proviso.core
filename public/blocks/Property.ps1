Set-StrictMode -Version 1.0;

<#


#>

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
		[ValidateSet("None", "Low", "Medium", "High")]
		[string]$Impact = "None",
		[switch]$Skip = $false,
		[string]$Ignore = $null,
		[string]$Display = $null,
		[object]$Expect,
		[object]$Extract,
		[Alias('PreventConfig', 'PreventConfiguration', 'DisableConfig')]
		[switch]$NoConfig = $false,
		[Alias('ThrowOnConfig', 'ThrowOnConfiguration')]
		[string]$ThrowOnConfigure = $null,
		[switch]$UsesAdd = $false,
		[switch]$UsesAddRemove = $false
	);
	
	begin {
		[bool]$xVerbose = ("Continue" -eq $global:VerbosePreference) -or ($PSBoundParameters["Verbose"] -eq $true);
		[bool]$xDebug = ("Continue" -eq $global:DebugPreference) -or ($PSBoundParameters["Debug"] -eq $true);
		
		Enter-Block $MyInvocation.MyCommand -Name $Name -Verbose:$xVerbose -Debug:$xDebug;
	};
	
	process {
		$currentProperty = New-Object Proviso.Core.Models.Property($Name, ([Proviso.Core.PropertyParentType](Get-ParentBlockType)), (Get-ParentBlockName));
		
		Set-Declarations $currentProperty -BlockType ($MyInvocation.MyCommand) -ModelPath $ModelPath -TargetPath $TargetPath `
						 -Impact $Impact -Skip:$Skip -Ignore $Ignore -Expect $Expect -Extract $Extract -NoConfig:$NoConfig `
						 -ThrowOnConfigure $ThrowOnConfigure -Display $Display -Verbose:$xVerbose -Debug:$xDebug;
		
		# BIND:
		switch ((Get-ParentBlockType)) {
#			"GlobalProperties" {
#				Write-Debug "$(Get-DebugIndent)	NOT Binding Property: [$($currentProperty.Name)] to parent, because parent is a Properties wrapper.";
#			}
			"Members" {
				Write-Debug "$(Get-DebugIndent)	Binding Property: [$($currentProperty.Name)] to Collection: [$($currentCollection.Name)] - within grandparent named: [$($currentCollection.ParentName)].";
				$currentCollection.AddMemberProperty($currentProperty);
			}
			"Facet" {
				Write-Debug "$(Get-DebugIndent)	Binding Property: [$($currentProperty.Name)] to Facet, named: [$($currentProperty.ParentName)], with grandparent named: [$grandParentName].";
				
				$currentFacet.AddProperty($currentProperty);
			}
			"Properties" {
				Write-Debug "$(Get-DebugIndent)	Binding Property: [$($currentProperty.Name)] to Pattern, named: [$($currentProperty.ParentName)], with grandparent named: [$grandParentName].";
				
				$currentPattern.AddProperty($currentProperty);
			}
			default {
				throw "Proviso Framework Error. Invalid Property Parent: [$($currentProperty.ParentType)] specified.";
			}
		}
		
		# STORE:
		# TODO: Figure out what rules I want to impose on re-using properties. 
		# 	 There are a few options: 
		# 		a. any property can be re-used (this gets SUPER hard cuz... in order to 'import' it ... I'd need to be able to find it (as a code author) and... store it correctly.)
		# 			don't think this is the right approach. 
		# 		b. MAYBE, globally-defined properties can be re-used? 
		# 			this'd be a bit easier to tackle - and ... makes a bit more sense? 
		# 		c. The other option too is ... they can't ever be re-used. 
		# 	either way, whatever I decided, I'll need to implement that for Properties, Cohorts, and Inclusions ... 
		# 	likewise, I have CLR VirtualProperty and VirtualCohort objects defined. 
		# 		they'd be ... what ends up being referenced as a place-holder ... and then 'looked up' during 'discovery' / etc. 
		# 		and, if I end up NOT allowing re-use ... then I don't need those virtual objects... 
		#Store-Property $currentProperty -AllowReplace (Allow-BlockReplacement) -Verbose:$xVerbose -Debug:$xDebug;
		
		& $PropertyBlock;
	};
	
	end {
		Exit-Block $MyInvocation.MyCommand -Name $Name -Verbose:$xVerbose -Debug:$xDebug;
	};
}