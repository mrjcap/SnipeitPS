---
external help file: SnipeitPS-help.xml
Module Name: SnipeitPS
online version:
schema: 2.0.0
---

# New-SnipeitFile

## SYNOPSIS

Uploads a file attachment to an entity in Snipe-IT.

## SYNTAX

```
New-SnipeitFile [-EntityType] <String> [-id] <Int32> [-File] <Object[]> [-notes <String>]
 [-Session <SnipeitSession>] [-ProgressAction <ActionPreference>] [-WhatIf] [-Confirm] [<CommonParameters>]
```

## DESCRIPTION

Attaches one or more files to an allowlisted Snipe-IT entity using multipart/form-data upload. Preserves raw binary
bytes and Unicode filenames. Supported entity types include accessories, audits, assets, components, consumables,
hardware, licenses, locations, maintenances, models, suppliers, users, companies, and departments.

## EXAMPLES

### EXAMPLE 1

```powershell
New-SnipeitFile -EntityType 'hardware' -id 100 -File 'C:\Docs\manual.pdf' -notes 'Hardware manual'
```

## PARAMETERS

### -EntityType

The type of object to upload files to. Supported types: accessories, audits, assets, components, consumables, hardware,
licenses, locations, maintenances, models, suppliers, users, companies, departments.

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: True
Position: 1
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -id

The ID of the parent entity to attach files to.

```yaml
Type: Int32
Parameter Sets: (All)
Aliases:

Required: True
Position: 2
Default value: 0
Accept pipeline input: True (ByPropertyName)
Accept wildcard characters: False
```

### -File

Path(s) or FileInfo object(s) of the file(s) to upload.

```yaml
Type: Object[]
Parameter Sets: (All)
Aliases: Files

Required: True
Position: 3
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -notes

Optional notes associated with the uploaded file(s).

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -Session

Optional custom SnipeitSession instance.

```yaml
Type: SnipeitSession
Parameter Sets: (All)
Aliases:

Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -WhatIf

Shows what would happen if the cmdlet runs. The cmdlet is not run.

```yaml
Type: SwitchParameter
Parameter Sets: (All)
Aliases: wi

Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -Confirm

Prompts you for confirmation before running the cmdlet.

```yaml
Type: SwitchParameter
Parameter Sets: (All)
Aliases: cf

Required: False
Position: Named
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
