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

# PICKUP/NEXT: I THINK that I might want to NOT throw within the pipeline (see Pipeline.ps1 -> Line#289)
# 	UNLESS the Instance in question is set to -Strict:$true? And... further, IF the -Verb is READ... maybe also not throw (even IF strict)?
# 	basically, see the note on line #74 within Pattern.ps1... i can/should allow some instances to be NULL/EMPTY ... 
# 		but... what should that look like and ... do I make it a default (for some verbs?) or ... does it have to be explicit? etc?
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