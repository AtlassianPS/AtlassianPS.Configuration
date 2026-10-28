function New-ConnectionContext {
    # .ExternalHelp ..\AtlassianPS.Configuration-help.xml
    [Diagnostics.CodeAnalysis.SuppressMessageAttribute(
        'PSUseShouldProcessForStateChangingFunctions',
        '',
        Justification = 'Creates an unregistered in-memory candidate; it does not perform HTTP or persist state.'
    )]
    [CmdletBinding()]
    [OutputType( [AtlassianPS.Connection] )]
    param(
        [ValidateNotNullOrEmpty()]
        [String]
        $Name,

        [Parameter( Mandatory )]
        [ValidateNotNullOrEmpty()]
        [String]
        $Product,

        [Parameter( Mandatory )]
        [Uri]
        $BaseUri,

        [Uri]
        $SiteUri,

        [String]
        $CloudId,

        [PSCredential]
        $Credential,

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

    Write-DebugMessage -BoundParameters $PSBoundParameters

    if (-not $PSBoundParameters.ContainsKey('Name')) {
        do {
            $script:NextGeneratedName++
            $Name = '{0}-{1}' -f $Product, $script:NextGeneratedName
        } while (Get-Connection -Product $Product -Name $Name)
    }

    if (-not $BaseUri.IsAbsoluteUri -or $BaseUri.Scheme -notin @('http', 'https') -or
        $BaseUri.UserInfo -or $BaseUri.Query -or $BaseUri.Fragment
    ) {
        throw 'BaseUri must be an absolute HTTP(S) product endpoint without user information, query or fragment.'
    }

    $modes = @(
        'Credential',
        'ApiToken',
        'PersonalAccessToken',
        'Anonymous' |
            Where-Object { $PSBoundParameters.ContainsKey($_) }
    )
    if ($modes.Count -ne 1) { throw 'Supply exactly one authentication mode.' }
    $authenticationMode = $modes[0]
    if ($PSBoundParameters.ContainsKey('EmailAddress') -and $authenticationMode -ne 'ApiToken') {
        throw 'EmailAddress requires ApiToken.'
    }
    if ($authenticationMode -eq 'Anonymous' -and -not $Anonymous) { throw 'Anonymous must be enabled explicitly.' }
    if ($authenticationMode -eq 'Credential' -and
        (-not $Credential -or $Credential -eq [PSCredential]::Empty -or
        [string]::IsNullOrWhiteSpace($Credential.UserName) -or $Credential.Password.Length -eq 0
        )
    ) {
        throw 'Credential must contain a username and password.'
    }
    if ($authenticationMode -eq 'ApiToken' -and [string]::IsNullOrWhiteSpace($EmailAddress)) {
        throw 'ApiToken requires EmailAddress.'
    }

    $token = $null
    try {
        if ($authenticationMode -in @('ApiToken', 'PersonalAccessToken')) {
            $token = ConvertTo-ConnectionToken -Token $PSBoundParameters[$authenticationMode]
        }

        $context = [AtlassianPS.Connection]::new(
            $Name,
            $Product,
            [Uri]$BaseUri.AbsoluteUri.TrimEnd('/'),
            $SiteUri,
            $CloudId,
            $authenticationMode,
            $EmailAddress,
            $Credential,
            $token,
            $script:RegistryGeneration
        )

        for ($index = $script:RequestContexts.Count - 1; $index -ge 0; $index--) {
            $existing = $script:RequestContexts[$index].Target
            if (-not $existing -or $existing.State -eq 'Disconnected') { $script:RequestContexts.RemoveAt($index) }
        }

        $script:RequestContexts.Add([WeakReference]::new($context))

        $context
    }
    finally {
        if ($token) { $token.Dispose() }
    }
}
