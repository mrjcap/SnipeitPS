---
external help file: SnipeitPS-help.xml
Module Name: SnipeitPS
online version:
schema: 2.0.0
---

# Get-SnipeitCategory

## SYNOPSIS

Gets a list of Snipe-IT Categories

## SYNTAX

### Search (Default)

```
Get-SnipeitCategory [-search <String>] [-name <String>] [-sort <String>] [-order <String>] [-limit <Int32>]
 [-offset <Int32>] [-all] [-category_type <String>] [-archived <Boolean>] [-use_default_eula <Boolean>]
 [-require_acceptance <Boolean>] [-checkin_email <Boolean>] [-created_by <Int32>] [-created_at <String>]
 [-updated_at <String>] [-filter <String>] [-Session <SnipeitSession>] [-ProgressAction <ActionPreference>]
 [<CommonParameters>]
```

### Get with ID

```
Get-SnipeitCategory [-id <Int32>] [-Session <SnipeitSession>] [-ProgressAction <ActionPreference>]
 [<CommonParameters>]
```

## DESCRIPTION

Gets a list of Snipe-IT categories or a specific category by ID.

## EXAMPLES

### EXAMPLE 1

```powershell
Get-SnipeitCategory -id 1
```

### EXAMPLE 2

```powershell
Get-SnipeitCategory -search "Laptop"
```

## PARAMETERS

### -search

A text string to search the Categories data

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

An ID of a specific Category

```yaml
Type: Int32
Parameter Sets: Get with ID
Aliases:

Required: False
Position: Named
Default value: 0
Accept pipeline input: True (ByPropertyName)
Accept wildcard characters: False
```

### -name

Optionally restrict Category results to this Category name.

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

### -sort

Column to sort on

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

### -order

Sort order for results, one of 'asc' or 'desc'. Defaults to 'desc'

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

Return all results, works with -offset and other parameters

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

### -category_type

Restrict results to an asset, accessory, component, consumable, or license category.

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

### -archived

Include archived categories as supported by the server.

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

### -use_default_eula

Filter categories by use of the default EULA.

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

### -require_acceptance

Filter categories by their acceptance requirement.

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

### -checkin_email

Filter categories by their checkin email setting.

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

### -created_by

Restrict results to the creating user's ID.

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

### -created_at

Exact creation timestamp in server format.

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

### -updated_at

Exact last-update timestamp in server format.

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
