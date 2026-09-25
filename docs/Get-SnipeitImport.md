---
external help file: SnipeitPS-help.xml
Module Name: SnipeitPS
online version:
schema: 2.0.0
---

# Get-SnipeitImport

## SYNOPSIS

Gets uploaded import files from Snipe-IT.

## SYNTAX

```
Get-SnipeitImport [[-Session] <SnipeitSession>] [-ProgressAction <ActionPreference>] [<CommonParameters>]
```

## DESCRIPTION

Retrieves an unpaginated list of uploaded CSV/TSV import files available to the current user (or all imports for a
superuser) in Snipe-IT.

## EXAMPLES

### EXAMPLE 1

```powershell
Get-SnipeitImport
```

## PARAMETERS

### -Session

Optional custom SnipeitSession instance.

```yaml
Type: SnipeitSession
Parameter Sets: (All)
Aliases:

Required: False
Position: 1
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -ProgressAction

Controls how PowerShell displays progress records. Available in PowerShell 7.4 and later.

```yaml
Type: ActionPreference
Parameter Sets: (All)
Aliases: proga

Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### CommonParameters

This cmdlet supports the common parameters: -Debug, -ErrorAction, -ErrorVariable, -InformationAction,
-InformationVariable, -OutVariable, -OutBuffer, -PipelineVariable, -Verbose, -WarningAction, and -WarningVariable. For
more information, see [about_CommonParameters](http://go.microsoft.com/fwlink/?LinkID=113216).

## INPUTS

## OUTPUTS

### System.Management.Automation.PSCustomObject

## NOTES

## RELATED LINKS
