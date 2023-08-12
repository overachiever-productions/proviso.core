Set-StrictMode -Version 1.0;

BeforeAll {
	$UnitName = (Split-Path -Leaf $PSCommandPath).Replace(".Tests.ps1", "");
	$uut = $PSCommandPath.Replace(".Tests.ps1", ".ps1").Replace("\tests\", "\");
	$root = ($PSCommandPath.Split("\tests"))[0];
	
	. $uut;
}

Describe "$UnitName Tests" -Tag "UnitTests" {
	Context "Collection Member Tests" {
		It "Stores Collection Data on Set" {
			$fakeMembership = @{
				SupportsRemove = $false
				IsStrict	   = $false
			};
			
			Set-PvContext_CollectionData -Membership $fakeMembership -Members @("one", "two", "four") -CurrentMember 'one';
			
			$members = $PVContext.Current.Collection.Members;
			$members | Should -Not -Be $null;
			$members.Count | Should -Be 3;
			
			$PVContext.Current.Collection.CurrentMember | Should -Be 'one';
		}
		
		It "Overwrites Collection Data on Set" {
			$fakeMembership = @{
				SupportsRemove = $false
				IsStrict	   = $false
			};
			
			Set-PvContext_CollectionData -Membership $fakeMembership -Members @("one", "two", "four") -CurrentMember 'one';
			
			# overwrite with new. Technically, pipeline SHOULD call clear before this gets invoked, but just verifying that it'll ALWAYS be reset... 
			Set-PvContext_CollectionData -Membership $fakeMembership -Members @("Frodo", "Sam") -CurrentMember 'Sam';
			$members = $PVContext.Current.Collection.Members;
			$members | Should -Not -Be $null;
			$members.Count | Should -Be 2;
			
			$PVContext.Current.Collection.CurrentMember | Should -Be 'Sam';
		}
		
		It "Allows Shorthand Access to Collection Data" {
			$fakeMembership = @{
				SupportsRemove = $false
				IsStrict	   = $false
			};
			
			Set-PvContext_CollectionData -Membership $fakeMembership -Members @("Bilbo", "Frodo", "Sam") -CurrentMember 'Sam';
			$members = $PVCurrent.Collection.Members;
			$members | Should -Not -Be $null;
			$members.Count | Should -Be 3;
			
			$PVCurrent.Collection.CurrentMember | Should -Be 'Sam';
		}
		
		It "Clears Collection Data on Remove" {
			$fakeMembership = @{
				SupportsRemove = $false
				IsStrict	   = $false
			};
			
			Set-PvContext_CollectionData -Membership $fakeMembership -Members @("Bilbo", "Frodo", "Sam") -CurrentMember 'Sam';
			($PVCurrent.Collection.Members).Count | Should -Be 3;
			$PVCurrent.Collection.CurrentMember | Should -Be 'Sam';
			
			Remove-PvContext_CollectionData;
			
			$PVCurrent.Collection.Members | Should -Be $null;
			$PVCurrent.Collection.CurrentMember | Should -Be $null;
		}
	}
}