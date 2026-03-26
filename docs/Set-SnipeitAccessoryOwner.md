---
external help file: SnipeitPS-help.xml
Module Name: SnipeitPS
online version:
schema: 2.0.0
---

# Set-SnipeitAccessoryOwner

## SYNOPSIS
Checkout accessory

## SYNTAX

```
Set-SnipeitAccessoryOwner [-id] <Int32[]> [-assigned_to] <Int32> [[-checkout_to_type] <String>]
 [[-note] <String>] [[-url] <String>] [[-apiKey] <String>] [-WhatIf] [-Confirm] [<CommonParameters>]
```

## DESCRIPTION
Checkout accessory to user

## EXAMPLES

### EXAMPLE 1
```
Set-SnipeitAccessoryOwner -id 1 -assigned_to 1 -checkout_to_type user -note "testing check out to user"
```

## PARAMETERS

### -apiKey
Deprecated parameter, please use Connect-SnipeitPS instead.
User's API Key for Snipe-IT.

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

### -assigned_to
ID of target user, asset, or location

```yaml
Type: Int32
Parameter Sets: (All)
Aliases:

Required: True
Position: 2
Default value: 0
Accept pipeline input: False
Accept wildcard characters: False
```

### -checkout_to_type
Checkout accessory to one of the following types: user, asset, or location

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: False
Position: 3
Default value: user
Accept pipeline input: False
Accept wildcard characters: False
```

### -id
Unique ID for accessory or array of IDs to checkout

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

### -note
Notes about checkout

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

### -url
Deprecated parameter, please use Connect-SnipeitPS instead.
URL of Snipe-IT system.

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
