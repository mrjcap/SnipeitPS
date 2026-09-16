---
external help file: SnipeitPS-help.xml
Module Name: SnipeitPS
online version:
schema: 2.0.0
---

# Set-SnipeitLicenseOwner

## SYNOPSIS

Check out a license seat.

## SYNTAX

### User (Default)

```
Set-SnipeitLicenseOwner -id <Int32[]> -assigned_to <Int32> [-seat_id <Nullable[Int32]>] [-notes <String>]
 [-Session <SnipeitSession>] [-WhatIf] [-Confirm] [<CommonParameters>]
```

### Asset

```
Set-SnipeitLicenseOwner -id <Int32[]> -asset_id <Int32> [-seat_id <Nullable[Int32]>] [-notes <String>]
 [-Session <SnipeitSession>] [-WhatIf] [-Confirm] [<CommonParameters>]
```

## DESCRIPTION

POST /api/v1/licenses/{id}/checkout checks out a seat for each license ID. The default User parameter set
requires assigned_to and sends target_type=user. Asset requires asset_id and sends target_type=asset. User and
hardware asset targets are mutually exclusive. Omit seat_id or pass $null to let the server choose a free
license seat. Supply a positive seat ID to select one explicitly.

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

User ID from 1 to 2147483647. Required in User; mutually exclusive with asset_id.

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

### -seat_id

Optional positive license seat ID. Omit or pass $null for server selection of a free seat.

```yaml
Type: Nullable[Int32]
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

### -asset_id

Hardware asset ID from 1 to 2147483647. Required in Asset; mutually exclusive with assigned_to.

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

### CommonParameters

Supports the PowerShell common parameters. See [about_CommonParameters](https://go.microsoft.com/fwlink/?LinkID=113216).

## INPUTS

### System.Management.Automation.PSObject

Accepts objects with matching properties: id, assigned_to, asset_id.

## OUTPUTS

### System.Management.Automation.PSCustomObject

Returns the API response processed by the module dispatcher.

## NOTES

Requires a connection to a Snipe-IT server that supports this endpoint. Supports -WhatIf and -Confirm.
Confirmation impact is Medium.

## RELATED LINKS

[Connect-SnipeitPS](Connect-SnipeitPS.md)
