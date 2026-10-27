function Resolve-RequestContext {
    # .ExternalHelp ..\AtlassianPS.Configuration-help.xml
    [CmdletBinding()]
    [OutputType( [AtlassianPS.Connection] )]
    param(
        [Parameter( Mandatory )]
        [String]
        $Product,

        [Parameter( DontShow )]
        [AtlassianPS.Connection]
        $RequestContext,

        [AtlassianPS.Connection]
        $Connection,

        [String]
        $ConnectionName,

        [Uri]
        $BaseUri,

        [PSCredential]
        $Credential,

        [Alias('Email')]
        [String]
        $EmailAddress,

        [Object]
        $ApiToken,

        [Alias('PAT', 'BearerToken')]
        [Object]
        $PersonalAccessToken,

        [Switch]
        $Anonymous
    )

    if ($PSBoundParameters.ContainsKey('RequestContext')) {
        $conflicts = @(
            'Connection',
            'ConnectionName',
            'BaseUri',
            'Credential',
            'EmailAddress',
            'ApiToken',
            'PersonalAccessToken',
            'Anonymous'
        )
        $hasConflict = @($conflicts | Where-Object { $PSBoundParameters.ContainsKey($_) }).Count -gt 0
        if (-not $RequestContext -or $RequestContext.Product -ne $Product -or
            $RequestContext.RegistryGeneration -ne $script:RegistryGeneration -or
            $RequestContext.State -eq 'Disconnected' -or $hasConflict
        ) {
            throw 'Invalid internal request context.'
        }

        if ($RequestContext.State -eq 'Active' -or $RequestContext.IsOverride) {
            Assert-ConnectionActive -Connection $RequestContext -Product $Product
        }

        return $RequestContext
    }

    $selectors = @(
        'Connection',
        'ConnectionName',
        'BaseUri' |
            Where-Object { $PSBoundParameters.ContainsKey($_) }
    )
    if ($selectors.Count -gt 1) { throw 'Connection, ConnectionName and BaseUri are mutually exclusive.' }
    if ($PSBoundParameters.ContainsKey('Connection') -and -not $Connection) { throw 'Connection cannot be null.' }
    if ($PSBoundParameters.ContainsKey('ConnectionName') -and [string]::IsNullOrWhiteSpace($ConnectionName)) {
        throw 'ConnectionName cannot be empty.'
    }

    $auth = @{}
    foreach ($key in @('Credential', 'EmailAddress', 'ApiToken', 'PersonalAccessToken', 'Anonymous')) {
        if ($PSBoundParameters.ContainsKey($key)) { $auth[$key] = $PSBoundParameters[$key] }
    }

    if ($PSBoundParameters.ContainsKey('BaseUri') -and -not $BaseUri) { throw 'BaseUri cannot be null.' }
    if ($BaseUri) {
        $context = New-ConnectionContext -Name 'Standalone' -Product $Product -BaseUri $BaseUri @auth
        $context.MakeStandalone([Guid]::Empty)
        return $context
    }

    if ($ConnectionName) { $Connection = Get-Connection -Product $Product -Name $ConnectionName }
    elseif (-not $PSBoundParameters.ContainsKey('Connection')) { $Connection = Get-Connection -Product $Product -Default }
    if (-not $Connection) { throw "No $Product connection selected. Connect or select a connection first." }

    Assert-ConnectionActive -Connection $Connection -Product $Product
    if ($auth.Count -eq 0) { return $Connection }

    $contextParameters = @{
        Name    = $Connection.Name
        Product = $Product
        BaseUri = $Connection.BaseUri
        SiteUri = $Connection.SiteUri
        CloudId = $Connection.CloudId
    }

    $context = New-ConnectionContext @contextParameters @auth
    $context.SetValidationResult($Connection.DeploymentType, $null)
    $context.MakeStandalone($Connection.InstanceId)

    $context
}
