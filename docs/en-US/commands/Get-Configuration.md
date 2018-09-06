---
external help file: AtlassianPS.Configuration-help.xml
Module Name: AtlassianPS.Configuration
online version: https://atlassianps.org/docs/AtlassianPS.Configuration/commands/Get-Configuration/
locale: en-US
schema: 2.0.0
layout: documentation
permalink: /docs/AtlassianPS.Configuration/commands/Get-Configuration/
---
# Get-Configuration

## SYNOPSIS

Retrieve a stored configuration

## SYNTAX

### asObject (Default)

```powershell
Get-AtlassianConfiguration [[-Name] <String[]>] [-ValueOnly] [<CommonParameters>]
```

### asValue

```powershell
Get-AtlassianConfiguration [[-Name] <String[]>] [-ValueOnly] [<CommonParameters>]
```

### asHashtable

```powershell
Get-AtlassianConfiguration [[-Name] <String[]>] [-AsHashtable] [<CommonParameters>]
```

## DESCRIPTION

Retrieve a stored configuration.

The object return can be customized as needed with the parameters `-AsHashtable` and `-ValueOnly`.

## EXAMPLES

### EXAMPLE 1

```powershell
Get-AtlassianConfiguration
```

Get all stored servers

> Each entry is returned as a PSCustomObject where the `Name` is the name of the
> entry and the `Value` is it's value.
> This is used for using the pipeline. See Example 4.
> Use `-ValueOnly` if interested _only_ in the value.

### EXAMPLE 2

```powershell
Set-AtlassianConfiguration -Name "Headers" -Value @{ Authorization = "Basic ABCDEF" }

Get-AtlassianConfiguration -Name "Headers"
```

Get a specific entry in the configuration.

> Each entry is returned as a PSCustomObject where the `Name` is the name of the
> entry and the `Value` is it's value.
> This is used for using the pipeline. See Example 4.
> Use `-ValueOnly` if interested _only_ in the value.

### EXAMPLE 3

```powershell
Set-AtlassianConfiguration -Name "Headers" -Value @{ Authorization = "Basic ABCDEF" }

Get-AtlassianConfiguration -Name "Headers" -ValueOnly
```

Get the value of a specific entry in the configuration.

### EXAMPLE 4

```powershell
Set-AtlassianConfiguration -Name "Headers" -Value @{ Authorization = "Basic ABCDEF" }
Set-AtlassianConfiguration -Name "SomethingElse" -Value (Get-Date)

"Headers", "SomethingElse", "SomethingMissing" |
    Get-AtlassianConfiguration |
    Set-AtlassianConfiguration -Value $null
```

> Command is spread across multiple lines to be easier to read

This example uses the pipeline twice:

1. The `-Name` of the entry is passed from the three string
2. The `-Name` of the two entries found are passed to `Set-AtlassianConfiguration`
3. `Set-AtlassianConfiguration` resets the value of the two entries

### EXAMPLE 5

```powershell
Set-AtlassianConfiguration -Name "Headers" -Value @{ Authorization = "Basic ABCDEF" }

Get-AtlassianConfiguration -AsHashtable
```

This example will return a hashtable (key-value pair) where `Headers` is the key.

## PARAMETERS

### -Name

Name of the configuration to be retrieved

Is not case sensitive

```yaml
Type: String[]
Parameter Sets: (All)
Aliases:

Required: False
Position: 1
Default value: *
Accept pipeline input: True (ByPropertyName, ByValue)
Accept wildcard characters: True
```

### -ValueOnly

Determine that this cmdlet shall only return the value of the configuration.

```yaml
Type: SwitchParameter
Parameter Sets: asValue
Aliases:

Required: True
Position: Named
Default value: False
Accept pipeline input: False
Accept wildcard characters: False
```

### -AsHashtable

Determine the result shall be return as a hashtable.

```yaml
Type: SwitchParameter
Parameter Sets: asHashtable
Aliases:

Required: True
Position: Named
Default value: False
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

## OUTPUTS

### [System.Management.Automation.PSObject]

### [System.Hashtable]

## NOTES

## RELATED LINKS

[Set-Configuration](../Set-Configuration/)

[Remove-Configuration](../Remove-Configuration/)

[Export-Configuration](../Export-Configuration/)
