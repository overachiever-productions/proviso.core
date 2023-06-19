Set-StrictMode -Version 1.0;

[PSCustomObject]$global:ProvisoContext = New-Object -TypeName PSCustomObject;
$global:PvCurrent = $ProvisoContext;

filter Set-EnumeratorData {
	param (
		[Object[]]$Members,
		[Object]$CurrentValue
	);
	
	if (($ProvisoContext.Properties -contains "Enumerator") -or ($null -ne $ProvisoContext.Enumerator)) {
		Remove-EnumeratorData;
	}
	
	$enumerator = @{
		Members = $Members
		Value = $CurrentValue
	};
	
	Add-Member -InputObject $ProvisoContext -MemberType NoteProperty -Name Enumerator -Value $enumerator -Force;
}

filter Remove-EnumeratorData {
	$ProvisoContext.PSObject.Properties.Remove('Enumerator');
}

<#

	Set-EnumeratorData -Members @("one", "two", "four") -CurrentValue 'one';
	Write-Host "All: $($PvCurrent.Enumerator.Members)";
	Write-Host "	Current: $($PvCurrent.Enumerator.Value)";

	Write-Host "-------------------------------------------"
	Set-EnumeratorData -Members @("one", "two", "four") -CurrentValue 'two';
	Write-Host "All: $($PvCurrent.Enumerator.Members)";
	Write-Host "	Current: $($PvCurrent.Enumerator.Value)";

	Write-Host "-------------------------------------------"
	Set-EnumeratorData -Members @("one", "two", "four") -CurrentValue 'four';
	Write-Host "All: $($PvCurrent.Enumerator.Members)";
	Write-Host "	Current: $($PvCurrent.Enumerator.Value)";

	Write-Host "-------------------------------------------"
	Remove-EnumeratorData;
	Write-Host "All: $($PvCurrent.Enumerator.Members)";
	Write-Host "	Current: $($PvCurrent.Enumerator.Value)";

#>