Set-StrictMode -Version 1.0;

<#

	WARN: see the "ALSO" at the bottome of these comments.
	TODO: I also need some sort of Publish/Register-ContextSomething func or 'provider'. 
		Something that'll let 'authors' of various Proviso.XXX libraries ... add their own processing details into the pipeline. 
			as in, ... if they can provide a Set-XXX and Remove-XXX set of funcs that match what's needed... 
			then... these can be processed and added into a 'loop' of "load whatever such and such" or "remove whatever such and such" context-setters/removers type-funcs are available at
			the 'system' level when the pipeline is being processed. 

			basically, 'ContextHandlers'.

			and, arguably, I should IMPLEMENT the functionality below by means of these 'handlers'.
			
				e.g., at the time of writing, I've got Operation and Collection as context 'object' (at WILDLY different 'levels'...)
				but, I'm also, eventually, going to add in Instance 'context' (for Patterns/Iterators). 


				yeah... cuz. imediately after writing the above, it became clear that I need to add a new "Property" context. 
					so that I can work with things like "{SELF}" as a ... name/etc. 

		
		To make all of the above work I need (at least) the following: 
			- Set & Remove methods. 
				- PROBABLY an optional VALIDATE method? 
			- a KEY or "context-location-root" - e.g., Operation, Collection, Property ... and such (for the above)... 
			- tiers or locations or handler-locations. 
					sadly, this is going to need to be a bit ugly like ASP.NET pipeline 'position' handlers/locations ... 
						e.g., all of that on-before-such-but-after-blah-bullcrap. 
				and... once these tiers are defined within the pipeline... 
					then, each context-provider will need to specify which 'pair' of these hooks/handlers/locations to use. 
						e.g., some of these scopes would potentially be: 
							-Runbook Level
							-Surface Level
							-Pattern / Iterator Level
							-Facet Level 
							-Collection Level
							-Property Level
							i.e., I'll need to scrutinize the current pipeline and put in 'hooks/locations/tiers'. 
							and then classify each of my Set/Remove funcs (below) into more object-y type packaging so'z that these things
							can then be registered and handled accordingly.
								
						at which point, the func-method-names no longer really matter. 
							
						the RUB/CONCERN, though ... is that each of these 'thingies' is going to need some objects passed in to them? 
							the current runbook? surface? facet/pattern? property? 
			- AHH. 
				'authors' don't need to provide the Remove-XXX func. The framework will do that - the code is/always-should-be the exact same anyhow. 
		ALSO
			some stuff can't be 'providery'. 
			.Current.Extract and .Current.Expect and .Current.Result and other stuff... isn't something I need to make 'plugable' 
			in fact... i'm not even sure making stuff plug-able makes sense. 
#>

[PSCustomObject]$global:PVCurrent = New-Object -TypeName PSCustomObject;
[PSCustomObject]$global:PVContext = New-Object -TypeName PSCustomObject;
Add-Member -InputObject $PVContext -MemberType NoteProperty -Name Current -Value $PVCurrent;

filter Set-PvContext_OperationData {
	param (
		[Parameter(Mandatory)]
		[ValidateSet("Read", "Test", "Invoke")]
		[string]$Verb,
		[Parameter(Mandatory)]
		[ValidateSet("Facet", "Surface", "Runbook")]
		[string]$Noun,
		[Parameter(Mandatory)]
		[string]$BlockName,
		[string]$TargetServer,
		[Object]$Target,
		[Object]$Model
	);
	
	if (($PVCurrent.Properties -contains "Operation") -or ($null -ne $PVCurrent.Operation)) {
		Remove-PvContext_OperationData;
	}
	
	$operation = @{
		Verb 			= $Verb
		Noun 			= $Noun
		BlockName 		= $BlockName
		TargetServer 	= $TargetServer
		Target	     	= $Target
		Model 			= $Model
	};
	
	Add-Member -InputObject $PVCurrent -MemberType NoteProperty -Name Operation -Value $operation -Force;
	
}

filter Set-PvContext_CollectionData {
	param (
		[string]$Name,
		[Parameter(Mandatory)]
		[Object]$Membership,
		[Parameter(Mandatory)]
		[Object[]]$Members,
		[Parameter(Mandatory)]
		[Object]$CurrentMember
	);
	
	if (($PVCurrent.Properties -contains "Collection") -or ($null -ne $PVCurrent.Collection)) {
		Remove-PvContext_CollectionData;
	}
	
	$supportsRemove = $Membership.SupportsRemove;
	$isStrict = $Membership.IsStrict;
	
	$collection = @{
		CurrentMember  = $CurrentMember
		IsStrict = $isStrict
		Name = $Name
		Members = $Members
		SupportsRemove = $supportsRemove
	};
	
	Add-Member -InputObject $PVCurrent -MemberType NoteProperty -Name Collection -Value $collection -Force;
}

filter Set-PvContext_InstanceData {
	param (
		[string]$InstanceName = "Instances",  	# TODO: might make more sense to set it to $null and ... 'go that route' (just make sure to handle REMOVE-func... )
		[Object[]]$Members,
		[Object]$CurrentMember,
		[string]$DefaultInstanceName
	);
	
	if (($PVCurrent.Properties -contains $InstanceName) -or ($null -ne $PVCurrent.$InstanceName)) {
		Remove-PvContext_InstanceData -InstancesName $InstanceName;
	}
	
	$instance = @{
		Name = $CurrentMember
		Members = $Members
		#DefaultInstance = $DefaultInstanceName
	}
	
	Add-Member -InputObject $PVCurrent -MemberType NoteProperty -Name $InstanceName -Value $instance -Force;
}

filter Set-PvContext_PropertyData {
	param (
		[string]$PropertyName,
		[string]$ParentName
		# ??? what else? .IsCollectionProperty/Member? .IsInclusion? etc.?
	);
	
	if (($PVCurrent.Properties -contains "Property") -or ($null -ne $PVCurrent.Property)) {
		Remove-PvContext_PropertyData;
	}
	
	$property = @{
		Name = $PropertyName
		ParentName = $ParentName
	}
	
	Add-Member -InputObject $PVCurrent -MemberType NoteProperty -Name Property -Value $property -Force;
}

filter Remove-PvContext_CollectionData {
	$PVCurrent.PSObject.Properties.Remove('Collection');
}

filter Remove-PvContext_OperationData {
	$PVCurrent.PSObject.Properties.Remove('Operation');
}

filter Remove-PvContext_PropertyData {
	$PVCurrent.PSObject.Properties.Remove('Property');
}

filter Remove-PvContext_InstanceData {
	param (
		[string]$InstancesName
	);
	
	$PVCurrent.PSObject.Properties.Remove($InstancesName);
}


filter Get-PvContextOperationName {
	if (($PVCurrent.Properties -contains "Operation") -or ($null -ne $PVCurrent.Operation)) {
		return "$($PVCurrent.Operation.Verb)-$($PVCurrent.Operation.Noun)";
	}
	
	return "##ERROR##";
}



