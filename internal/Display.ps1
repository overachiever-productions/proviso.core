Set-StrictMode -Version 1.0;

<#


#>

[PSCustomObject]$global:PVDisplayTokenizer = New-Object -TypeName PSCustomObject;
Add-Member -InputObject $PVDisplayTokenizer -MemberType NoteProperty -Name Tokens -Value (@{});

# TODO: Move New|Publish|Get|Unpublish-PvDisplayToken methods into 'public';
# 		I can EITHER: 
#			a) break each of these out into their own <func_name>.ps1 file within the \public\framework\ folder or
# 			b) add some 'publication' directives/whatever inside of the .psm1 (near the bottom) to add these methods and a few other, similar, 'provider-ish' methods as well. 
# 				this option seems to almost make the most sense - other than that ... it's ARGUABLE that public methods should be in the ... public folder of the project.
filter New-PVDisplayToken {
	param (
		[Parameter(Mandatory)]
		[string]$Key,
		[Parameter(Mandatory)]
		[Alias('ContextPath')]
		[string]$Location,
		[ValidateSet('Throw', 'Warn', 'DefaultText')]			# when warn, then $DefaultReplacementText CAN be used if present; when DefaultText, $DefaultReplacementText MUST be present.
		[string]$NonFoundBehavior = 'Throw',
		[string]$DefaultReplacementText = $null,
		[string]$ModuleName = "Proviso.Core",
		[Switch]$RequiresCollection = $false,
		[Switch]$RequiresInstance = $false   # effectively the same as .RequiresPattern (i.e., we have to have an instance/iterator).
#		[Switch]$RequiresSurface = $false,
#		[Switch]$RequiresRunbook = $false # this might not ever even be needed. 
	);
	
	if ('DefaultText' -eq $NonFoundBehavior) {
		if ($null -eq $DefaultReplacementText) {
			throw "When -NonFoundBehavior is set to DefaultText (i.e., replace with default text), -DefaultReplacementText must be non-NULL.";
		}
	}
	
	$Token = @{
		Key			       = $Key
		Location = $Location
		SourceModule	   = $ModuleName
		NonMatchedBehavior = $NonFoundBehavior
		DefaultText = $DefaultReplacementText
		# TODO: add a FileSource 'property' here that lets us know which MODULE this came from and ... the location of the file... 
		RequiresCollection = $RequiresCollection
		RequiresInstance  = $RequiresInstance
#		RequiresSurface    = $RequiresSurface
#		RequiresRunbook    = $RequiresRunbook
	}
	
	return $Token;
}

filter Publish-PVDisplayToken {
	param (
		[Parameter(Mandatory)]
		[PSCustomObject]$Token,
		[string[]]$Aliases
	);
	
	# TODO: verify that it HAS the properties needed 
	# and that it either has {} or does not (based on how I end up implementing).
	
	$PVDisplayTokenizer.Tokens[($Token.Key)] = $Token;
	
	foreach ($alias in $Aliases) {
		$clone = $Token.Clone();
		$clone.Key = $alias;
		$PVDisplayTokenizer.Tokens[$alias] = $clone;
	}
}

filter Get-PVDisplayTokens {
	return $PVDisplayTokenizer.Tokens;
}

filter UnPublish-PVDisplayToken {
	param (
		[string]$Key	
	);
	
	$PVDisplayTokenizer.Tokens.Remove($Key);
}

function Validate-DisplayTokenUse {
	[CmdletBinding()]
	param (
		[Parameter(Mandatory)]
		[string]$Display,
		[Switch]$IsCollection = $false,
		[Switch]$IsInstance = $false,
#		[Switch]$IsSurface = $false,
#		[Switch]$IsRunbook = $false,
		$Tokens = ($global:PVDisplayTokenizer.Tokens),
		$Context = ($global:PVContext.Current)
	);
	
	[string[]]$validationFailures = @();
	[string[]]$validationWarnings = @();
	
	if ($Display -like '*{*') {
		$current = ($Display -replace '{{', '') -replace '}}', '';
		
		$pattern = '\{[^}]+\}';
		$regex = [Regex]::New($pattern);
		foreach ($match in $regex.Matches($current)) {
			$token = $Tokens[$match.Value];
			if ($null -eq $token) {
				$validationFailures += "Invalid Display Token. Token: [$match] has NOT been defined. Remember to escape { and } with {{ and }} if you want to use curly-brackets in -Name or -Display values for Properties.";
			}
			else {
				if ($token.RequiresCollection -and -not ($IsCollection)) {
					$problem = "Token: [$match] may only be used within a Collection.";
					
					if ('Throw' -eq $token.NonMatchedBehavior) {
						$validationFailures += $problem;
					}
					if ('Warn' -eq $token.NonMatchedBehavior) {
						$validationWarnings += $problem;
					}
				}
				if ($token.RequiresInstance -and -not ($IsInstance)) {
					$problem = "Token: [$match] may only be used within a Pattern.";
					
					if ('Throw' -eq $token.NonMatchedBehavior) {
						$validationFailures += $problem;
					}
					if ('Warn' -eq $token.NonMatchedBehavior) {
						$validationWarnings += $problem;
					}
				}
				# I'm honestly not even sure these are needed. I can implement them if/as/when needed.				
#				if ($token.RequiresSurface -and -not ($IsSurface)) {
#					
#				}
#				if ($token.RequiresRunbook -and -not ($IsRunbook)) {
#					
#				}
			}
		}
	}
	
	if ($validationWarnings) {
		foreach ($warning in $validationWarnings) {
			Write-Warning $warning;
		}
	}
	
	if ($validationFailures) {
		throw "ruh roh... validation errors: $validationFailures ";
	}
}

