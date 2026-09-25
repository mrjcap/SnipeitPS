---
external help file: SnipeitPS-help.xml
Module Name: SnipeitPS
online version:
schema: 2.0.0
---

# Get-SnipeitAssetMaintenance

## SYNOPSIS

Lists Snipe-IT Asset Maintenances

## SYNTAX

### ByFilter (Default)

```
Get-SnipeitAssetMaintenance [[-search] <String>] [-filter <String>] [[-asset_id] <Int32>]
 [-supplier_id <Int32>] [-created_by <Int32>] [-url <String>] [-maintenance_type <String>]
 [-maintenance_type_id <Int32>] [-responsible_party_id <Int32>] [-checked_out_to_id <Int32>]
 [-checked_out_to_type <String>] [-completed <Boolean>] [-upcoming_status <String>] [[-sort] <String>]
 [[-order] <String>] [[-limit] <Int32>] [-format <String>] [-all] [[-offset] <Int32>]
 [[-Session] <SnipeitSession>] [-ProgressAction <ActionPreference>] [<CommonParameters>]
```

### ById

```
Get-SnipeitAssetMaintenance -id <Int32> [[-Session] <SnipeitSession>] [-ProgressAction <ActionPreference>]
 [<CommonParameters>]
```

## DESCRIPTION

Gets asset maintenance records from the Snipe-IT system.

## EXAMPLES

### EXAMPLE 1

```powershell
Get-SnipeitAssetMaintenance
```

### EXAMPLE 2

```powershell
Get-SnipeitAssetMaintenance -search "myMachine"
```

## PARAMETERS

### -id

Unique ID of the maintenance record to retrieve. Mutually exclusive with query filters.

```yaml
Type: Int32
Parameter Sets: ById
Aliases:

Required: True
Position: Named
Default value: 0
Accept pipeline input: True (ByPropertyName, ByValue)
Accept wildcard characters: False
```

### -search

Search string to query maintenance records.

```yaml
Type: String
Parameter Sets: ByFilter
Aliases:

Required: False
Position: 1
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -filter

Advanced search filter string. Takes precedence over search when both are provided.

```yaml
Type: String
Parameter Sets: ByFilter
Aliases:

Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -asset_id

Asset ID to filter maintenance records by.

```yaml
Type: Int32
Parameter Sets: ByFilter
Aliases:

Required: False
Position: 2
Default value: 0
Accept pipeline input: False
Accept wildcard characters: False
```

### -supplier_id

Supplier ID to filter maintenance records by.

```yaml
Type: Int32
Parameter Sets: ByFilter
Aliases:

Required: False
Position: Named
Default value: 0
Accept pipeline input: False
Accept wildcard characters: False
```

### -created_by

User ID of the creator to filter maintenance records by.

```yaml
Type: Int32
Parameter Sets: ByFilter
Aliases:

Required: False
Position: Named
Default value: 0
Accept pipeline input: False
Accept wildcard characters: False
```

### -url

URL string to filter maintenance records by.

```yaml
Type: String
Parameter Sets: ByFilter
Aliases:

Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -maintenance_type

Maintenance type string to filter by.

```yaml
Type: String
Parameter Sets: ByFilter
Aliases:

Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -maintenance_type_id

Maintenance type ID to filter by.

```yaml
Type: Int32
Parameter Sets: ByFilter
Aliases:

Required: False
Position: Named
Default value: 0
Accept pipeline input: False
Accept wildcard characters: False
```

### -responsible_party_id

User ID of the responsible party to filter by.

```yaml
Type: Int32
Parameter Sets: ByFilter
Aliases:

Required: False
Position: Named
Default value: 0
Accept pipeline input: False
Accept wildcard characters: False
```

### -checked_out_to_id

Polymorphic ID of the target the underlying asset was checked out to.

```yaml
Type: Int32
Parameter Sets: ByFilter
Aliases:

Required: False
Position: Named
Default value: 0
Accept pipeline input: False
Accept wildcard characters: False
```

### -checked_out_to_type

Fully qualified class name for polymorphic checkout target (e.g. App\Models\User).

```yaml
Type: String
Parameter Sets: ByFilter
Aliases:

Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -completed

Filter by completion state. Bound true queries completed records; bound false queries active records. Omitted returns
both.

```yaml
Type: Boolean
Parameter Sets: ByFilter
Aliases:

Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -upcoming_status

Upcoming status filter. Allowed values: due, overdue, due-or-overdue.

```yaml
Type: String
Parameter Sets: ByFilter
Aliases:

Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -sort

Specify the column name you wish to sort by. Defaults to created_at.

```yaml
Type: String
Parameter Sets: ByFilter
Aliases:

Required: False
Position: 3
Default value: Created_at
Accept pipeline input: False
Accept wildcard characters: False
```

### -order

Specify the order (asc or desc) you wish to order by. Defaults to desc.

```yaml
Type: String
Parameter Sets: ByFilter
Aliases:

Required: False
Position: 4
Default value: Desc
Accept pipeline input: False
Accept wildcard characters: False
```

### -limit

Specify the number of results to return per page. Defaults to 50.

```yaml
Type: Int32
Parameter Sets: ByFilter
Aliases:

Required: False
Position: 5
Default value: 50
Accept pipeline input: False
Accept wildcard characters: False
```

### -format

Set to flat to return the flattened maintenance representation.

```yaml
Type: String
Parameter Sets: ByFilter
Aliases:

Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -all

When specified, streams all results across pages using dispatcher-managed pagination.

```yaml
Type: SwitchParameter
Parameter Sets: ByFilter
Aliases:

Required: False
Position: Named
Default value: False
Accept pipeline input: False
Accept wildcard characters: False
```

### -offset

Offset to use for pagination.

```yaml
Type: Int32
Parameter Sets: ByFilter
Aliases:

Required: False
Position: 6
Default value: 0
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
Position: 7
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
