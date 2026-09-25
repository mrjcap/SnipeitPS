---
external help file: SnipeitPS-help.xml
Module Name: SnipeitPS
online version:
schema: 2.0.0
---

# Get-SnipeitActivity

## SYNOPSIS

Gets and searches Snipe-IT Activity history

## SYNTAX

```
Get-SnipeitActivity [[-search] <String>] [[-target_type] <String>] [[-target_id] <Int32>]
 [[-item_type] <String>] [[-item_id] <Int32>] [[-action_type] <String>] [[-limit] <Int32>] [[-offset] <Int32>]
 [-all] [[-Session] <SnipeitSession>] [[-filter] <String>] [[-created_by] <Int32>] [[-action_source] <String>]
 [[-remote_ip] <String>] [-uploads] [[-sort] <String>] [[-order] <String>] [-ProgressAction <ActionPreference>]
 [<CommonParameters>]
```

## DESCRIPTION

Gets a list of Snipe-IT activity history

## EXAMPLES

### EXAMPLE 1

```powershell
Get-SnipeitActivity -search Keyboard
```

### EXAMPLE 2

```powershell
Get-SnipeitActivity -target_type Asset -target_id 1
```

## PARAMETERS

### -search

A text string to search the Activity history

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: False
Position: 1
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -target_type

Type of target. One of the following:
'Accessory','Asset','AssetMaintenance','AssetModel','Category','Company','Component','Consumable','CustomField','Depreciable','Depreciation','Group','Licence','LicenseSeat','Location','Manufacturer','Statuslabel','Supplier','User'

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

### -target_id

Needed if target_type is specified

```yaml
Type: Int32
Parameter Sets: (All)
Aliases:

Required: False
Position: 3
Default value: 0
Accept pipeline input: False
Accept wildcard characters: False
```

### -item_type

Type of item. One of the following:
'Accessory','Asset','AssetMaintenance','AssetModel','Category','Company','Component','Consumable','CustomField','Depreciable','Depreciation','Group','Licence','LicenseSeat','Location','Manufacturer','Statuslabel','Supplier','User'

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

### -item_id

Needed if item_type is specified

```yaml
Type: Int32
Parameter Sets: (All)
Aliases:

Required: False
Position: 5
Default value: 0
Accept pipeline input: False
Accept wildcard characters: False
```

### -action_type

Type of action. One of the following: "add seats", "checkin from", "checkout", "update", "create", "delete", "restore",
"upload", "accepted", "declined", "requested"

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: False
Position: 6
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -limit

Specify the number of results to return

```yaml
Type: Int32
Parameter Sets: (All)
Aliases:

Required: False
Position: 7
Default value: 50
Accept pipeline input: False
Accept wildcard characters: False
```

### -offset

Result offset to use

```yaml
Type: Int32
Parameter Sets: (All)
Aliases:

Required: False
Position: 8
Default value: 0
Accept pipeline input: False
Accept wildcard characters: False
```

### -all

Return all results, works with -offset and other parameters

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
Position: 9
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -filter

Advanced search expression applied instead of search when supplied.

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: False
Position: 10
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -created_by

Restrict activity to this actor user ID.

```yaml
Type: Int32
Parameter Sets: (All)
Aliases:

Required: False
Position: 11
Default value: 0
Accept pipeline input: False
Accept wildcard characters: False
```

### -action_source

Restrict activity to this source, such as api.

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: False
Position: 12
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -remote_ip

Restrict activity to this remote IP address.

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: False
Position: 13
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -uploads

Return only activity records with uploaded files. Omitted or false leaves this filter disabled.

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

### -sort

Server activity column used for sorting.

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: False
Position: 14
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -order

Sort direction, asc or desc.

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: False
Position: 15
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
