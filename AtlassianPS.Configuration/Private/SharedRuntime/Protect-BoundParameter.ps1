function Protect-BoundParameter {
    [CmdletBinding()]
    [OutputType([System.Collections.IDictionary])]
    param(
        [Parameter( Mandatory )]
        [System.Collections.IDictionary]
        $BoundParameters
    )

    $parameters = [Ordered]@{}
    foreach ($key in $BoundParameters.Keys) {
        $value = $BoundParameters[$key]
        if ($key -match 'Credential|Password|Token|Secret|Cookie|Authorization|Headers|Body' -or
            $value -is [PSCredential] -or $value -is [SecureString]
        ) {
            $parameters[$key] = '[REDACTED]'
        }
        elseif ($null -eq $value) { $parameters[$key] = $null }
        elseif ($value -is [Uri]) {
            if ($value.IsAbsoluteUri) {
                $parameters[$key] = $value.GetComponents([UriComponents]'SchemeAndServer, Path', [UriFormat]::UriEscaped)
            }
            else { $parameters[$key] = ($value.OriginalString -split '[?#]', 2)[0] }
        }
        elseif ($value -is [String] -or $value.GetType().IsPrimitive -or $value -is [Switch]) {
            $parameters[$key] = $value
        }
        else { $parameters[$key] = "[$($value.GetType().FullName)]" }
    }

    return $parameters
}
