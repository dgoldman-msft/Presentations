function Get-SessionType {
	<#
		.Synopsis
			Custom PowerShell session reporter

		.Description
			This is a wrapper function for Get-PSSession

		.Example
			Get-SessionType

		.Notes
            NOTE: This output uses a custom ps1xml file PowerShellUtilities.Sessions
	#>


	[OutputType('PSUtilities.Sessions')]
	[Alias('gses')]
	[CmdletBinding(DefaultParameterSetName = "Default")]
	param()

	process {
		Write-PSFMessage -Level Verbose  -Message "Retreiving Sessions"
		try {
			foreach ($session in Get-PSSession) {
				if ($session.Name -like 'ExchangeOnline*') { [string]$Name = 'Exo' }
				else { [string]$Name = $session.Name }

				if ($session.psbase.ApplicationPrivateData.ContainsKey('SupportedVersions')) {
					[string]$SupportedVersions = ($session.psbase).ApplicationPrivateData.SupportedVersions.ToString()
				}
				else { [string]$SupportedVersions = 'Not Available' }

				[PSCustomObject]@{
					PSTypeName                      = 'PSUtilities.Sessions'
					Id                              = $session.Id
					Name                            = $Name
					ComputerName                    = $session.ComputerName
					Type                            = $session.ComputerType
					SessionState                    = $session.State
					VersionsSupported               = $SupportedVersions
					ServerConfig                    = $session.ConfigurationName
					IsAvailabile                    = $session.Availability
					# Connection Information
					AppName                         = $session.Runspace.ConnectionInfo.AppName
					ConnectionURI                   = $session.Runspace.ConnectionInfo.ConnectionURI
					ProxyAuthentication             = $session.Runspace.ConnectionInfo.ProxyAuthentication
					ProxyAccessType                 = $session.Runspace.ConnectionInfo.ProxyAccessType
					Port                            = $session.Runspace.ConnectionInfo.Port
					UseCompression                  = $session.Runspace.ConnectionInfo.UseCompression
					# Timeout Information
					'CancelTimeout - In Hours'      = (New-Timespan -seconds ($session.Runspace.ConnectionInfo.CancelTimeout / 1000)).TotalMinutes
					'IdleTimeout - In Minutes'      = (New-Timespan -seconds ($session.Runspace.ConnectionInfo.IdleTimeout / 1000)).TotalMinutes
					'IdleTimeout - In Hours'        = (New-Timespan -seconds ($session.Runspace.ConnectionInfo.IdleTimeout / 1000)).TotalHours
					'OpenTimeout - In Minutes'      = (New-Timespan -seconds ($session.Runspace.ConnectionInfo.OpenTimeout / 1000)).TotalMinutes
					'OpenTimeout - In Hours'        = (New-Timespan -seconds ($session.Runspace.ConnectionInfo.OpenTimeout / 1000)).TotalHours
					'OperationTimeout - In Minutes' = (New-Timespan -seconds ($session.Runspace.ConnectionInfo.OperationTimeout / 1000)).TotalMinutes
    }
			}
		}
		catch {
			Stop-PSFFunction -Message "ERROR: Get-Session failure" -Cmdlet $PSCmdlet -ErrorRecord $_
		}
	}
}