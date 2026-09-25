---
external help file: SnipeitPS-help.xml
Module Name: SnipeitPS
online version:
schema: 2.0.0
---

# Set-SnipeitCustomField

## SYNOPSIS

Updates a Custom Field on Snipe-IT asset system

## SYNTAX

```
Set-SnipeitCustomField [-id] <Int32[]> [[-name] <String>] [[-help_text] <String>] [[-element] <String>]
 [[-format] <String>] [[-field_values] <String>] [[-field_encrypted] <Boolean>] [[-show_in_email] <Boolean>]
 [[-custom_format] <String>] [[-RequestType] <String>] [[-Session] <SnipeitSession>] [[-is_unique] <Boolean>]
 [[-display_in_user_view] <Boolean>] [[-auto_add_to_fieldsets] <Boolean>] [[-show_in_listview] <Boolean>]
 [[-display_checkout] <Boolean>] [[-display_checkin] <Boolean>] [[-display_audit] <Boolean>]
 [[-show_in_requestable_list] <Boolean>] [-ProgressAction <ActionPreference>] [-WhatIf] [-Confirm]
 [<CommonParameters>]
```

## DESCRIPTION

Updates a Custom Field on Snipe-IT asset system

## EXAMPLES

### EXAMPLE 1

```powershell
Set-SnipeitCustomField -id 1 -Name "AntivirusInstalled" -Format "BOOLEAN" -element text -HelpText "Is AntiVirus `
  installed on Asset"
```

## PARAMETERS

### -id

An ID of a specific resource to update

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

The field's name, which is also the form label

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

### -help_text

Any additional text you wish to display under the form field to make it clearer what the values should be.

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

### -element

Form field type that should be displayed.

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

### -format

How the field should be validated

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

### -field_values

In the case of list boxes, etc, this should be a list of the options available

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

### -field_encrypted

Whether the field should be encrypted. (This can cause issues if you change it after the field was created.)

```yaml
Type: Boolean
Parameter Sets: (All)
Aliases:

Required: False
Position: 7
Default value: False
Accept pipeline input: False
Accept wildcard characters: False
```

### -show_in_email

Whether or not to show the custom field in email notifications

```yaml
Type: Boolean
Parameter Sets: (All)
Aliases:

Required: False
Position: 8
Default value: False
Accept pipeline input: False
Accept wildcard characters: False
```

### -custom_format

Retained for compatibility. Custom regex updates are rejected because the supported API does not accept them. Omit
format and custom_format when updating other properties of an existing regex field.

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: False
Position: 9
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -RequestType

HTTP request type to send to Snipe-IT system. Defaults to Put. You could use Patch if needed.

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: False
Position: 10
Default value: Put
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
Position: 11
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -is_unique

Require unique values across assets using this field.

```yaml
Type: Boolean
Parameter Sets: (All)
Aliases:

Required: False
Position: 12
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -display_in_user_view

Show the field in the user's asset view.

```yaml
Type: Boolean
Parameter Sets: (All)
Aliases:

Required: False
Position: 13
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -auto_add_to_fieldsets

Automatically add the field to newly created fieldsets.

```yaml
Type: Boolean
Parameter Sets: (All)
Aliases:

Required: False
Position: 14
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -show_in_listview

Show the field in asset list views.

```yaml
Type: Boolean
Parameter Sets: (All)
Aliases:

Required: False
Position: 15
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -display_checkout

Show the field during checkout.

```yaml
Type: Boolean
Parameter Sets: (All)
Aliases:

Required: False
Position: 16
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -display_checkin

Show the field during checkin.

```yaml
Type: Boolean
Parameter Sets: (All)
Aliases:

Required: False
Position: 17
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -display_audit

Show the field during an audit.

```yaml
Type: Boolean
Parameter Sets: (All)
Aliases:

Required: False
Position: 18
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -show_in_requestable_list

Show the field in the requestable asset list.

```yaml
Type: Boolean
Parameter Sets: (All)
Aliases:

Required: False
Position: 19
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

This cmdlet supports the common parameters: -Debug, -ErrorAction, -ErrorVariable, -InformationAction,
-InformationVariable, -OutVariable, -OutBuffer, -PipelineVariable, -Verbose, -WarningAction, and -WarningVariable. For
more information, see [about_CommonParameters](http://go.microsoft.com/fwlink/?LinkID=113216).

## INPUTS

## OUTPUTS

### System.Management.Automation.PSCustomObject

## NOTES

## RELATED LINKS
