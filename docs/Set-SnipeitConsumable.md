---
external help file: SnipeitPS-help.xml
Module Name: SnipeitPS
online version:
schema: 2.0.0
---

# Set-SnipeitConsumable

## SYNOPSIS

Update a Consumable on Snipe-IT asset system

## SYNTAX

```
Set-SnipeitConsumable [-id] <Int32[]> [[-name] <String>] [[-qty] <Int32>] [[-category_id] <Int32>]
 [[-min_amt] <Int32>] [[-company_id] <Int32>] [[-order_number] <String>] [[-manufacturer_id] <Int32>]
 [[-location_id] <Int32>] [[-requestable] <Boolean>] [[-purchase_date] <DateTime>] [[-purchase_cost] <String>]
 [[-model_number] <String>] [[-item_no] <String>] [[-image] <String>] [-image_delete] [[-RequestType] <String>]
 [[-Session] <SnipeitSession>] [[-supplier_id] <Int32>] [[-notes] <String>] [[-unit_cost] <Decimal>]
 [[-currency] <String>] [[-note] <String>] [[-default_supplier_id] <Int32>]
 [[-default_purchase_cost] <Decimal>] [-ProgressAction <ActionPreference>] [-WhatIf] [-Confirm]
 [<CommonParameters>]
```

## DESCRIPTION

Updates a consumable. qty is an absolute stock count, not a signed delta. Legacy purchase parameters remain on the wire
for older servers. On the current API, metadata-only updates do not edit purchase history. A positive qty difference can
create an acquisition using unit_cost and order metadata; purchase_cost is not consumed by that adjustment. Negative and
zero changes do not create acquisition lines. Use Invoke-SnipeitQuantityAdjustment for an explicit signed adjustment or
receipt.

## EXAMPLES

### EXAMPLE 1

```powershell
Set-SnipeitConsumable -id 1 -name "Ink pack" -qty 20 -category_id 3 -min_amt 5
Update consumable with stock count 20, alert when stock is 5 or lower
```

## PARAMETERS

### -id

Optional ID number of the Consumable

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

### -name

Optional Name of the Consumable

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

### -qty

Optional Quantity of consumable

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

### -category_id

Required Category ID of the Consumable, this can be obtained using Get-SnipeitCategory

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

### -min_amt

Optional minimum quantity of consumable

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

### -company_id

Optional Company ID

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

Optional Order number

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

### -manufacturer_id

Manufacturer ID number of the consumable

```yaml
Type: Int32
Parameter Sets: (All)
Aliases:

Required: False
Position: 8
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -location_id

Location ID number of the consumable

```yaml
Type: Int32
Parameter Sets: (All)
Aliases:

Required: False
Position: 9
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -requestable

Is consumable requestable?

```yaml
Type: Boolean
Parameter Sets: (All)
Aliases:

Required: False
Position: 10
Default value: False
Accept pipeline input: False
Accept wildcard characters: False
```

### -purchase_date

Optional Purchase date of the consumable

```yaml
Type: DateTime
Parameter Sets: (All)
Aliases:

Required: False
Position: 11
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -purchase_cost

Optional Purchase cost of the consumable

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

### -model_number

Model number of the consumable

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

### -item_no

Item number for the consumable

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

### -image

Image file name and path for item

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
Position: 16
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
Position: 17
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
Position: 18
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -notes

Notes stored with the consumable.

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: False
Position: 19
Default value: None
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
Position: 20
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
Position: 21
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
Position: 22
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
Position: 23
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
