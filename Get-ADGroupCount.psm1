Function Get-ADGroupCount {
	<#
	.NAME
	Get-ADGroupCount
	.SYNOPSIS
	Get an AD object's group count
	.DESCRIPTION
	Recurses through an object's group memberships to find out the total number of groups.
	.EXAMPLE
	Get-ADGroupCount -Object user1
	#>

	[CmdletBinding(
		SupportsShouldProcess=$false,
		ConfirmImpact="None"
	)]

	Param(
		[Parameter(ValueFromPipeline=$true,Position=0)]
		[ValidateNotNullOrEmpty()]
		[string] $Object
	)

	begin {
		Function Recurse {
			Param(
				[Parameter()]
				[int] $Depth,
				
				[Parameter()]
				[object[]] $Groups
			)
			
			if (!$Groups) { return }
			
			foreach ($grp in $Groups) {
				$script:grouplist += $grp
				
				Write-Output ([string]::join("", ("`t" * $Depth), "-> ", $grp.Name))

				Recurse -Depth ($Depth + 1) -Groups (Get-ADPrincipalGroupMembership $grp)
			}
		}
	}

	process {
		$script:grouplist = @()
		
		Write-Output ([string]::format("Object : {0}`n", $Object))
		
		Recurse -Depth 0 -Groups (Get-ADPrincipalGroupMembership $Object)
		
		Write-Output ("`nGroup membership count (absolute) : {0}" -f @($script:grouplist).Length)
		Write-Output ("Group membership count (unique)   : {0}" -f @($script:grouplist | Sort-Object | Get-Unique).Length)
	}

	end {
		
	}
}
