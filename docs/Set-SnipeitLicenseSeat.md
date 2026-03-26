---
external help file: SnipeitPS-help.xml
Module Name: SnipeitPS
online version:
schema: 2.0.0
---

# Set-SnipeitLicenseSeat

## SYNOPSIS
Set license seat or checkout license seat

## SYNTAX

```
Set-SnipeitLicenseSeat [-id] <Int32[]> [-seat_id] <Int32> [[-assigned_to] <Int32>] [[-asset_id] <Int32>]
 [[-note] <String>] [[-RequestType] <String>] [[-url] <String>] [[-apiKey] <String>] [-WhatIf] [-Confirm]
 [<CommonParameters>]
```

## DESCRIPTION
Checkout specific license seat to user, asset or both

## EXAMPLES

### EXAMPLE 1
```
Set-SnipeitLicenseSeat -ID 1 -seat_id 1 -assigned_id 3
Checkout license to user ID 3
```

### EXAMPLE 2
```
Set-SnipeitLicenseSeat -ID 1 -seat_id 1 -asset_id 3
Checkout license to asset ID 3
```

### EXAMPLE 3
```
Set-SnipeitLicenseSeat -ID 1 -seat_id 1 -asset_id $null -assigned_id $null
Checkin license seat ID 1 of license ID 1
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
Position: 8
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -asset_id
ID of target asset

```yaml
Type: Int32
Parameter Sets: (All)
Aliases:

Required: False
Position: 4
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -assigned_to
ID of target user

```yaml
Type: Int32
Parameter Sets: (All)
Aliases: assigned_id

Required: False
Position: 3
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -id
Unique ID for license to checkout or array of IDs

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
Position: 5
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
Position: 6
Default value: Patch
Accept pipeline input: False
Accept wildcard characters: False
```

### -seat_id
ID of the license seat

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

### -url
Deprecated parameter, please use Connect-SnipeitPS instead.
URL of Snipe-IT system.

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
