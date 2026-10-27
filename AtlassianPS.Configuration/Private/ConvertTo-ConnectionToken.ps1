function ConvertTo-ConnectionToken {
    [Diagnostics.CodeAnalysis.SuppressMessageAttribute(
        'PSAvoidUsingConvertToSecureStringWithPlainText',
        '',
        Justification = 'The public contract accepts CI string tokens; normalization retains an owned SecureString copy.'
    )]
    [CmdletBinding()]
    [OutputType( [System.Security.SecureString] )]
    param(
        [Parameter( Mandatory )]
        [AllowNull()]
        [AllowEmptyString()]
        [Object]
        $Token
    )

    if ($Token -is [System.Security.SecureString]) {
        if ($Token.Length -eq 0) { throw 'Token cannot be empty.' }
        return $Token.Copy()
    }

    if ($Token -is [string] -and -not [string]::IsNullOrWhiteSpace($Token)) {
        return ConvertTo-SecureString -String $Token -AsPlainText -Force
    }

    throw 'Token must be a nonempty string or SecureString.'
}
