---
external help file: SnipeitPS-help.xml
Module Name: SnipeitPS
online version:
schema: 2.0.0
---

# Get-SnipeitManufacturer

## SYNOPSIS

Gets a list of Snipe-IT Manufacturers

## SYNTAX

### Search (Default)

```
Get-SnipeitManufacturer [-search <String>] [-name <String>] [-sort <String>] [-order <String>] [-limit <Int32>]
 [-offset <Int32>] [-all] [-manufacturer_url <String>] [-support_url <String>] [-warranty_lookup_url <String>]
 [-support_phone <String>] [-support_email <String>] [-deleted <Boolean>] [-status <String>] [-filter <String>]
 [-Session <SnipeitSession>] [-ProgressAction <ActionPreference>] [<CommonParameters>]
```

### Get with ID

```
Get-SnipeitManufacturer [-id <Int32>] [-Session <SnipeitSession>] [-ProgressAction <ActionPreference>]
 [<CommonParameters>]
```

## DESCRIPTION

Gets a list of Snipe-IT manufacturers or a specific manufacturer by ID.

## EXAMPLES

### EXAMPLE 1

```powershell
Get-SnipeitManufacturer -search HP
Search all manufacturers for string HP
```

### EXAMPLE 2

```powershell
Get-SnipeitManufacturer -id 3
Returns manufacturer with ID 3
```

## PARAMETERS

### -search

A text string to search the Manufacturers data

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

An ID of a specific Manufacturer

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

Optionally restrict Manufacturer results to this name field

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

### -manufacturer_url

Match the manufacturer's website URL.

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

### -support_url

Match the manufacturer's support website URL.

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

### -warranty_lookup_url

Match the manufacturer's warranty lookup URL.

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

### -support_phone

Match a support phone number.

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

### -support_email

Match a support email address.

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

### -deleted

Return soft-deleted manufacturers.

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

### -status

Use deleted to request soft-deleted manufacturers.

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
