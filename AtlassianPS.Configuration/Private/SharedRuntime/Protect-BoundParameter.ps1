function Protect-BoundParameter {
    <#
    .SYNOPSIS
        Returns a redacted copy of bound command parameters.

    .DESCRIPTION
        Redacts values whose parameter names contain Credential, Password, Token, Secret, Cookie, Authorization, Headers or Body.
        PSCredential and SecureString values are redacted regardless of their parameter names.
        Values typed as Uri omit user information, queries and fragments.
        Other strings, primitive values, switches and nulls are preserved; complex objects become type names.
        The input dictionary remains unchanged, and the calling writer formats the returned copy.

    .PARAMETER BoundParameters
        Dictionary of command inputs to sanitize before diagnostic formatting.

    .EXAMPLE
        $parameters = Protect-BoundParameter -BoundParameters $PSBoundParameters

        Creates an ordered copy suitable for a debug or verbose parameter trace.

    .OUTPUTS
        System.Collections.Specialized.OrderedDictionary
    #>
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
