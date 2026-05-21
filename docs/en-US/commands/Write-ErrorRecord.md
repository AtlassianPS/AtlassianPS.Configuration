---
external help file: AtlassianPS.Configuration-help.xml
Module Name: AtlassianPS.Configuration
online version: https://atlassianps.org/docs/AtlassianPS.Configuration/commands/Write-ErrorRecord/
locale: en-US
schema: 2.0.0
layout: documentation
permalink: /docs/AtlassianPS.Configuration/commands/Write-ErrorRecord/
---
# Write-ErrorRecord

## SYNOPSIS

Creates and writes non-terminating error records.

## SYNTAX

```powershell
Write-AtlassianErrorRecord [[-Cmdlet] <PSCmdlet>] -Exception <Exception>
 [[-TargetObject] <Object>] -ErrorId <String> -Category <ErrorCategory>
 [<CommonParameters>]
```

```powershell
Write-AtlassianErrorRecord [[-Cmdlet] <PSCmdlet>] [-Exception <Exception>]
 [-ExceptionType <String>] -Message <String> [[-TargetObject] <Object>]
 -ErrorId <String> -Category <ErrorCategory> [<CommonParameters>]
```

```powershell
Write-AtlassianErrorRecord [[-Cmdlet] <PSCmdlet>] -ErrorRecord <ErrorRecord>
 [<CommonParameters>]
```

## DESCRIPTION

Writes non-terminating errors either from an existing exception, a newly
constructed exception, or an existing error record.

## EXAMPLES

### EXAMPLE 1

```powershell
function Invoke-WriteErrorExistingExample {
    [CmdletBinding()]
    param()

    Write-AtlassianErrorRecord `
        -Exception ([System.Exception]::new('existing-exception')) `
        -ErrorId 'Demo.WriteError.Existing' `
        -Category InvalidOperation `
        -ErrorAction SilentlyContinue
}

Invoke-WriteErrorExistingExample
```

Writes a non-terminating error from an existing exception.

### EXAMPLE 2

```powershell
function Invoke-WriteErrorNewExample {
    [CmdletBinding()]
    param()

    Write-AtlassianErrorRecord `
        -Message 'generated-exception' `
        -ExceptionType 'System.InvalidOperationException' `
        -ErrorId 'Demo.WriteError.New' `
        -Category InvalidOperation `
        -ErrorAction SilentlyContinue
}

Invoke-WriteErrorNewExample
```

Writes a non-terminating error with a newly created exception type.

### EXAMPLE 3

```powershell
function Invoke-WriteErrorRecordExample {
    [CmdletBinding()]
    param()

    $record = [System.Management.Automation.ErrorRecord]::new(
        [System.Exception]::new('rethrow-record'),
        'Demo.WriteError.Record',
        [System.Management.Automation.ErrorCategory]::InvalidOperation,
        $null
    )

    Write-AtlassianErrorRecord -ErrorRecord $record -ErrorAction SilentlyContinue
}

Invoke-WriteErrorRecordExample
```

Writes a non-terminating error using an existing error record.

## PARAMETERS

### -Cmdlet

Cmdlet runtime to use for writing the error. Defaults to `$PSCmdlet`.

```yaml
Type: PSCmdlet
Parameter Sets: (All)
Aliases:

Required: False
Position: 0
Default value: $PSCmdlet
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

Existing error record to write directly.

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

[Stop-ErrorRecord](../Stop-ErrorRecord/)