function Process-DisplayTokenReplacements {
	[CmdletBinding()]
	param (
		[Parameter(Mandatory)]
		[string]$Display,
		[Parameter(Mandatory)]
		[string]$Name,     # used only if/when there's a failure in processing tokens within -Display
		$Tokens = ($global:PVDisplayTokenizer.Tokens),  
		$Context = ($global:PVContext.Current)
	);
	
	[string]$output = $Display;
	
	if ($Display -like '*{*') {
		$escaped = ($Display -replace '{{', '') -replace '}}', '';
		
		$pattern = '\{[^}]+\}';
		$regex = [Regex]::New($pattern);
		foreach ($match in $regex.Matches($escaped)) {
			if ($Tokens.Keys -contains $match) {
				try {
					$token = $Tokens[$match.Value];
					$path = $token.Location;
					$replacementValue = Extract-ValueFromObjectByPath -Object $PVCurrent -Path $path;
					
					$output = $output -replace $match, $replacementValue;
				}
				catch {
					# vNEXT: see the vNEXT commend below for else logic - about possibly adding in ... iterator/current-member and such... 
					$problem = "EXCEPTION Processing Token: [$match] within -Display: [$Display]. Using !*`$Name*! as default -Display. Root Exception: `n$_";
					Write-Debug $problem;
					Write-Verbose $problem;
					
					# TODO: Look at possibly adding $_ to $PVContext.Current.Exceptions or ... whatever... (not via THROW... but as an exception detail that can 
					# 		be easily reviewed by caller/user. THEN... make sure there's an [EX:#] as part of the -Display... so that if this was, say, EX:2 out of 
					# 		whatever is being done, then EX:2. 'down below' properties and such could/would show the root exception.)
					
					$output = "!*$($Name)*!";
				}
			}
			else {
				# WEIRD. Pre-validation apparently failed. So, verbose + debug the info and ... send back a !placeholder!:
				$problem = "WARNING: No matching token for: [$match] was found for -Display value of: [$Display]. Using !`$Name! as default -Display.";
				Write-Debug $problem;
				Write-Verbose $problem;
				
				# vNEXT: potentially look at including Iterator + Enumerator + name entries so that something like, say: "!MSSQLSERVER::Bilbo:Is Member of SysAdmins!" could be spit out (where the last 'chunk' of the example in question is the $Name)
				$output = "!$($Name)!";
			}
		}
	}
	
	$output = ($output -replace '{{', '{') -replace '}}', '}';
	
	return $output;
}

# Core Display Tokens: 
Publish-PVDisplayToken -Token (New-PVDisplayToken -Key "{SELF}" -Location "Property.Name");
Publish-PVDisplayToken -Token (New-PVDisplayToken -Key "{COLLECTION.MEMBER}" -Location "Collection.CurrentMember" -RequiresCollection) -Aliases "{CURRENT.MEMBER.NAME}", "{COLLECTION.CURRENT.MEMBER}";
#Publish-PVDisplayToken -Token (New-PVDisplayToken -Key "{INSTANCE.MEMBER}" -Location "Instance.Name" -RequiresInstance); 
#Publish-PVDisplayToken -Token (New-PVDisplayToken -Key "{PARENT.NAME}" -Location "hmmmm" -Requires????  );

<#

	[PSCustomObject]$global:PVCurrent = New-Object -TypeName PSCustomObject;
	[PSCustomObject]$global:PVContext = New-Object -TypeName PSCustomObject;
	Add-Member -InputObject $PVContext -MemberType NoteProperty -Name Current -Value $PVCurrent;

	Write-Host "-----------------------"
	#Validate-DisplayTokenUse -Display "does {{ have curly}} brackets for {SELF}";
	#Validate-DisplayTokenUse -Display "{COLLECTION.CURRENT.MEMBER}.IsSomething";

	Process-DisplayTokenReplacements -Display "no tokens but {{escaped curly brackets}}";

	Write-Host "-----------------------"
	Process-DisplayTokenReplacements -Display "{SELF} token AND: {{escaped curly brackets}}";


#>