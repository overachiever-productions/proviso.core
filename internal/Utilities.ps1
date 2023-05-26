Set-StrictMode -Version 1.0;

$global:PvUtility = [Proviso.Core.Utilities]::Instance;

filter DeepClone-Block {
	param (
		$Block
	);
	
	return $PvUtility.DeepClone($Block);
	
	#return [System.Management.Automation.PSSerializer]::Deserialize([System.Management.Automation.PSSerializer]::Serialize($Block));
}

