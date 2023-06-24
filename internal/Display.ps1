Set-StrictMode -Version 1.0;


# display token 'class/object'
#  	token/key
# 	value/object (props)
# 		.Mapping/Source (i.e., what to run? or what to use to populate the replacement value.  )
# 		.RequiresCollection 
# 		.RequiresInstance
# 		.RequiresSurface 
# 		.RequiresRunbook 

filter New-PVDisplayToken {
	param (
		[string]$Key,
		[string]$Source,
		[Switch]$RequiresCollection = $false,
		[Switch]$RequiresInstance = $false,
		[Switch]$RequiresSurface = $false,
		[Switch]$RequiresRunbook = $false # this might not ever even be needed. 
	);
	
	$Token = @{
		Key = $Key
		Data = @{
			RequiresCollection = $RequiresCollection
			RequiiresInstance  = $RequiresInstance
			RequiresSurface    = $RequiresSurface
			RequiresRunbook	= $RequiresRunbook
		};
	}
	
	return $Token;
}