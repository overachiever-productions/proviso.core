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
		Bind-Aspect -Aspect $definition -Verbose:$xVerbose -Debug:$xDebug;
		
		& $ScriptBlock;
	};
	
	end {
		Exit-Block $MyInvocation.MyCommand -Name $Name -Verbose:$xVerbose -Debug:$xDebug;
		$global:currentAspect = $null;
	};
}

function Bind-Aspect {
	[CmdletBinding()]
	param (
		[Proviso.Core.Definitions.AspectDefinition]$Aspect
	);
	
	process {
		try {
			$surfaceName = $global:PvOrthography.GetParentBlockName();
			$surface = $global:PvOrthography.GetSurfaceDefinition($surfaceName);
			
			Write-Debug "$(Get-DebugIndent)		Binding Aspect: [$($Aspect.Name)] to Surface: [$($surfaceName)].";
			$surface.AddAspect($Aspect);
			
			# TODO: do aspects NEED to be stored in the ortho-cache?
			if ($global:PvOrthography.StoreAspectDefinition($definition, (Allow-DefinitionReplacement))) {
				Write-Verbose "Aspect: [$Name] was replaced.";
			}
		}
		catch {
			"Exception in Bind-Aspect: $($_.Exception.Message) `r`t$($_.ScriptStackTrace) ";
		}
	}
}