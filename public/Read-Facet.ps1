Set-StrictMode -Version 1.0;

<# 

	Surface "Extended Events" {
		Setup { }
		Aspect "Named Aspect" {
			Facet "ANOTHER My First Facet" { }

			Pattern "My first Pattern" { 
				Iterate {}
				Add {}
				Remove {}

				Property "Do I need wrappers around Properties?" {}
				Property "No I don't need a parent wrapper" {}

				Cohort "Members Test" {
					Enumerate {
						return @("Piggly","Wiggly");
					}
					Add {
						# set some global array to $array + some new value or whatever... 
					}
					Remove {}
					Property "Cohort Property 1" {
						Expect {}
					}
					Property "Cohort Property 2" {}
				}
			}
		}
		Cleanup { }
	}

	Facets {
		Facet "My Second Facet" { }
	}

	#Read-Facet "ANOTHER My First Facet" { } 

write-host "--------------------------------------------------"

	$facets = @(
		[PSCustomObject]@{ Name = "My First Facet" }
		[PSCustomObject]@{ Name = "ANOTHER My First Facet" }
		[PSCustomObject]@{ Name = "My Second Facet" }
		[PSCustomObject]@{ Name = "My first Pattern" }
	)

	#$facets | Read-Facet;

write-host "--------------------------------------------------"



#>

function Read-Facet {
	[CmdletBinding(DefaultParameterSetName = 'Default')]
	param (
		
# TODO: add in an option for Read-Facet via -Id... 		
		
		[Parameter(Mandatory, Position = 0, ParameterSetName = 'Default')]
		[Parameter(Mandatory, Position = 0, ParameterSetName = 'Targets')]
		[Parameter(Mandatory, Position = 0, ParameterSetName = 'Servers')]
		[Alias('FacetName')]
		[string]$Name,
		
		[Parameter(ParameterSetName = 'Default')]
		[Parameter(ParameterSetName = 'Targets')]
		[Parameter(ParameterSetName = 'Servers')]
		#[Alias('SurfaceName', 'AspectName')]
		[string]$ParentName,
		
		[Parameter(Mandatory, ValueFromPipeline, ParameterSetName = 'Targets')]
		[Parameter(ParameterSetName = 'Default')]
		[Parameter(ParameterSetName = 'Servers')]
		[Alias('Target')]
		[object[]]$Targets,
		
# TODO: add in a param (and ... param-set details) for $Model, right? 
# 		er, NO: if this were a Test or Invoke operation, then ... yup. 
# 			but not for a READ... 
		
		[Parameter(Mandatory, ValueFromPipelineByPropertyName, ParameterSetName = 'Servers')]
		[Parameter(ParameterSetName = 'Default')]
		[Parameter(ParameterSetName = 'Targets')]
		[Alias('Host', 'Hosts', 'Server', 'Computer', 'Computers', 'ComputerName', 'ComputerNames')]
		[string[]]$Servers = $null,
		
		[Parameter(ParameterSetName = 'Default')]
		[Parameter(ParameterSetName = 'Targets')]
		[Parameter(ParameterSetName = 'Servers')]
		[switch]$AsPson = $false,
		
		[Parameter(ParameterSetName = 'Default')]
		[Parameter(ParameterSetName = 'Targets')]
		[Parameter(ParameterSetName = 'Servers')]
		[switch]$AsJson = $false,
		
		[Parameter(ParameterSetName = 'Default')]
		[Parameter(ParameterSetName = 'Targets')]
		[Parameter(ParameterSetName = 'Servers')]
		[PSCredential]$Credential
		
		
# TODO: add in 2x display properties: 
# 		-Wrap: allows wrap of text in the 'outcome'/comments column (vs default which is equivlent of -NoWrap.)
# 		-NonMatchedOnly: which... a) needs a better name, and b) does NOT apply to READ-xxx. But, it's the idea that I could, somehow, emit a DIFFERENT result-type out the bottom of
# 			the Test-XXX or Invoke-XXX operation itself that'd be ... well, the exact same kind of object as the normal results object for those operations, but ... filtered to where it
# 			it only shows properties that ... were non-matched (either for Test... or for Invoke (second test/validate)
# 			and... truth is... i might not even need a secondary object-type or 'filtered' set of results in the same object type. in fact, i don't want that. 
# 			instead, I'd have $PvFormatter.WriteThisOrThatColumnIf($global:NonMatchedOrNot, $_)... 
# 		i mean... the above is way over-wrought... but it's, conceptually, what I'd want to tackle. i.e., ONLY write ENTIRE ROWS? if they're non-matched (assuming that this is even possible)
		
	);
	
	begin {
		[bool]$xVerbose = ("Continue" -eq $global:VerbosePreference) -or ($PSBoundParameters["Verbose"] -eq $true);
		[bool]$xDebug = ("Continue" -eq $global:DebugPreference) -or ($PSBoundParameters["Debug"] -eq $true);
		
		# CONTEXT: Get-Facet is a proxy method. If the Facet is already registered, we'll get it back. 
		#	Otherwise, Get-Facet will attempt registration + return the Facet (if everything worked).
		[Proviso.Core.Models.Facet]$facet = Get-Facet -Name $Name -ParentName $ParentName -Verbose:$xVerbose -Debug:$xDebug;
		
		if ($null -eq $facet) {
			throw "Processing Error. Facet: [$Name] NOT found.";
		}
		
		if ($AsPson -and $AsJson) {
			throw "Invalid Arguments. Specify either -AsPson or -AsXml - but not both.";
		}
		
		$results = @();  # MUST be declared here to be able to be in scope for all pipeline'd operations... 
	};
	
	process {
		
		if (Has-ArrayValue $Servers) {
			foreach ($s in $Servers) {
				if (Has-ArrayValue $Targets) {
					foreach ($t in $Targets) {
						$results += Process-ReadFacet -Facet $facet -ServerName $s -Target $t -Credential $Credential -Verbose:$xVerbose -Debug:$xDebug;
					}
				}
				else {
					$results += Process-ReadFacet -Facet $facet -ServerName $s -Credential $Credential -Verbose:$xVerbose -Debug:$xDebug;
				}
			}
		}
		else {
			if (Has-ArrayValue $Targets) {
				foreach ($t in $Targets) {
					$results += Process-ReadFacet -Facet $facet -Target $t -Verbose:$xVerbose -Debug:$xDebug;
				}
			}
			else {
				$results += Process-ReadFacet -Facet $facet -Verbose:$xVerbose -Debug:$xDebug;
			}
		}
	};
	
	end {
		if ($AsPson) {
			return $results | ConvertTo-Expression;
		}
		
		if ($AsJson) {
			#return $results | ConvertTo-Xml -Depth 16 -As Stream;
			return $results.Serialize();
		}
		
		return $results;  # TODO: might need to declare this (early on/initially) as an array of ... FacetProcessingResults of whatever ... 
	};
}

