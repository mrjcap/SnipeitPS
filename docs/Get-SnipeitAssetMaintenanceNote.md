---
external help file: SnipeitPS-help.xml
Module Name: SnipeitPS
online version:
schema: 2.0.0
---

# Get-SnipeitAssetMaintenanceNote

## SYNOPSIS

Get maintenance journal notes.

## SYNTAX

```
Get-SnipeitAssetMaintenanceNote [-id] <Int32[]> [[-Session] <SnipeitSession>]
 [-ProgressAction <ActionPreference>] [<CommonParameters>]
```

## DESCRIPTION

GET /api/v1/maintenances/{id}/notes returns a payload containing notes and maintenance_id for each record. The server
lists journal entries with action_type "note added", newest first. Completion action notes are not included.

## EXAMPLES

### Example 1

```powershell
Get-SnipeitAssetMaintenanceNote -id 44
```

Retrieves records using the current connection.

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

### -Session

Optional SnipeitSession instance. If omitted or null, uses the current module connection.

```yaml
Type: SnipeitSession
Parameter Sets: (All)
Aliases:

Required: False
Position: 2
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

### System.Management.Automation.PSObject

Accepts objects with matching properties: id.

## OUTPUTS

### System.Management.Automation.PSCustomObject

Returns the API response processed by the module dispatcher.

## NOTES

Requires a connection to a Snipe-IT server that supports this endpoint.

## RELATED LINKS

[Connect-SnipeitPS](Connect-SnipeitPS.md)
