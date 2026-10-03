---
external help file: SnipeitPS-help.xml
Module Name: SnipeitPS
online version:
schema: 2.0.0
---

# Set-SnipeitLicenseOwner

## SYNOPSIS

Check out a license seat to a user or hardware asset.

## SYNTAX

### User (Default)

```
Set-SnipeitLicenseOwner -id <Int32[]> -assigned_to <Int32> [-seat_id <Int32>] [-notes <String>]
 [-Session <SnipeitSession>] [-reassign] [-ProgressAction <ActionPreference>] [-WhatIf] [-Confirm]
 [<CommonParameters>]
```

### Asset

```
Set-SnipeitLicenseOwner -id <Int32[]> -asset_id <Int32> [-seat_id <Int32>] [-notes <String>]
 [-Session <SnipeitSession>] [-reassign] [-ProgressAction <ActionPreference>] [-WhatIf] [-Confirm]
 [<CommonParameters>]
```

## DESCRIPTION

POST /api/v1/licenses/{id}/checkout checks out a seat for each license ID. The default User parameter set requires
assigned_to and sends target_type=user. Asset requires asset_id and sends target_type=asset. User and hardware asset
targets are mutually exclusive. Omit seat_id or pass $null to let the server choose a free license seat. Supply a
positive seat ID to select one explicitly.

## EXAMPLES

### Example 1

```powershell
Set-SnipeitLicenseOwner -id 10 -assigned_to 7 -WhatIf
```

Previews the operation without changing server data.

### Example 2

```powershell
Set-SnipeitLicenseOwner -id 10 -asset_id 42 -seat_id 100 -WhatIf
```

Previews checkout of a specific license seat to a hardware asset.

## PARAMETERS

### -id

One or more license IDs, each from 1 to 2147483647.

```yaml
Type: Int32[]
Parameter Sets: (All)
Aliases:

Required: True
Position: Named
Default value: None
Accept pipeline input: True (ByPropertyName)
Accept wildcard characters: False
```

### -assigned_to

User ID, mutually exclusive with asset_id. The server receives target_type=user.

```yaml
Type: Int32
Parameter Sets: User
Aliases:

Required: True
Position: Named
Default value: 0
Accept pipeline input: True (ByPropertyName)
Accept wildcard characters: False
```

### -asset_id

Hardware asset ID. The server receives target_type=asset.

```yaml
Type: Int32
Parameter Sets: Asset
Aliases:

Required: True
Position: Named
Default value: 0
Accept pipeline input: True (ByPropertyName)
Accept wildcard characters: False
```

### -seat_id

Optional seat ID. Omit or pass null to let the server choose a free seat.

```yaml
Type: Int32
Parameter Sets: (All)
Aliases:

Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -notes

Optional checkout or checkin notes. Allows null; sent only when explicitly bound.

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

### -Session

Optional SnipeitSession instance. If omitted or null, uses the current module connection.

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

### -reassign

Permits displacing an occupied seat when the license is reassignable. Sent only when explicitly bound. Explicit false is
sent as false. This is a checkout control, separate from the license's reassignable setting.

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
