---
external help file: SnipeitPS-help.xml
Module Name: SnipeitPS
online version:
schema: 2.0.0
---

# Update-SnipeitAssetAudit

## SYNOPSIS

Audit an asset by ID, tag, or serial in Snipe-IT (supports single and bulk audits)

## SYNTAX

### ById (Default)

```powershell
Update-SnipeitAssetAudit [-id] <Int32[]> [[-location_id] <Int32>] [[-next_audit_date] <DateTime>]
 [[-note] <String>] [[-image] <String>] [[-url] <String>] [[-apiKey] <String>]
 [-WhatIf] [-Confirm] [<CommonParameters>]
```

### ByTag

```powershell
Update-SnipeitAssetAudit [-asset_tag] <String> [[-location_id] <Int32>] [[-next_audit_date] <DateTime>]
 [[-note] <String>] [[-image] <String>] [[-url] <String>] [[-apiKey] <String>]
 [-WhatIf] [-Confirm] [<CommonParameters>]
```

### BySerial

```powershell
Update-SnipeitAssetAudit [-serial] <String> [[-location_id] <Int32>] [[-next_audit_date] <DateTime>]
 [[-note] <String>] [[-image] <String>] [[-url] <String>] [[-apiKey] <String>]
 [-WhatIf] [-Confirm] [<CommonParameters>]
```

## DESCRIPTION

Audit an asset by ID, tag, or serial in Snipe-IT. Supports auditing multiple assets in bulk via array of IDs.

## EXAMPLES

### EXAMPLE 1

```powershell
Update-SnipeitAssetAudit -id 1 -location_id 5
```

### EXAMPLE 2

```powershell
Update-SnipeitAssetAudit -id 42, 43 -note "Q3 quarterly audit" -next_audit_date (Get-Date).AddMonths(3)
```

### EXAMPLE 3

```powershell
Update-SnipeitAssetAudit -id 1 -image "C:\photos\audit.jpg" -note "Physical check verified"
```

## PARAMETERS

### -apiKey

Deprecated parameter, please use Connect-SnipeitPS instead. User's API Key for Snipe-IT.

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: False
Position: 5
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -asset_tag

Asset tag of the asset to audit (Snipe-IT 8.7+ quickscan audit)

```yaml
Type: String
Parameter Sets: ByTag
Aliases:

Required: True
Position: Named
Default value: None
Accept pipeline input: True (ByPropertyName)
Accept wildcard characters: False
```

### -id

Unique ID of the asset or array of IDs to audit (bulk audit)

```yaml
Type: Int32[]
Parameter Sets: ById
Aliases:

Required: True
Position: 1
Default value: None
Accept pipeline input: True (ByPropertyName)
Accept wildcard characters: False
```

### -image

Path to an image file to upload and attach to the audit log.

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

### -note

Optional note for the audit log entry.

```yaml
Type: String
Parameter Sets: (All)
Aliases: notes

Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -serial

Serial number of the asset to audit (Snipe-IT 8.7+ quickscan audit)

```yaml
Type: String
Parameter Sets: BySerial
Aliases:

Required: True
Position: Named
Default value: None
Accept pipeline input: True (ByPropertyName)
Accept wildcard characters: False
```

### -location_id

ID of the location to associate with the audit

```yaml
Type: Int32
Parameter Sets: (All)
Aliases:

Required: False
Position: Named
Default value: 0
Accept pipeline input: False
Accept wildcard characters: False
```

### -next_audit_date

Due date for the asset's next audit

```yaml
Type: DateTime
Parameter Sets: (All)
Aliases:

Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -url

Deprecated parameter, please use Connect-SnipeitPS instead. URL of Snipe-IT system.

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

### CommonParameters

This cmdlet supports the common parameters: -Debug, -ErrorAction, -ErrorVariable,
-InformationAction, -InformationVariable, -OutVariable, -OutBuffer, -PipelineVariable,
-Verbose, -WarningAction, and -WarningVariable. For more information, see
[about_CommonParameters](http://go.microsoft.com/fwlink/?LinkID=113216).

## INPUTS

## OUTPUTS

## NOTES

## RELATED LINKS
