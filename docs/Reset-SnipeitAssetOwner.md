---
external help file: SnipeitPS-help.xml
Module Name: SnipeitPS
online version:
schema: 2.0.0
---

# Reset-SnipeitAssetOwner

## SYNOPSIS

Check in an asset.

## SYNTAX

### ById (Default)

```
Reset-SnipeitAssetOwner [-id] <Int32[]> [-name <String>] [-clear_name] [-checkin_at <DateTime>]
 [[-status_id] <Int32>] [[-location_id] <Int32>] [-update_default_location] [[-note] <String>]
 [[-Session] <SnipeitSession>] [-ProgressAction <ActionPreference>] [-WhatIf] [-Confirm] [<CommonParameters>]
```

### ByTagPath

```
Reset-SnipeitAssetOwner [-tag] <String[]> [-name <String>] [-clear_name] [-checkin_at <DateTime>]
 [[-status_id] <Int32>] [[-location_id] <Int32>] [-update_default_location] [[-note] <String>]
 [[-Session] <SnipeitSession>] [-ProgressAction <ActionPreference>] [-WhatIf] [-Confirm] [<CommonParameters>]
```

### ByQuickScan

```
Reset-SnipeitAssetOwner [-checkin_key] <String> [-checkin_by_field <String>] [-name <String>] [-clear_name]
 [-checkin_at <DateTime>] [[-status_id] <Int32>] [[-location_id] <Int32>] [-update_default_location]
 [[-note] <String>] [[-Session] <SnipeitSession>] [-ProgressAction <ActionPreference>] [-WhatIf] [-Confirm]
 [<CommonParameters>]
```

## DESCRIPTION

Checks in an asset from its current user, location, or asset. Supports checkin by asset ID via `POST
/api/v1/hardware/{id}/checkin`, checkin by asset tag in route via `POST /api/v1/hardware/bytag/{tag}/checkin`, and
quickscan checkin by tag/serial in request body via `POST /api/v1/hardware/checkinbytag`.

## EXAMPLES

### EXAMPLE 1

```powershell
Reset-SnipeitAssetOwner -id 44
```

### EXAMPLE 2

```powershell
Reset-SnipeitAssetOwner -tag 'AST-0044' -note 'Returned by employee'
```

### EXAMPLE 3

```powershell
Reset-SnipeitAssetOwner -checkin_key 'SRL-998811' -checkin_by_field 'serial'
```

## PARAMETERS

### -id

Unique ID(s) of the asset(s) to check in.

```yaml
Type: Int32[]
Parameter Sets: ById
Aliases:

Required: True
Position: 1
Default value: None
Accept pipeline input: True (ByPropertyName, ByValue)
Accept wildcard characters: False
```

### -tag

Unique asset tag(s) of the asset(s) to check in.

```yaml
Type: String[]
Parameter Sets: ByTagPath
Aliases: asset_tag

Required: True
Position: 1
Default value: None
Accept pipeline input: True (ByPropertyName)
Accept wildcard characters: False
```

### -checkin_key

Lookup key value (asset tag or serial number) for body-based checkin.

```yaml
Type: String
Parameter Sets: ByQuickScan
Aliases:

Required: True
Position: 1
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -checkin_by_field

Field to look up by for body-based checkin: asset_tag or serial. Defaults to asset_tag.

```yaml
Type: String
Parameter Sets: ByQuickScan
Aliases:

Required: False
Position: Named
Default value: asset_tag
Accept pipeline input: False
Accept wildcard characters: False
```

### -name

Optional new asset name upon checkin.

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

### -clear_name

When set, clears the asset's custom name upon checkin.

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

### -checkin_at

Optional date to record as the checkin timestamp.

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

### -status_id

Change asset status to this status ID upon checkin.

```yaml
Type: Int32
Parameter Sets: (All)
Aliases:

Required: False
Position: 2
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -location_id

Location ID to change asset location to upon checkin.

```yaml
Type: Int32
Parameter Sets: (All)
Aliases:

Required: False
Position: 3
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -update_default_location

When set, updates the asset's default (RTD) location to the specified location_id.

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

### -note

Notes about the checkin.

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: False
Position: 4
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
Position: 5
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
