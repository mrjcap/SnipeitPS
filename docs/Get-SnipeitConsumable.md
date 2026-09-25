---
external help file: SnipeitPS-help.xml
Module Name: SnipeitPS
online version:
schema: 2.0.0
---

# Get-SnipeitConsumable

## SYNOPSIS

Gets a list of Snipe-IT consumables

## SYNTAX

### Search (Default)

```
Get-SnipeitConsumable [-search <String>] [-name <String>] [-category_id <Int32>] [-company_id <Int32>]
 [-manufacturer_id <Int32>] [-location_id <Int32>] [-order <String>] [-sort <String>] [-expand]
 [-limit <Int32>] [-offset <Int32>] [-all] [-supplier_id <Int32>] [-model_number <String>]
 [-order_number <String>] [-notes <String>] [-expand_company_hierarchy <Boolean>] [-filter <String>]
 [-Session <SnipeitSession>] [-ProgressAction <ActionPreference>] [<CommonParameters>]
```

### Get with ID

```
Get-SnipeitConsumable [-id <Int32[]>] [-Session <SnipeitSession>] [-ProgressAction <ActionPreference>]
 [<CommonParameters>]
```

## DESCRIPTION

Gets a list of Snipe-IT consumables or a specific consumable by ID.

## EXAMPLES

### EXAMPLE 1

```powershell
Get-SnipeitConsumable -all
Returns all consumables
```

### EXAMPLE 2

```powershell
Get-SnipeitConsumable -search paper
Returns search results containing "paper"
```

### EXAMPLE 3

```powershell
Get-SnipeitConsumable -id 1
Returns specific consumable
```

## PARAMETERS

### -search

A text string to search the consumables

```yaml
Type: String
Parameter Sets: Search
Aliases:

Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -id

An ID of a specific consumable

```yaml
Type: Int32[]
Parameter Sets: Get with ID
Aliases:

Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -name

Optionally restrict consumable results to this name field

```yaml
Type: String
Parameter Sets: Search
Aliases:

Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -category_id

ID number of category

```yaml
Type: Int32
Parameter Sets: Search
Aliases:

Required: False
Position: Named
Default value: 0
Accept pipeline input: False
Accept wildcard characters: False
```

### -company_id

ID number of company

```yaml
Type: Int32
Parameter Sets: Search
Aliases:

Required: False
Position: Named
Default value: 0
Accept pipeline input: False
Accept wildcard characters: False
```

### -manufacturer_id

ID number of manufacturer

```yaml
Type: Int32
Parameter Sets: Search
Aliases:

Required: False
Position: Named
Default value: 0
Accept pipeline input: False
Accept wildcard characters: False
```

### -location_id

Location ID number of the consumable to filter by

```yaml
Type: Int32
Parameter Sets: Search
Aliases:

Required: False
Position: Named
Default value: 0
Accept pipeline input: False
Accept wildcard characters: False
```

### -order

Specify the order (asc or desc) you wish to order by on your sort column

```yaml
Type: String
Parameter Sets: Search
Aliases:

Required: False
Position: Named
Default value: Desc
Accept pipeline input: False
Accept wildcard characters: False
```

### -sort

Sort results by column

```yaml
Type: String
Parameter Sets: Search
Aliases:

Required: False
Position: Named
Default value: Created_at
Accept pipeline input: False
Accept wildcard characters: False
```

### -expand

Whether to include detailed information on categories, etc (true) or just the text name (false)

```yaml
Type: SwitchParameter
Parameter Sets: Search
Aliases:

Required: False
Position: Named
Default value: False
Accept pipeline input: False
Accept wildcard characters: False
```

### -limit

Specify the number of results you wish to return. Defaults to 50. Defines batch size for -all

```yaml
Type: Int32
Parameter Sets: Search
Aliases:

Required: False
Position: Named
Default value: 50
Accept pipeline input: False
Accept wildcard characters: False
```

### -offset

Offset to use

```yaml
Type: Int32
Parameter Sets: Search
Aliases:

Required: False
Position: Named
Default value: 0
Accept pipeline input: False
Accept wildcard characters: False
```

### -all

Return all results

```yaml
Type: SwitchParameter
Parameter Sets: Search
Aliases:

Required: False
Position: Named
Default value: False
Accept pipeline input: False
Accept wildcard characters: False
```

### -supplier_id

Restrict results to a supplier ID.

```yaml
Type: Int32
Parameter Sets: Search
Aliases:

Required: False
Position: Named
Default value: 0
Accept pipeline input: False
Accept wildcard characters: False
```

### -model_number

Match the manufacturer's model number.

```yaml
Type: String
Parameter Sets: Search
Aliases:

Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -order_number

Match a purchase order number.

```yaml
Type: String
Parameter Sets: Search
Aliases:

Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -notes

Match stored notes.

```yaml
Type: String
Parameter Sets: Search
Aliases:

Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -expand_company_hierarchy

Include descendant companies when filtering by company_id.

```yaml
Type: Boolean
Parameter Sets: Search
Aliases:

Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -filter

Server text-search filter, taking precedence over search.

```yaml
Type: String
Parameter Sets: Search
Aliases:

Required: False
Position: Named
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
