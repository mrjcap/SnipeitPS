---
external help file: SnipeitPS-help.xml
Module Name: SnipeitPS
online version:
schema: 2.0.0
---

# Get-SnipeitAssetDue

## SYNOPSIS

Gets assets due or overdue for audit or check-in.

## SYNTAX

```
Get-SnipeitAssetDue [-Action] <String> [-Status] <String> [-search <String>] [-filter <String>]
 [-asset_status <String>] [-status_type <String>] [-status_id <Int32>] [-asset_tag <String>] [-serial <String>]
 [-requestable <Boolean>] [-model_id <Int32[]>] [-category_id <Int32>] [-location_id <Int32>]
 [-rtd_location_id <Int32>] [-supplier_id <Int32>] [-asset_eol_date <DateTime>] [-assigned_to <Int32>]
 [-assigned_type <String>] [-company_id <Int32>] [-expand_company_hierarchy <Boolean>]
 [-manufacturer_id <Int32>] [-depreciation_id <Int32>] [-byod <Boolean>] [-order_number <String>]
 [-components <Boolean>] [-customfields <Hashtable>] [-order <String>] [-sort <String>] [-limit <Int32>]
 [-offset <Int32>] [-All] [-preserveResponse] [-Session <SnipeitSession>] [-past_eol <Boolean>]
 [-ProgressAction <ActionPreference>] [<CommonParameters>]
```

## DESCRIPTION

Queries the Snipe-IT hardware API for assets matching upcoming status criteria: audit or checkin action, and due,
overdue, or due-or-overdue status. Calls GET /api/v1/hardware/{action}/{upcoming_status}.

## EXAMPLES

### EXAMPLE 1

```
Get-SnipeitAssetDue -Action Audit -Status Due
```

### EXAMPLE 2

```
Get-SnipeitAssetDue -Action Checkin -Status Overdue -All
```

## PARAMETERS

### -Action

The upcoming action to query: Audit or Checkin.

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

### -Status

The status filter: Due, Overdue, or DueOrOverdue.

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: True
Position: 2
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -search

Search query string.

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

Asset status classification, such as Archived or Deleted. Separate from the required due Status selector.

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

Include component relationships in returned assets.

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

### -order

Sort order direction: asc or desc.

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

### -sort

Field to sort results by.

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

### -limit

Specify the number of results to return per page. Defaults to 50.

```yaml
Type: Int32
Parameter Sets: (All)
Aliases:

Required: False
Position: Named
Default value: 50
Accept pipeline input: False
Accept wildcard characters: False
```

### -offset

Result offset for pagination.

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

### -All

When set, automatically streams all pages of results.

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

### -preserveResponse

When set, returns the original response envelope instead of unwrapping asset records.

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
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -past_eol

True restricts results to assets past their end-of-life date. False leaves this restriction off.

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

This cmdlet supports the common parameters: -Debug, -ErrorAction, -ErrorVariable,
-InformationAction, -InformationVariable, -OutVariable, -OutBuffer, -PipelineVariable, -Verbose,
-WarningAction, and -WarningVariable. For more information, see
[about_CommonParameters](http://go.microsoft.com/fwlink/?LinkID=113216).

## INPUTS

## OUTPUTS

### SnipeitPS.Asset

## NOTES

## RELATED LINKS
