---
external help file: AtlassianPS.Configuration-help.xml
Module Name: AtlassianPS.Configuration
online version: https://atlassianps.org/docs/AtlassianPS.Configuration/commands/Write-VerboseMessage/
locale: en-US
schema: 2.0.0
layout: documentation
permalink: /docs/AtlassianPS.Configuration/commands/Write-VerboseMessage/
---
# Write-VerboseMessage

## SYNOPSIS

Writes a formatted verbose message.

## SYNTAX

```powershell
Write-AtlassianVerboseMessage [-Message] <String> [[-Cmdlet] <PSCmdlet>] [<CommonParameters>]
```

## DESCRIPTION

Writes verbose output using the configured message style settings (`Breadcrumbs`,
`Indent`, `FunctionName`, and `TimeStamp`).

Use this helper instead of shadowing PowerShell's built-in `Write-Verbose` command.

## EXAMPLES

### EXAMPLE 1

```powershell
Write-AtlassianVerboseMessage -Message 'Shared runtime diagnostic message.' -Verbose
```

Writes a verbose message using the configured message style.

### EXAMPLE 2

```powershell
Set-AtlassianConfiguration -Name Message -Value ([AtlassianPS.MessageStyle]::new(2, $false, $true, $false))
Write-AtlassianVerboseMessage -Message 'Shared runtime diagnostic message.' -Verbose
```

Writes a breadcrumb line and an indented verbose message based on the configured
message style.

## PARAMETERS

### -Message

Message to write to the verbose stream.

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: True
Position: 1
Default value: None
Accept pipeline input: True (ByValue)
Accept wildcard characters: False
```

### -Cmdlet

Optional cmdlet context used for function-name formatting.
Defaults to the caller's `$PSCmdlet` when called from an advanced function.

```yaml
Type: PSCmdlet
Parameter Sets: (All)
Aliases:

Required: False
Position: 2
Default value: Caller $PSCmdlet
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

[Write-DebugMessage](../Write-DebugMessage/)
