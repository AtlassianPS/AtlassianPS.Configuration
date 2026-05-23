---
external help file: AtlassianPS.Configuration-help.xml
Module Name: AtlassianPS.Configuration
online version: https://atlassianps.org/docs/AtlassianPS.Configuration/commands/Write-TerminatingError/
locale: en-US
schema: 2.0.0
layout: documentation
permalink: /docs/AtlassianPS.Configuration/commands/Write-TerminatingError/
---
# Write-TerminatingError

## SYNOPSIS

Creates and throws terminating error records.

## SYNTAX

```powershell
Write-AtlassianTerminatingError [[-Cmdlet] <PSCmdlet>] -Exception <Exception>
 [[-TargetObject] <Object>] -ErrorId <String> -Category <ErrorCategory>
 [<CommonParameters>]
```

```powershell
Write-AtlassianTerminatingError [[-Cmdlet] <PSCmdlet>] [-Exception <Exception>]
 [-ExceptionType <String>] -Message <String> [[-TargetObject] <Object>]
 -ErrorId <String> -Category <ErrorCategory> [<CommonParameters>]
```

```powershell
Write-AtlassianTerminatingError [[-Cmdlet] <PSCmdlet>] -ErrorRecord <ErrorRecord>
 [<CommonParameters>]
```

## DESCRIPTION

Throws terminating errors either from an existing exception, a newly
constructed exception, or an existing error record.

## EXAMPLES

### EXAMPLE 1

```powershell
function Invoke-WriteTerminatingErrorExistingExample {
    [CmdletBinding()]
    param()

    Write-AtlassianTerminatingError `
        -Exception ([System.Exception]::new('existing-exception')) `
        -ErrorId 'Demo.WriteTerminatingError.Existing' `
        -Category InvalidOperation
}

try {
    Invoke-WriteTerminatingErrorExistingExample
}
catch {
    $_.FullyQualifiedErrorId
}
```

Throws a terminating error from an existing exception and catches it.

### EXAMPLE 2

```powershell
function Invoke-WriteTerminatingErrorNewExample {
    [CmdletBinding()]
    param()

    Write-AtlassianTerminatingError `
        -Message 'generated-exception' `
        -ExceptionType 'System.InvalidOperationException' `
        -ErrorId 'Demo.WriteTerminatingError.New' `
        -Category InvalidOperation
}

try {
    Invoke-WriteTerminatingErrorNewExample
}
catch {
    $_.FullyQualifiedErrorId
}
```

Throws a terminating error with a newly created exception type and catches it.

### EXAMPLE 3

```powershell
function Invoke-WriteTerminatingErrorRecordExample {
    [CmdletBinding()]
    param()

    $record = [System.Management.Automation.ErrorRecord]::new(
        [System.Exception]::new('rethrow-record'),
        'Demo.WriteTerminatingError.Record',
        [System.Management.Automation.ErrorCategory]::InvalidOperation,
        $null
    )

    Write-AtlassianTerminatingError -ErrorRecord $record
}

try {
    Invoke-WriteTerminatingErrorRecordExample
}
catch {
    $_.FullyQualifiedErrorId
}
```

Throws a terminating error from an existing error record and catches it.

## PARAMETERS

### -Cmdlet

Cmdlet runtime to use for throwing the error.
Defaults to the caller's `$PSCmdlet` when called from an advanced function.

```yaml
Type: PSCmdlet
Parameter Sets: (All)
Aliases:

Required: False
Position: 0
Default value: Caller $PSCmdlet
Accept pipeline input: False
Accept wildcard characters: False
```

### -Exception

Exception used to build the error record.

```yaml
Type: Exception
Parameter Sets: ExistingException, NewException
Aliases:

Required: True (ExistingException), False (NewException)
Position: 1
Default value: None
Accept pipeline input: True (ByPropertyName, ByValue)
Accept wildcard characters: False
```

### -ExceptionType

Exception type used when creating a new exception.

```yaml
Type: String
Parameter Sets: NewException
Aliases:

Required: False
Position: 2
Default value: System.Management.Automation.RuntimeException
Accept pipeline input: False
Accept wildcard characters: False
```

### -Message

Message used when creating a new exception.

```yaml
Type: String
Parameter Sets: NewException
Aliases:

Required: True
Position: 3
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -TargetObject

Target object associated with the error record.

```yaml
Type: Object
Parameter Sets: ExistingException, NewException
Aliases:

Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -ErrorId

Identifier for the generated error record.

```yaml
Type: String
Parameter Sets: ExistingException, NewException
Aliases:

Required: True
Position: 10
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -Category

Error category for the generated error record.

```yaml
Type: ErrorCategory
Parameter Sets: ExistingException, NewException
Aliases:

Required: True
Position: 11
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -ErrorRecord

Existing error record to throw directly.

```yaml
Type: ErrorRecord
Parameter Sets: Rethrow
Aliases:

Required: True
Position: 1
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### CommonParameters

This cmdlet supports the common parameters: -Debug, -ErrorAction,
-ErrorVariable, -InformationAction, -InformationVariable, -OutVariable,
-OutBuffer, -PipelineVariable, -Verbose, -WarningAction, and -WarningVariable.
For more information, see about_CommonParameters
(<http://go.microsoft.com/fwlink/?LinkID=113216>).

## INPUTS

System.Exception, System.Management.Automation.ErrorRecord

## OUTPUTS

None

## NOTES

## RELATED LINKS

[Write-NonTerminatingError](../Write-NonTerminatingError/)
