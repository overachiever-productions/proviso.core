Set-StrictMode -Version 1.0;

<#


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

filter Remove-PvContext_CollectionData {
	$PVCurrent.PSObject.Properties.Remove('Collection');
}

filter Remove-PvContext_OperationData {
	$PVCurrent.PSObject.Properties.Remove('Operation');
}

<#

	Set-PvContext_CollectionData -Members @("one", "two", "four") -CurrentMember 'one';
	Write-Host "All: $($PVCurrent.Collection.Members)";
	Write-Host "	Current: $($PVCurrent.Collection.CurrentMember)";

	Write-Host "------------------------------------------- (long syntax)"
	Set-PvContext_CollectionData -Members @("one", "two", "four") -CurrentMember 'two';
	Write-Host "All: $($PVContext.Current.Collection.Members)";
	Write-Host "	Current: $($PVContext.Current.Collection.CurrentMember)";

	Write-Host "-------------------------------------------"
	Set-PvContext_CollectionData -Members @("one", "two", "four") -CurrentMember 'four';
	Write-Host "All: $($PVCurrent.Collection.Members)";
	Write-Host "	Current: $($PVCurrent.Collection.CurrentMember)";

	Write-Host "-------------------------------------------"
	Remove-PvContext_CollectionData;
	Write-Host "All: $($PVCurrent.Collection.Members)";
	Write-Host "	Current: $($PVCurrent.Collection.CurrentMember)";

#>