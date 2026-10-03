---
external help file: SnipeitPS-help.xml
Module Name: SnipeitPS
online version:
schema: 2.0.0
---

# Get-SnipeitRequestableItem

## SYNOPSIS

Lists requestable models, accessories, consumables, components, or licenses.

## SYNTAX

```
Get-SnipeitRequestableItem [-Type] <String> [[-search] <String>] [[-sort] <String>] [[-order] <String>]
 [[-limit] <Int32>] [[-offset] <Int32>] [-all] [-PreserveResponse] [[-Session] <SnipeitSession>]
 [-ProgressAction <ActionPreference>] [<CommonParameters>]
```

## DESCRIPTION

Queries GET /api/v1/account/requestable/models, /accessories, /consumables, /components, or /licenses. Results respect
server permissions and company scoping. Rows expose model_id, accessory_id, consumable_id, component_id, or license_id
instead of id so model and accessory rows cannot bind as asset requests. Consumable, component, and license rows can
pipe to account request commands. This server has no model or accessory account request mutation route. Use
Get-SnipeitRequestableAsset for hardware. Use PreserveResponse for the unmodified response envelope. It takes precedence
over all.

## EXAMPLES

### EXAMPLE 1

```
Get-SnipeitRequestableItem -Type Consumable -Session $session
```

## PARAMETERS

### -Type

Resource type to list. Model, Accessory, Consumable, Component, or License.

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

### -search

Server-side search text.

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

### -sort

Sort column. Defaults to name. Also accepts created_at. Only models support remaining.

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: False
Position: 3
Default value: Name
Accept pipeline input: False
Accept wildcard characters: False
```

### -order

Sort direction. Defaults to desc.

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: False
Position: 4
Default value: Desc
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
Position: 5
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
Position: 6
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
Position: 7
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
