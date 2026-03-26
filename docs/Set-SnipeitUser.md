---
external help file: SnipeitPS-help.xml
Module Name: SnipeitPS
online version:
schema: 2.0.0
---

# Set-SnipeitUser

## SYNOPSIS
Updates a user on Snipe-IT system

## SYNTAX

```
Set-SnipeitUser [-id] <Int32[]> [[-first_name] <String>] [[-last_name] <String>] [[-username] <String>]
 [[-jobtitle] <String>] [[-email] <String>] [[-phone] <String>] [[-password] <String>] [[-company_id] <Int32>]
 [[-location_id] <Int32>] [[-department_id] <Int32>] [[-manager_id] <Int32>] [[-groups] <Int32[]>]
 [[-employee_num] <String>] [[-activated] <Boolean>] [[-notes] <String>] [[-ldap_import] <Boolean>]
 [[-image] <String>] [-image_delete] [[-RequestType] <String>] [[-url] <String>] [[-apiKey] <String>]
 [-WhatIf] [-Confirm] [<CommonParameters>]
```

## DESCRIPTION
Updates a user on Snipe-IT system

## EXAMPLES

### EXAMPLE 1
```
Set-SnipeitUser -id 3 -first_name It -last_name Snipe -username snipeit -activated $false -company_id 1 -location_id 1 -department_id 1
Updates user with ID 3
```

## PARAMETERS

### -activated
Can user log in to Snipe-IT?

```yaml
Type: Boolean
Parameter Sets: (All)
Aliases:

Required: False
Position: 15
Default value: False
Accept pipeline input: False
Accept wildcard characters: False
```

### -apiKey
Deprecated parameter, please use Connect-SnipeitPS instead.
User's API Key for Snipe-IT.

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

### -company_id
ID number of company the user belongs to

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

### -department_id
ID number of department

```yaml
Type: Int32
Parameter Sets: (All)
Aliases:

Required: False
Position: 11
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -email
Email address

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: False
Position: 6
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -employee_num
Employee number

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

### -first_name
User's first name

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

### -groups
ID numbers of groups

```yaml
Type: Int32[]
Parameter Sets: (All)
Aliases:

Required: False
Position: 13
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -id
ID number of Snipe-IT user or array of IDs

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

### -image
Image file name and path for item

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: False
Position: 18
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

### -jobtitle
User's job title

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: False
Position: 5
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -last_name
User's last name

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: False
Position: 3
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -ldap_import
Mark user as imported from LDAP

```yaml
Type: Boolean
Parameter Sets: (All)
Aliases:

Required: False
Position: 17
Default value: False
Accept pipeline input: False
Accept wildcard characters: False
```

### -location_id
ID number of location

```yaml
Type: Int32
Parameter Sets: (All)
Aliases:

Required: False
Position: 10
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -manager_id
ID number of manager

```yaml
Type: Int32
Parameter Sets: (All)
Aliases:

Required: False
Position: 12
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -notes
User Notes

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

### -password
Password for user

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: False
Position: 8
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -phone
Phone number

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

### -RequestType
HTTP request type to send to Snipe-IT system.
Defaults to Patch. You could use Put if needed.

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: False
Position: 19
Default value: Patch
Accept pipeline input: False
Accept wildcard characters: False
```

### -url
Deprecated parameter, please use Connect-SnipeitPS instead.
URL of Snipe-IT system.

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

### -username
Username for user

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

### -WhatIf
Shows what would happen if the cmdlet runs.
The cmdlet is not run.

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

### CommonParameters
This cmdlet supports the common parameters: -Debug, -ErrorAction, -ErrorVariable, -InformationAction, -InformationVariable, -OutVariable, -OutBuffer, -PipelineVariable, -Verbose, -WarningAction, and -WarningVariable. For more information, see [about_CommonParameters](http://go.microsoft.com/fwlink/?LinkID=113216).

## INPUTS

## OUTPUTS

## NOTES

## RELATED LINKS
