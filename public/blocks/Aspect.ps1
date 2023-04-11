Set-StrictMode -Version 1.0;

function Aspect {
	[CmdletBinding()]
	param (
		[Parameter(Mandatory, Position = 0, ParameterSetName = 'Named')]
		[Alias('AspectName')]
		[string]$Name = $null,
		
		[Parameter(Mandatory, Position = 1, ParameterSetName = 'Named')]
		[Parameter(Mandatory, Position = 0, ParameterSetName = 'Anonymous')]
		[ScriptBlock]$ScriptBlock,
		[string]$ModelPath = $null,
		[string]$TargetPath = $null,
		[string]$Path,
		[ValidateSet("None", "Low", "Medium", "High")]
		[string]$Impact = "None",
		[switch]$Skip = $false,
		[string]$Ignore = $null
	);
	
	begin {
		[bool]$xVerbose = ("Continue" -eq $global:VerbosePreference) -or ($PSBoundParameters["Verbose"] -eq $true);
		[bool]$xDebug = ("Continue" -eq $global:DebugPreference) -or ($PSBoundParameters["Debug"] -eq $true);
		Enter-Block $MyInvocation.MyCommand -Name $Name -Verbose:$xVerbose -Debug:$xDebug;
	};
	
	process {
		$parentName = $global:PvOrthography.GetParentBlockName();
		$definition = New-Object Proviso.Core.Definitions.AspectDefinition($Name, $parentName);
		
		Set-Definitions $definition -BlockType ($MyInvocation.MyCommand) -ModelPath $ModelPath -TargetPath $TargetPath `
						-Impact $Impact -Skip:$Skip -Ignore $Ignore -Expect $null -Extract $null -ThrowOnConfig $null `
						-DisplayFormat $null -Verbose:$xVerbose -Debug:$xDebug;
		
		$currentAspect = $definition;
		
		# BIND: 
		Write-Debug "$(Get-DebugIndent)		Binding Aspect: [$($definition.Name)] to Surface: [$($currentSurface.Name)].";
		$currentSurface.AddAspect($definition);
		
		& $ScriptBlock;
	};
	
	end {
		Exit-Block $MyInvocation.MyCommand -Name $Name -Verbose:$xVerbose -Debug:$xDebug;
		$global:currentAspect = $null;
	};
}