---
external help file: SnipeitPS-help.xml
Module Name: SnipeitPS
online version:
schema: 2.0.0
---

# Reset-SnipeitLicenseOwner

## SYNOPSIS

Check in a license seat.

## SYNTAX

```
Reset-SnipeitLicenseOwner [-id] <Int32[]> [-seat_id] <Int32> [[-notes] <String>] [[-Session] <SnipeitSession>]
 [-ProgressAction <ActionPreference>] [-WhatIf] [-Confirm] [<CommonParameters>]
```

## DESCRIPTION

POST /api/v1/licenses/{id}/checkin checks in the specified seat for each license ID. A positive seat_id is required.
This command does not automatically select a seat or check in all seats.

## EXAMPLES

### Example 1

```powershell
Reset-SnipeitLicenseOwner -id 10 -seat_id 100 -notes 'Returned' -WhatIf
```

Previews the operation without changing server data.

## PARAMETERS

### -id

One or more license IDs, each from 1 to 2147483647.

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

### -seat_id

Required license seat ID from 1 to 2147483647. Selects the specific seat to check in.

```yaml
Type: Int32
Parameter Sets: (All)
Aliases:

Required: True
Position: 2
Default value: 0
Accept pipeline input: True (ByPropertyName)
Accept wildcard characters: False
```

### -notes

Optional checkout or checkin notes. Allows null; sent only when explicitly bound.

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

### -Session

Optional SnipeitSession instance. If omitted or null, uses the current module connection.

```yaml
Type: SnipeitSession
Parameter Sets: (All)
Aliases:

Required: False
Position: 4
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -WhatIf

Shows the intended operation without sending the modifying request.

```yaml
Type: SwitchParameter
Parameter Sets: (All)
Aliases: wi

Required: False
Position: Named
Default value: False
Accept pipeline input: False
Accept wildcard characters: False
```

### -Confirm

Prompts for confirmation before sending the modifying request.

```yaml
Type: SwitchParameter
Parameter Sets: (All)
Aliases: cf

Required: False
Position: Named
Default value: False
Accept pipeline input: False
Accept wildcard characters: False
```

### -ProgressAction

Controls how PowerShell displays progress records. Available in PowerShell 7.4 and later.

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

Requires a connection to a Snipe-IT server that supports this endpoint. Supports -WhatIf and -Confirm. Confirmation
impact is Medium.

## RELATED LINKS

[Connect-SnipeitPS](Connect-SnipeitPS.md)
