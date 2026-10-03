---
external help file: SnipeitPS-help.xml
Module Name: SnipeitPS
online version:
schema: 2.0.0
---

# Get-SnipeitLicense

## SYNOPSIS

Gets a list of Snipe-IT Licenses

## SYNTAX

### Search (Default)

```
Get-SnipeitLicense [-search <String>] [-name <String>] [-company_id <Int32>] [-product_key <String>]
 [-order_number <String>] [-purchase_order <String>] [-license_name <String>] [-license_email <MailAddress>]
 [-manufacturer_id <Int32>] [-supplier_id <Int32>] [-depreciation_id <Int32>] [-category_id <Int32>]
 [-order <String>] [-sort <String>] [-limit <Int32>] [-offset <Int32>] [-all] [-created_by <Int32>]
 [-maintained <Boolean>] [-expires <Boolean>] [-deleted <Boolean>] [-status <String>]
 [-expand_company_hierarchy <Boolean>] [-filter <String>] [-Session <SnipeitSession>]
 [-ProgressAction <ActionPreference>] [<CommonParameters>]
```

### Get with ID

```
Get-SnipeitLicense [-id <Int32>] [-Session <SnipeitSession>] [-ProgressAction <ActionPreference>]
 [<CommonParameters>]
```

### Get licenses checked out to user ID

```
Get-SnipeitLicense [-user_id <Int32>] [-all] [-Session <SnipeitSession>] [-NormalizeIdentity]
 [-ProgressAction <ActionPreference>] [<CommonParameters>]
```

### Get licenses checked out to asset ID

```
Get-SnipeitLicense [-asset_id <Int32>] [-all] [-Session <SnipeitSession>] [-ProgressAction <ActionPreference>]
 [<CommonParameters>]
```

## DESCRIPTION

Gets a list of Snipe-IT licenses or a specific license by ID.

## EXAMPLES

### EXAMPLE 1

```powershell
Get-SnipeitLicense -search SomeLicense
```

### EXAMPLE 2

```powershell
Get-SnipeitLicense -id 1
```

## PARAMETERS

### -search

A text string to search the Licenses data

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

An ID of a specific License

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

### -user_id

ID of a user to filter licenses checked out to

```yaml
Type: Int32
Parameter Sets: Get licenses checked out to user ID
Aliases: assigned_user

Required: False
Position: Named
Default value: 0
Accept pipeline input: True (ByPropertyName)
Accept wildcard characters: False
```

### -asset_id

ID of an asset to filter licenses checked out to

```yaml
Type: Int32
Parameter Sets: Get licenses checked out to asset ID
Aliases: hardware_id

Required: False
Position: Named
Default value: 0
Accept pipeline input: True (ByPropertyName)
Accept wildcard characters: False
```

### -name

Name of a specific license to search for

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

### -company_id

ID of a company to filter by

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

### -product_key

Product key to search for

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

Order number to search for

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

### -purchase_order

Purchase order to search for

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

### -license_name

Name of the license to search for

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

### -license_email

Email address associated with the license

```yaml
Type: MailAddress
Parameter Sets: Search
Aliases:

Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -manufacturer_id

ID of a manufacturer to filter by

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

### -supplier_id

ID of a supplier to filter by

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

### -depreciation_id

ID of a depreciation schedule to filter by

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

### -category_id

ID of a category to filter by

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

### -sort

Specify the column name you wish to sort by

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
Parameter Sets: Search, Get licenses checked out to user ID, Get licenses checked out to asset ID
Aliases:

Required: False
Position: Named
Default value: False
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

### -maintained

Filter by the license maintenance flag.

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

### -expires

Filter licenses with or without an expiration date.

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

### -deleted

Return soft-deleted licenses.

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

Server license classification, such as inactive or expiring.

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

### -NormalizeIdentity

For user assignments, replace id with the license inventory ID. Off by default.
Otherwise id keeps its original assignment meaning; license_id and seat_id
are added without replacing existing ID properties. Collection IDs are unchanged.

```yaml
Type: SwitchParameter
Parameter Sets: Get licenses checked out to user ID
Aliases:

Required: False
Position: Named
Default value: False
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
