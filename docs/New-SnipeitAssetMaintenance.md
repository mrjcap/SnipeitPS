---
external help file: SnipeitPS-help.xml
Module Name: SnipeitPS
online version:
schema: 2.0.0
---

# New-SnipeitAssetMaintenance

## SYNOPSIS

Add a new Asset maintenance to Snipe-IT asset system

## SYNTAX

### ByAssetId (Default)

```
New-SnipeitAssetMaintenance [-asset_id] <Int32> [[-supplier_id] <Int32>] [-asset_maintenance_type] <String>
 [-title] <String> [-start_date] <DateTime> [[-expected_completion_date] <DateTime>] [[-is_warranty] <Boolean>]
 [[-cost] <Decimal>] [-url <String>] [-completed_at <DateTime>] [-completed_by <Int32>]
 [-asset_maintenance_time <Int32>] [-image <String>] [[-notes] <String>] [[-assigned_to] <Int32>]
 [[-responsible_party_id] <Int32>] [-preserveResponse] [[-Session] <SnipeitSession>]
 [-ProgressAction <ActionPreference>] [-WhatIf] [-Confirm] [<CommonParameters>]
```

### ByAssetIds

```
New-SnipeitAssetMaintenance -asset_ids <Int32[]> [[-supplier_id] <Int32>] [-asset_maintenance_type] <String>
 [-title] <String> [-start_date] <DateTime> [[-expected_completion_date] <DateTime>] [[-is_warranty] <Boolean>]
 [[-cost] <Decimal>] [-url <String>] [-completed_at <DateTime>] [-completed_by <Int32>]
 [-asset_maintenance_time <Int32>] [-image <String>] [[-notes] <String>] [[-assigned_to] <Int32>]
 [[-responsible_party_id] <Int32>] [-preserveResponse] [[-Session] <SnipeitSession>]
 [-ProgressAction <ActionPreference>] [-WhatIf] [-Confirm] [<CommonParameters>]
```

## DESCRIPTION

Add a new Asset maintenance to Snipe-IT asset system

## EXAMPLES

### EXAMPLE 1

```powershell
New-SnipeitAssetMaintenance -asset_id 1 -supplier_id 1 -asset_maintenance_type "Maintenance" `
 -title "replace keyboard" -start_date "2021-01-01"
```

## PARAMETERS

### -asset_id

Required ID of the asset for single creation. Mutually exclusive with asset_ids.

```yaml
Type: Int32
Parameter Sets: ByAssetId
Aliases:

Required: True
Position: 1
Default value: 0
Accept pipeline input: True (ByPropertyName, ByValue)
Accept wildcard characters: False
```

### -asset_ids

Array of positive asset IDs for bulk creation. Mutually exclusive with asset_id.

```yaml
Type: Int32[]
Parameter Sets: ByAssetIds
Aliases:

Required: True
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -supplier_id

Optional positive supplier ID. Pass null to leave the supplier unset.

```yaml
Type: Int32
Parameter Sets: (All)
Aliases:

Required: False
Position: 2
Default value: 0
Accept pipeline input: False
Accept wildcard characters: False
```

### -asset_maintenance_type

Existing numeric maintenance type ID or exact unique catalog name. Names, including built-in types, are resolved through
the server's maintenance-types catalog.

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: True
Position: 3
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -title

Required title/name of maintenance.

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: True
Position: 4
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -start_date

Required start date.

```yaml
Type: DateTime
Parameter Sets: (All)
Aliases:

Required: True
Position: 5
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -expected_completion_date

Optional expected completion date. Accepts null; completion_date is a legacy alias.

```yaml
Type: DateTime
Parameter Sets: (All)
Aliases: completion_date

Required: False
Position: 6
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -is_warranty

Optional maintenance done under warranty flag. Defaults to false.

```yaml
Type: Boolean
Parameter Sets: (All)
Aliases:

Required: False
Position: 7
Default value: False
Accept pipeline input: False
Accept wildcard characters: False
```

### -cost

Optional nullable cost. The server normalizes zero to null.

```yaml
Type: Decimal
Parameter Sets: (All)
Aliases:

Required: False
Position: 8
Default value: 0
Accept pipeline input: False
Accept wildcard characters: False
```

### -url

Optional related URL, up to 255 characters. An empty value clears the URL.

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

### -completed_at

Nullable actual completion timestamp. Must fall between start_date and the server's current time.

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

### -completed_by

Nullable positive ID of the user who completed the maintenance.

```yaml
Type: Int32
Parameter Sets: (All)
Aliases:

Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -asset_maintenance_time

Nullable recorded maintenance duration in days. Zero is preserved in the request.

```yaml
Type: Int32
Parameter Sets: (All)
Aliases:

Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -image

Path to an image to upload when creating maintenance for one asset. Bulk creation rejects images because the shared
multipart transport does not preserve the asset ID array.

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

### -notes

Optional notes.

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: False
Position: 9
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -assigned_to

Unsupported legacy input, rejected before HTTP. No automatic relationship mapping is possible.

```yaml
Type: Int32
Parameter Sets: (All)
Aliases:

Required: False
Position: 10
Default value: 0
Accept pipeline input: False
Accept wildcard characters: False
```

### -responsible_party_id

Nullable ID of the User responsible for maintenance, not the asset checkout snapshot. The checkout snapshot is captured
automatically by the server when maintenance is created.

```yaml
Type: Int32
Parameter Sets: (All)
Aliases: responsible_party

Required: False
Position: 11
Default value: 0
Accept pipeline input: False
Accept wildcard characters: False
```

### -preserveResponse

When specified, preserves the complete response envelope instead of extracting the payload.

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

### -Session

Optional custom SnipeitSession instance.

```yaml
Type: SnipeitSession
Parameter Sets: (All)
Aliases:

Required: False
Position: 12
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

Action preference for progress events generated by this cmdlet.

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
