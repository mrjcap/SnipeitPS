---
external help file: SnipeitPS-help.xml
Module Name: SnipeitPS
online version:
schema: 2.0.0
---

# Complete-SnipeitAssetMaintenance

## SYNOPSIS

Complete hardware asset maintenance.

## SYNTAX

```
Complete-SnipeitAssetMaintenance [-id] <Int32[]> [[-note] <String>] [[-Session] <SnipeitSession>]
 [-ProgressAction <ActionPreference>] [-WhatIf] [-Confirm] [<CommonParameters>]
```

## DESCRIPTION

POST /api/v1/maintenances/{id}/complete marks each record complete. The server sets completed_at to its current
timestamp and records the completing user. No client completion date is accepted. The optional note is recorded in the
completion action log, not as a separate journal note. The server rejects records that are already complete.

## EXAMPLES

### Example 1

```powershell
Complete-SnipeitAssetMaintenance -id 44 -note 'Inspection passed' -WhatIf
```

Previews the operation without changing server data.

## PARAMETERS

### -id

One or more maintenance record IDs, each from 1 to 2147483647.

```yaml
Type: Int32[]
Parameter Sets: (All)
Aliases:

Required: True
Position: 1
Default value: None
Accept pipeline input: True (ByPropertyName)
Accept wildcard characters: False
```

### -note

Optional completion action note. Allows null; sent only when explicitly bound.

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: False
Position: 2
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -Session

Optional SnipeitSession instance. If omitted or null, uses the current module connection.

```yaml
Type: SnipeitSession
Parameter Sets: (All)
Aliases:

Required: False
Position: 3
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -WhatIf

Shows the intended operation without sending the modifying request.

```yaml
Type: SwitchParameter
Parameter Sets: (All)
Aliases: wi

Required: False
Position: Named
Default value: False
Accept pipeline input: False
Accept wildcard characters: False
```

### -Confirm

Prompts for confirmation before sending the modifying request.

```yaml
Type: SwitchParameter
Parameter Sets: (All)
Aliases: cf

Required: False
Position: Named
Default value: False
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

### System.Management.Automation.PSObject

Accepts objects with matching properties: id.

## OUTPUTS

### System.Management.Automation.PSCustomObject

Returns the API response processed by the module dispatcher.

## NOTES

Requires a connection to a Snipe-IT server that supports this endpoint. Supports -WhatIf and -Confirm. Confirmation
impact is Medium.

## RELATED LINKS

[Connect-SnipeitPS](Connect-SnipeitPS.md)
