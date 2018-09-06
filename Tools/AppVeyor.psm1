function Get-AppVeyorProject {
    [CmdletBinding()]
    param(
        [Parameter()]
        [ValidateNotNullOrEmpty()]
        [String]
        $AccountName = $env:APPVEYOR_ACCOUNT_NAME,

        [Parameter()]
        [ValidateNotNullOrEmpty()]
        [String]
        $ProjectName = $env:APPVEYOR_PROJECT_SLUG,

        [Parameter()]
        [ValidateNotNullOrEmpty()]
        [String]
        $Token = $env:APPVEYOR_API_TOKEN
    )

    begin {
        if (-not $AccountName) {
            $Exception = New-Object "System.ApplicationException" "Missing AccountName"
            $errorRecord = New-Object System.Management.Automation.ErrorRecord $Exception, "AppVeyor.MissingAccountName", "InvalidData", $AccountName
            $PSCmdlet.ThrowTerminatingError($errorRecord)
        }

        if (-not $ProjectName) {
            $Exception = New-Object "System.ApplicationException" "Missing ProjectName"
            $errorRecord = New-Object System.Management.Automation.ErrorRecord $Exception, "AppVeyor.MissingProjectName", "InvalidData", $ProjectName
            $PSCmdlet.ThrowTerminatingError($errorRecord)
        }

        if (-not $Token) {
            $Exception = New-Object "System.ApplicationException" "Missing Authentication Token"
            $errorRecord = New-Object System.Management.Automation.ErrorRecord $Exception, "AppVeyor.MissingToken", "InvalidData", $Token
            $PSCmdlet.ThrowTerminatingError($errorRecord)
        }
    }

    process {
        $invokeRestMethodSplat = @{
            Uri         = "https://ci.appveyor.com/api/projects/$AccountName/$ProjectName"
            Method      = "GET"
            Headers     = @{
                "Authorization" = "Bearer $Token"
            }
            ContentType = "application/json"
        }
        Write-Debug "Using `$invokeRestMethodSplat"
        Invoke-RestMethod @invokeRestMethodSplat
    }
}

function Get-AppVeyorArtifact {
    [CmdletBinding()]
    param(
        [Parameter( Mandatory, ValueFromPipeline )]
        [ValidateNotNullOrEmpty()]
        [PSCustomObject]
        $Job,

        [Parameter()]
        [ValidateNotNullOrEmpty()]
        [String]
        $Token = $env:APPVEYOR_API_TOKEN
    )

    begin {
        if (-not $Token) {
            $Exception = New-Object "System.ApplicationException" "Missing Authentication Token"
            $errorRecord = New-Object System.Management.Automation.ErrorRecord $Exception, "AppVeyor.MissingToken", "InvalidData", $Token
            $PSCmdlet.ThrowTerminatingError($errorRecord)
        }
    }

    process {
        $invokeRestMethodSplat = @{
            Uri         = "https://ci.appveyor.com/api/buildjobs/{0}/artifacts" -f $Job.JobId
            Method      = "GET"
            Headers     = @{
                "Authorization" = "Bearer $Token"
            }
            ContentType = "application/json"
        }
        Invoke-RestMethod @invokeRestMethodSplat
    }
}

function Get-AppVeyorArtifactFile {
    [CmdletBinding()]
    param(
        [Parameter( Mandatory )]
        [ValidateNotNullOrEmpty()]
        [PSCustomObject]
        $Job,

        [Parameter( Mandatory, ValueFromPipeline )]
        [ValidateNotNullOrEmpty()]
        [PSCustomObject]
        $Artifact,

        [String]
        $OutPath = (Get-Location -PSProvider FileSystem).Path,

        [Parameter()]
        [ValidateNotNullOrEmpty()]
        [String]
        $Token = $env:APPVEYOR_API_TOKEN
    )

    begin {
        if (-not (Test-Path $OutPath)) {
            $Exception = New-Object "System.ApplicationException" "Invalid path for storing artifacts"
            $errorRecord = New-Object System.Management.Automation.ErrorRecord $Exception, "AppVeyor.InvalidOutPath", "ObjectNotFound", $OutPath
            $PSCmdlet.ThrowTerminatingError($errorRecord)
        }

        if (-not $Token) {
            $Exception = New-Object "System.ApplicationException" "Missing Authentication Token"
            $errorRecord = New-Object System.Management.Automation.ErrorRecord $Exception, "AppVeyor.MissingToken", "InvalidData", $Token
            $PSCmdlet.ThrowTerminatingError($errorRecord)
        }

        Write-Verbose "Storing artifacts to $OutPath"
    }

    process {
        $Artifact | ForEach-Object {
            $_artifact = $_
            $invokeRestMethodSplat = @{
                Uri     = "https://ci.appveyor.com/api/buildjobs/{0}/artifacts/{1}" -f $Job.JobId, $_artifact.fileName
                Method  = "GET"
                Headers = @{
                    "Authorization" = "Bearer $Token"
                }
                OutFile = "$OutPath/$($_artifact.fileName)"
            }
            Invoke-RestMethod @invokeRestMethodSplat
        }
    }
}
