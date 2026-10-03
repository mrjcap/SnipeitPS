---
external help file: SnipeitPS-help.xml
Module Name: SnipeitPS
online version:
schema: 2.0.0
---

# Get-SnipeitLowStockItem

## SYNOPSIS

Lists permission-scoped low-stock items using the server alert settings.

## SYNTAX

```
Get-SnipeitLowStockItem [[-search] <String>] [[-sort] <String>] [[-order] <String>] [[-limit] <Int32>]
 [[-offset] <Int32>] [-all] [-PreserveResponse] [[-Session] <SnipeitSession>]
 [-ProgressAction <ActionPreference>] [<CommonParameters>]
```

## DESCRIPTION

Queries GET /api/v1/low-stock. Results respect server permissions and company scoping. The server uses its configured
alert threshold and current checkouts to select low-stock rows. No threshold override is available. Row id is a
composite key such as consumable-5; item.id is the inventory ID. Do not use the row id as an inventory mutation ID.
Models and licenses cannot use quantity adjustment. Use PreserveResponse for the unmodified response envelope. It takes
precedence over all.

## EXAMPLES

### EXAMPLE 1

```
Get-SnipeitLowStockItem -Session $session
```

## PARAMETERS

### -search

Filters item names.

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

### -sort

Sort column. Defaults to remaining. Also accepts name, type, qty, min_amt, or percent.

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: False
Position: 2
Default value: Remaining
Accept pipeline input: False
Accept wildcard characters: False
```

### -order

Sort direction. Defaults to asc.

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: False
Position: 3
Default value: Asc
Accept pipeline input: False
Accept wildcard characters: False
```

### -limit

Records per page, from 1 to 500. Defaults to 50.

```yaml
Type: Int32
Parameter Sets: (All)
Aliases:

Required: False
Position: 4
Default value: 50
Accept pipeline input: False
Accept wildcard characters: False
```

### -offset

Nonnegative row offset.

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

Streams rows across pages until the total is reached or an empty page is returned.

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

### -PreserveResponse

Returns the first complete response without row normalization.

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

Controls progress display in PowerShell 7.4 and later.

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

### System.Management.Automation.PSObject

## NOTES

## RELATED LINKS
