Set-StrictMode -Version 1.0;

function Instance {
	[CmdletBinding()]
	param (
		[Parameter(Mandatory, Position = 0, ParameterSetName = 'Named')]
		[string]$Name = $null,
		[Parameter(Mandatory, Position = 1, ParameterSetName = 'Named')]
		[parameter(Mandatory, Position = 0, ParameterSetName = 'Anonymous')]
		[ScriptBlock]$InstanceBlock,
		
		[Alias('DefaultInstanceName')]
		[string]$DefaultInstance,
		
		#[Switch]$Naive = $false,
		
		[Switch]$Strict = $false #,
		
		# TODO: this might not even make sense. It's implemented as a STRING for now.
		#[string]$OrderBy = $null 
	);
	
	begin {
		[bool]$xVerbose = ("Continue" -eq $global:VerbosePreference) -or ($PSBoundParameters["Verbose"] -eq $true);
		[bool]$xDebug = ("Continue" -eq $global:DebugPreference) -or ($PSBoundParameters["Debug"] -eq $true);
		
		Enter-Block ($MyInvocation.MyCommand) -Name $Name -Verbose:$xVerbose -Debug:$xDebug;
	};
	
	process {
		$currentInstance = New-Object Proviso.Core.Models.Instance($Name, (Get-GrandParentBlockName), $Strict, $DefaultInstance);
		
		# STORE:
		# TODO: tackle this if/when I address the idea of 'globally-defined' ... instance(selectors)/iterators ... whatever
		
		# BIND: 
		Write-Debug "$(Get-DebugIndent)	Binding Instance-Block: [$Name] to Pattern: [$((Get-GrandParentBlockName))].";
		$currentPattern.AddInstance($currentInstance);
		
		& $InstanceBlock;
	};
	
	end {
		Exit-Block $MyInvocation.MyCommand -Name $Name -Verbose:$xVerbose -Debug:$xDebug;
	};
}