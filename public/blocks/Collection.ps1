﻿Set-StrictMode -Version 1.0;

<#

#>

function Collection {
	[CmdletBinding()]
	param (
		[Parameter(Mandatory, Position = 0, ParameterSetName = 'Named')]
		[string]$Name = $null,
		[Parameter(Mandatory, Position = 1, ParameterSetName = 'Named')]
		[parameter(Mandatory, Position = 0, ParameterSetName = 'Anonymous')]
		[ScriptBlock]$CollectionBlock,
		[string]$ModelPath = $null,
		[string]$TargetPath = $null,
		[string]$Path,
		[ValidateSet("None", "Low", "Medium", "High")]
		[string]$Impact = "None",
		[switch]$Skip = $false,
		[string]$Ignore = $null,
		[string]$Display = $null,
		
		[switch]$UsesAdd = $false,
		[switch]$UsesAddRemove = $false
		
		# TODO: enable syntactic sugar options for -UsesMembership "Name of globally defined membership here" and -UsesStrictMembership "ditto - but strict."
	);
	
	begin {
		[bool]$xVerbose = ("Continue" -eq $global:VerbosePreference) -or ($PSBoundParameters["Verbose"] -eq $true);
		[bool]$xDebug = ("Continue" -eq $global:DebugPreference) -or ($PSBoundParameters["Debug"] -eq $true);
		
		Enter-Block $MyInvocation.MyCommand -Name $Name -Verbose:$xVerbose -Debug:$xDebug;
	};
	
	process {
		$currentCollection = New-Object Proviso.Core.Models.Collection($Name, ([Proviso.Core.PropertyParentType](Get-ParentBlockType)), (Get-ParentBlockName));
		
		Set-Declarations $currentCollection -BlockType ($MyInvocation.MyCommand) -ModelPath $ModelPath -TargetPath $TargetPath `
						 -Impact $Impact -Skip:$Skip -Ignore $Ignore -Expect $Expect -Extract $Extract -NoConfig:$NoConfig `
						 -ThrowOnConfigure $ThrowOnConfigure -Display $Display -Verbose:$xVerbose -Debug:$xDebug;
		
		# TODO: address ... -UsesAdd/UsesAddRemove 
		# TODO:  -DefineMembers and -ListMembers ... if they're present ... then build 'anonymous' returns/funcs for them. 
		
		# BIND: 
		$grandParentName = Get-GrandParentBlockName;
		switch ((Get-ParentBlockType)) {
#			"Cohorts" {
#				Write-Debug "$(Get-DebugIndent)	NOT Binding Cohort: [$($currentCohort.Name)] to parent, because parent is a Cohorts wrapper.";
#			}
			"Facet" {
				Write-Debug "$(Get-DebugIndent)	Binding Collection: [$($currentCollection.Name)] to Facet, named: [$($currentCollection.ParentName)], with grandparent named: [$grandParentName].";
				
				$currentFacet.AddProperty($currentCollection);
			}
			"Properties" {
				Write-Debug "$(Get-DebugIndent)	Binding Collection: [$($currentCollection.Name)] to Pattern, named: [$($currentCollection.ParentName)], with grandparent named: [$grandParentName].";
				
				$currentPattern.AddProperty($currentCollection);
			}
			default {
				throw "Proviso Framework Error. Invalid Collection Parent: [$($currentCohort.ParentType)] specified.";
			}
		}
		
		& $CollectionBlock;
	};
	
	end {
		Exit-Block $MyInvocation.MyCommand -Name $Name -Verbose:$xVerbose -Debug:$xDebug;
	};
}