# NOTE: No -Config or -Model for Read operations (just -Targets as an option):
function Process-ReadFacet {
	[CmdletBinding()]
	param (
		[Parameter(Mandatory)]
		[Proviso.Core.Models.Facet]$Facet,
		[string]$ServerName = $null,
		[object]$Target = $null,
		[PSCredential]$Credential
	);
	
	begin {
		
		if (Has-Value $ServerName) {
			$connection = Register-RemoteSession -ServerName $ServerName -Credential $Credential;
			
			if (-not ($connection.Connected)) {
				throw "Failed to Connect to Remote Server: [$ServerName]. Error: $($connection.ErrorText)";
			}
		}
	};
	
	process {
		if (Has-Value $ServerName) {
			if ($connection.Connected) {
				$facetName = $Facet.Name;
				$remoteFacet = Invoke-Command -Session ($connection.Session) -ScriptBlock { Get-Facet -Name $using:facetName; }
				
				if (-not $remoteFacet) {
					
					# HACK / This is just for a proof of concept: 
					$importSQLBlock = {
						Install-Module -Name "proviso.sql" -Repository "Proviso Repo" -Force;
						Import-Module -Name "proviso.sql" -Force;
					};
					
					Invoke-Command -Session ($connection.Session) -ScriptBlock $importSQLBlock;
					Write-Host "Executed Install + Import on Remote Server... "; # TODO: long-term, going to have to check to see if version of .sql or whatever is already installed. 
					
					$remoteFacet = Invoke-Command -Session ($connection.Session) -ScriptBlock { Get-Facet -Name $using:facetName; }
					
					if (-not $remoteFacet) {
						
						throw "Facet: [$facetName] was NOT found on [$ServerName]. Serialization of Facets from local to REMOTE hosts is not YET supported.";
						
						# TODO: 
						# 	Resources/Fodder for Serialization and Deserialization of Facets (which derive from DeclarableBase)
						# 		- https://learn.microsoft.com/en-us/dotnet/standard/serialization/system-text-json/polymorphism?pivots=dotnet-7-0 
						# 		- possibly this: https://learn.microsoft.com/en-us/dotnet/standard/serialization/system-text-json/converters-how-to?pivots=dotnet-7-0 
						# 		- https://code-maze.com/csharp-polymorphic-serialization-and-deserialization/
						
						Write-Host "At this point... would ahve to TRY and serialize the facet here (locally), and send over the wire to rehydrate.";
						# pseudo-code for the above would be something like: 
						# 		$payload = $Facet.Serialize();
						# 		Invoke-Command -Session ($connection.Session) -ScriptBlock { LoadOrReadOrWhatever-Facet -JsonDefinition $using:payload; }
						# 		$remoteFacet = Invoke-Command -Session ($connection.Session) -ScriptBlock { Get-Facet -Name $using:facetName; }
						#  	if still null, throw... 
						# 		or... dump some info into the so-called $result object to let us know what happened here (tried to transfer over the wire, but failed?)
					}
					else {
						Write-Host "This is still just a test, but ... it looks like we got the facet from the remote server."
					}
				}
				
				if ($Target) {
					# nothing much here... because I'm going to make the 'architectural decision' that ... TARGETs can't be that complex when 
					# 	being passed around from one host to the next - i.e., the entire purpose of the -Target as an input is PRIMARILY to 
					# 		do some light-weight testing on facets/properties and the likes AND for ... code-gen or whatever might make sense for
					# 		facets/properties OUTSIDE of IAC. 
					# 	Or, stated differently: 
					# 		IF we're trying to run a FACET against a remote machine, we don't care about CANNED input into the Facet (e.g., a -Target)
					# 			Instead, we're expecting to extract values via the CODE in the Facet itself. 
					
					# The ABOVE, however, will be different for MODELs. 
					# 		it's just that Read-XXX doesn't REQUIRE (or allow/care-about) a MODEL. Test and Invoke ... will. 
					# 		in which case, I'm going to need to allow for the OPTION to have .Config 'classes'/objects that 
					# 		can/will support a .Deserialize() method/func/behavior along with a .FromJson(stringInput) method
					# 		and if/when those are present ... then... i'll 'beam' the model/config over the wire. rehydrate there... 
					# 			and then shove THAT (rehydrated object - on the remote server) into a command... 
					# 			get the results back ... serialize (there) and then rehydrate here.
				}
				
				if ($Model) {
					# DOES NOT APPLY to READ operations. 
					# this is just a place-holder for when I come back in here to copy/paste/tweak for Test|Invoke methods. 
					# 	and.. when I do: see the notes above about -Target and -Model... 
				}
				
				if ($remoteFacet) {
					$readBlock = {
						Read-Facet -Name $using:facetName -Target $using:Target -AsJson;
					};
					
					$remoteResult = Invoke-Command -Session $($connection.Session) -ScriptBlock $readBlock;
					
					$result = [Proviso.Core.FacetReadResult]::FromJson($serialized);
				}
				# TODO: 
				# 	is there an ELSE block here? that says: "had a connection to remote ... tried to serialize the facet or whatever... but couldn't..??"
			}
			# TODO: 
			# is there an ELSE block here - where I spin up a fake/place-holder FacetReadResult with an error about not being able to connect?
		}
		else {
			$instance = [Proviso.Core.Models.Facet]::GetInstance($Facet);
			
			Set-PvContext_OperationData -Verb Read -Noun Facet -BlockName ($instance.Name) -TargetServer $ServerName -Target $Target;
			
			$result = Execute-Pipeline -Verb "Read" -OperationType Facet -Block $instance -Target $Target -Verbose:$xVerbose -Debug:$xDebug;
		}
	};
	
	end {
		Remove-PvContext_OperationData;
		
		return $result;
	};
}