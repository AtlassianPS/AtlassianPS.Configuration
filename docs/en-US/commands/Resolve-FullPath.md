---
external help file: AtlassianPS.Configuration-help.xml
Module Name: AtlassianPS.Configuration
online version: https://atlassianps.org/docs/AtlassianPS.Configuration/commands/Resolve-FullPath/
locale: en-US
schema: 2.0.0
layout: documentation
permalink: /docs/AtlassianPS.Configuration/commands/Resolve-FullPath/
---
# Resolve-FullPath

## SYNOPSIS

Validates and resolves a file path to its full provider path.

## SYNTAX

```powershell
Resolve-AtlassianFullPath [-Path] <String> [<CommonParameters>]
```

## DESCRIPTION

Verifies that a file exists and returns the unresolved provider path as a
fully qualified file-system path.

## EXAMPLES

### EXAMPLE 1

```powershell
$path = Join-Path -Path ([System.IO.Path]::GetTempPath()) -ChildPath 'atlassianps-config-fullpath.txt'
Set-Content -LiteralPath $path -Value 'sample'
Resolve-AtlassianFullPath -Path $path
```

Returns the absolute path for the existing file.

## PARAMETERS

### -Path

Path to an existing file.

```yaml
Type: String
Parameter Sets: (All)
Aliases: FullName, PSPath

Required: True
Position: 1
Default value: None
Accept pipeline input: True (ByPropertyName, ByValue)
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

System.String

## NOTES

## RELATED LINKS

[Resolve-FilePath](../Resolve-FilePath/)
