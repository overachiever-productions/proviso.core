Set-StrictMode -Version 1.0;

<#


#>

[PSCustomObject]$global:ProvisoContext = New-Object -TypeName PSCustomObject;
$global:PvCurrent = $ProvisoContext;

filter Set-PvContext_CollectionData {
	param (
		[Object[]]$Members,
		[Object]$CurrentMember
	);
	
	if (($ProvisoContext.Properties -contains "Collection") -or ($null -ne $ProvisoContext.Collection)) {
		Remove-PvContext_CollectionData;
	}
	
	$collection = @{
		Members = $Members
		Member = $CurrentMember
	};
	
	Add-Member -InputObject $ProvisoContext -MemberType NoteProperty -Name Collection -Value $collection -Force;
}

filter Remove-PvContext_CollectionData {
	$ProvisoContext.PSObject.Properties.Remove('Collection');
}

<#

	Set-PvContext_CollectionData -Members @("one", "two", "four") -CurrentMember 'one';
	Write-Host "All: $($PvCurrent.Collection.Members)";
	Write-Host "	Current: $($PvCurrent.Collection.Member)";

	Write-Host "-------------------------------------------"
	Set-PvContext_CollectionData -Members @("one", "two", "four") -CurrentMember 'two';
	Write-Host "All: $($PvCurrent.Collection.Members)";
	Write-Host "	Current: $($PvCurrent.Collection.Member)";

	Write-Host "-------------------------------------------"
	Set-PvContext_CollectionData -Members @("one", "two", "four") -CurrentMember 'four';
	Write-Host "All: $($PvCurrent.Collection.Members)";
	Write-Host "	Current: $($PvCurrent.Collection.Member)";

	Write-Host "-------------------------------------------"
	Remove-PvContext_CollectionData;
	Write-Host "All: $($PvCurrent.Collection.Members)";
	Write-Host "	Current: $($PvCurrent.Collection.Member)";

#>