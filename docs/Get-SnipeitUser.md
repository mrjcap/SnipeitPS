---
external help file: SnipeitPS-help.xml
Module Name: SnipeitPS
online version:
schema: 2.0.0
---

# Get-SnipeitUser

## SYNOPSIS
Gets a list of Snipe-it Users

## SYNTAX

### Search (Default)
```
Get-SnipeitUser [-search <String>] [-company_id <Int32>] [-location_id <Int32>] [-group_id <Int32>]
 [-department_id <Int32>] [-username <String>] [-email <String>] [-order <String>] [-limit <Int32>]
 [-offset <Int32>] [-all] [-url <String>] [-apiKey <String>] [<CommonParameters>]
```

### Get with ID
```
Get-SnipeitUser [-id <String>] [-url <String>] [-apiKey <String>] [<CommonParameters>]
```

### Get users a specific accessory id has been checked out to
```
Get-SnipeitUser [-accessory_id <String>] [-all] [-url <String>] [-apiKey <String>] [<CommonParameters>]
```

## DESCRIPTION
Gets a list of Snipe-IT users or a specific user by ID.

## EXAMPLES

### EXAMPLE 1
```
Get-SnipeitUser -search SomeSurname
```

### EXAMPLE 2
```
Get-SnipeitUser -id 3
```

### EXAMPLE 3
```
Get-SnipeitUser -username someuser
```

### EXAMPLE 4
```
Get-SnipeitUser -email user@somedomain.com
```

### EXAMPLE 5
```
Get-SnipeitUser -accessory_id 3
Get users with accessory id 3 has been checked out to
```

## PARAMETERS

### -accessory_id
Get users a specific accessory id has been checked out to

```yaml
Type: String
Parameter Sets: Get users a specific accessory id has been checked out to
Aliases:

Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -all
Return all results, works with -offset and other parameters

```yaml
Type: SwitchParameter
Parameter Sets: Search, Get users a specific accessory id has been checked out to
Aliases:

Required: False
Position: Named
Default value: False
Accept pipeline input: False
Accept wildcard characters: False
```

### -apiKey
Deprecated parameter, please use Connect-SnipeitPS instead.
Users API Key for Snipeit.

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
Optionally restrict User results to this company_id field

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

### -department_id
Optionally restrict User results to this department_id field

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

### -email
Search string for email field

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

### -group_id
Optionally restrict User results to this group_id field

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

### -id
An id of specific User

```yaml
Type: String
Parameter Sets: Get with ID
Aliases:

Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -limit
Specify the number of results you wish to return.
Defaults to 50.
Defines batch size for -all

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

### -location_id
Optionally restrict User results to this location_id field

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

### -order
Sort order. Can be 'asc' or 'desc'.

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

### -search
A text string to search the User data

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

### -url
Deprecated parameter, please use Connect-SnipeitPS instead.
URL of Snipeit system.

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

### -username
Search string for username field

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

### CommonParameters
This cmdlet supports the common parameters: -Debug, -ErrorAction, -ErrorVariable, -InformationAction, -InformationVariable, -OutVariable, -OutBuffer, -PipelineVariable, -Verbose, -WarningAction, and -WarningVariable. For more information, see [about_CommonParameters](http://go.microsoft.com/fwlink/?LinkID=113216).

## INPUTS

## OUTPUTS

## NOTES

## RELATED LINKS
