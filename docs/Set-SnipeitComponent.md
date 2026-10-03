---
external help file: SnipeitPS-help.xml
Module Name: SnipeitPS
online version:
schema: 2.0.0
---

# Set-SnipeitComponent

## SYNOPSIS

Updates component

## SYNTAX

```
Set-SnipeitComponent [-id] <Int32[]> [[-qty] <Int32>] [[-min_amt] <Int32>] [[-name] <String>]
 [[-company_id] <Int32>] [[-location_id] <Int32>] [[-order_number] <String>] [[-purchase_date] <DateTime>]
 [[-purchase_cost] <String>] [[-image] <String>] [-image_delete] [[-RequestType] <String>]
 [[-Session] <SnipeitSession>] [[-supplier_id] <Int32>] [[-manufacturer_id] <Int32>] [[-model_number] <String>]
 [[-serial] <String>] [[-notes] <String>] [[-category_id] <Int32>] [[-unit_cost] <Decimal>]
 [[-currency] <String>] [[-note] <String>] [[-default_supplier_id] <Int32>]
 [[-default_purchase_cost] <Decimal>] [[-requestable] <Boolean>] [-ProgressAction <ActionPreference>] [-WhatIf]
 [-Confirm] [<CommonParameters>]
```

## DESCRIPTION

Updates a component. qty is an absolute stock count, not a signed delta. Legacy purchase parameters remain on the wire
for older servers. On the current API, metadata-only updates do not edit purchase history. A positive qty difference can
create an acquisition using unit_cost and order metadata; purchase_cost is not consumed by that adjustment. Negative and
zero changes do not create acquisition lines. Use Invoke-SnipeitQuantityAdjustment for an explicit signed adjustment or
receipt.

## EXAMPLES

### EXAMPLE 1

```powershell
Set-SnipeitComponent -id 42 -qty 12
Sets count of component with ID 42 to 12
```

## PARAMETERS

### -id

ID number of component or array of IDs

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

### -qty

Quantity of the components you have

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

### -min_amt

Minimum Quantity of the components before alert is triggered

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

### -name

Component name

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

### -company_id

Company ID to associate with the component

```yaml
Type: Int32
Parameter Sets: (All)
Aliases:

Required: False
Position: 5
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -location_id

ID number of the location the component is assigned to

```yaml
Type: Int32
Parameter Sets: (All)
Aliases:

Required: False
Position: 6
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -order_number

Order number for the component

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: False
Position: 7
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -purchase_date

Date component was purchased

```yaml
Type: DateTime
Parameter Sets: (All)
Aliases:

Required: False
Position: 8
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -purchase_cost

Cost of item being purchased.

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: False
Position: 9
Default value: 0
Accept pipeline input: False
Accept wildcard characters: False
```

### -image

Image file name and path for item

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

### -image_delete

Remove current image

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

### -RequestType

HTTP request type to send to Snipe-IT system. Defaults to Patch. You could use Put if needed.

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: False
Position: 11
Default value: Patch
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

### -supplier_id

ID of the supplier. Pass $null to clear it.

```yaml
Type: Int32
Parameter Sets: (All)
Aliases:

Required: False
Position: 13
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -manufacturer_id

ID of the manufacturer. Pass $null to clear it.

```yaml
Type: Int32
Parameter Sets: (All)
Aliases:

Required: False
Position: 14
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -model_number

Manufacturer's model number.

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

### -serial

Serial number recorded for the component.

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: False
Position: 16
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -notes

Notes stored with the component.

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: False
Position: 17
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -category_id

ID of the category to assign to the component.

```yaml
Type: Int32
Parameter Sets: (All)
Aliases:

Required: False
Position: 18
Default value: 0
Accept pipeline input: False
Accept wildcard characters: False
```

### -unit_cost

Nonnegative per-unit cost for a positive qty difference on the current API. Accepts explicit null. This does not edit an
existing acquisition line.

```yaml
Type: Decimal
Parameter Sets: (All)
Aliases:

Required: False
Position: 19
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -currency

Currency for an acquisition caused by a positive qty difference.

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: False
Position: 20
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -note

Reason for a qty change. The server generates one when omitted. When the change creates an order, the Order model limits
its notes to 1000 characters.

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: False
Position: 21
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -default_supplier_id

Default supplier for future purchases, separate from historical acquisition suppliers. Accepts explicit null; an unbound
value is omitted.

```yaml
Type: Int32
Parameter Sets: (All)
Aliases:

Required: False
Position: 22
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -default_purchase_cost

Default cost for future purchases, separate from unit_cost and historical purchase_cost.
Accepts null or a value from 0 to 99999999999999999.99. Omit to leave the stored default unchanged.

```yaml
Type: Decimal
Parameter Sets: (All)
Aliases:

Required: False
Position: 23
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -requestable

Whether users can request this component. Accepts true, false, or null.
Omit to leave the stored value unchanged.

```yaml
Type: Boolean
Parameter Sets: (All)
Aliases:

Required: False
Position: 24
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

This cmdlet supports the common parameters: -Debug, -ErrorAction, -ErrorVariable,
-InformationAction, -InformationVariable, -OutVariable, -OutBuffer, -PipelineVariable, -Verbose,
-WarningAction, and -WarningVariable. For more information, see
[about_CommonParameters](http://go.microsoft.com/fwlink/?LinkID=113216).

## INPUTS

## OUTPUTS

### System.Management.Automation.PSCustomObject

## NOTES

## RELATED LINKS
