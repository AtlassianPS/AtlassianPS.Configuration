---
external help file: AtlassianPS.Configuration-help.xml
Module Name: AtlassianPS.Configuration
online version: https://atlassianps.org/docs/AtlassianPS.Configuration/commands/Write-DebugMessage/
locale: en-US
schema: 2.0.0
layout: documentation
permalink: /docs/AtlassianPS.Configuration/commands/Write-DebugMessage/
---
# Write-DebugMessage

## SYNOPSIS

Writes a debug message while preserving the current debug preference.

## SYNTAX

```powershell
Write-AtlassianDebugMessage [[-Message] <String>] [-BreakPoint] [[-Cmdlet] <PSCmdlet>] [<CommonParameters>]
```

## DESCRIPTION

Writes debug output and restores the original `$DebugPreference` value after
processing.

## EXAMPLES

### EXAMPLE 1

```powershell
$DebugPreference = 'Continue'
Write-AtlassianDebugMessage -Message 'Shared runtime diagnostic message.'
```

Writes the debug message and keeps the same debug preference in scope.

## PARAMETERS

### -Message

Message to write to the debug stream.

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: False
Position: 1
Default value: None
Accept pipeline input: True (ByValue)
Accept wildcard characters: False
```

### -BreakPoint

When set, preserves the current debug preference behavior instead of forcing
`Continue`.

```yaml
Type: SwitchParameter
Parameter Sets: (All)
Aliases:

Required: False
Position: Named
Default value: False
Accept pipeline input: False
Accept wildcard characters: False
```

### -Cmdlet

Optional cmdlet context used by legacy callers.

```yaml
Type: PSCmdlet
Parameter Sets: (All)
Aliases:

Required: False
Position: Named
Default value: $PSCmdlet
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

System.String

## OUTPUTS

None

## NOTES

## RELATED LINKS

[Write-NonTerminatingError](../Write-NonTerminatingError/)
