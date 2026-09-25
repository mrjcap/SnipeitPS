---
external help file: SnipeitPS-help.xml
Module Name: SnipeitPS
online version:
schema: 2.0.0
---

# Get-SnipeitDepreciationReport

## SYNOPSIS

Gets the depreciation report for deprecable assets from Snipe-IT.

## SYNTAX

```
Get-SnipeitDepreciationReport [[-search] <String>] [-filter <String>] [-asset_status <String>]
 [-status_type <String>] [-status_id <Int32>] [-asset_tag <String>] [-serial <String>] [-requestable <Boolean>]
 [-model_id <Int32[]>] [-category_id <Int32>] [-location_id <Int32>] [-rtd_location_id <Int32>]
 [-supplier_id <Int32>] [-asset_eol_date <DateTime>] [-assigned_to <Int32>] [-assigned_type <String>]
 [-company_id <Int32>] [-expand_company_hierarchy <Boolean>] [-manufacturer_id <Int32>]
 [-depreciation_id <Int32>] [-byod <Boolean>] [-order_number <String>] [-components <Boolean>]
 [-customfields <Hashtable>] [[-sort] <String>] [[-order] <String>] [[-offset] <Int32>] [[-limit] <Int32>]
 [-all] [[-Session] <SnipeitSession>] [-ProgressAction <ActionPreference>] [<CommonParameters>]
```

## DESCRIPTION

Retrieves depreciation report data for assets from Snipe-IT, including purchase cost, current depreciated value, monthly
depreciation amount, and difference. Requires the 'reports.view' permission on Snipe-IT.

## EXAMPLES

### EXAMPLE 1

```
Get-SnipeitDepreciationReport
```

### EXAMPLE 2

```
Get-SnipeitDepreciationReport -search "MacBook" -All
```

## PARAMETERS

### -search

Search string to filter report results.

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

### -filter

Advanced asset search filter. The server gives this precedence over search.

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

### -asset_status

Asset status classification, such as Archived or Deleted. status is an alias.

```yaml
Type: String
Parameter Sets: (All)
Aliases: status

Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -status_type

Preferred asset status classification; takes precedence over asset_status.

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

### -status_id

Restrict results to this status label ID.

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

### -asset_tag

Exact asset tag to match.

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

### -serial

Exact serial number to match.

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

### -requestable

True restricts results to requestable assets. False does not filter out requestable assets.

```yaml
Type: Boolean
Parameter Sets: (All)
Aliases:

Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -model_id

One or more model IDs to match.

```yaml
Type: Int32[]
Parameter Sets: (All)
Aliases:

Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -category_id

Restrict results to this category ID.

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

### -location_id

Restrict results to this current location ID.

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

### -rtd_location_id

Restrict results to this default return location ID.

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

### -supplier_id

Restrict results to this supplier ID.

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

### -asset_eol_date

Exact end-of-life date, serialized as yyyy-MM-dd.

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

### -assigned_to

Assignment target ID. Supply together with assigned_type.

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

### -assigned_type

Assignment model class, such as App\Models\User. Supply together with assigned_to.

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

### -company_id

Restrict results to this company ID.

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

### -expand_company_hierarchy

Include reachable companies when filtering by company_id.

```yaml
Type: Boolean
Parameter Sets: (All)
Aliases:

Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -manufacturer_id

Restrict results to this manufacturer ID.

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

### -depreciation_id

Restrict results to this depreciation definition ID.

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

### -byod

Filter personally owned versus organization-owned assets.

```yaml
Type: Boolean
Parameter Sets: (All)
Aliases:

Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -order_number

Exact order number to match.

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

### -components

Request component loading in the shared asset handler. The depreciation transformer omits component details.

```yaml
Type: Boolean
Parameter Sets: (All)
Aliases:

Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -customfields

Exact-match custom-field filters, keyed by internal columns such as _snipeit_room_12. Other query keys are rejected. Use
typed parameters for built-in filters.

```yaml
Type: Hashtable
Parameter Sets: (All)
Aliases:

Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -sort

Specifies the column by which report results are sorted.

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

### -order

Specifies the sort order (asc or desc).

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: False
Position: 3
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -offset

Number of records to skip for pagination.

```yaml
Type: Int32
Parameter Sets: (All)
Aliases:

Required: False
Position: 4
Default value: 0
Accept pipeline input: False
Accept wildcard characters: False
```

### -limit

Maximum number of records to return per page.

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

### -all

When specified, streams all records across pages using dispatcher-managed pagination.

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
Position: 6
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

### SnipeitPS.DepreciationReportEntry

## NOTES

## RELATED LINKS
