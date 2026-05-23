---
external help file: AtlassianPS.Configuration-help.xml
Module Name: AtlassianPS.Configuration
online version: https://atlassianps.org/docs/AtlassianPS.Configuration/commands/Resolve-FilePath/
locale: en-US
schema: 2.0.0
layout: documentation
permalink: /docs/AtlassianPS.Configuration/commands/Resolve-FilePath/
---
# Resolve-FilePath

## SYNOPSIS

Resolves a file path to an absolute provider path.

## SYNTAX

```powershell
Resolve-AtlassianFilePath [-Path] <String> [<CommonParameters>]
```

## DESCRIPTION

Resolves relative and provider paths into a fully qualified file-system path.

## EXAMPLES

### EXAMPLE 1

```powershell
$folder = Join-Path -Path ([System.IO.Path]::GetTempPath()) -ChildPath 'atlassianps-config-example'
New-Item -Path $folder -ItemType Directory -Force | Out-Null
$filePath = Join-Path -Path $folder -ChildPath 'sample.txt'
Set-Content -LiteralPath $filePath -Value 'sample'

Push-Location -Path $folder
try {
    Resolve-AtlassianFilePath -Path './sample.txt'
}
finally {
    Pop-Location
}
```

Resolves a relative file name to its absolute path.

## PARAMETERS

### -Path

Path to a file that should be resolved.

```yaml
Type: String
Parameter Sets: (All)
Aliases: PSPath, LiteralPath

Required: True
Position: 1
Default value: None
Accept pipeline input: True (ByValue)
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
