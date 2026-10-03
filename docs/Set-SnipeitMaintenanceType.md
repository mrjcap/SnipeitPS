---
external help file: SnipeitPS-help.xml
Module Name: SnipeitPS
online version:
schema: 2.0.0
---

# Set-SnipeitMaintenanceType

## SYNOPSIS

Renames a maintenance type without clearing its existing color.

## SYNTAX

```
Set-SnipeitMaintenanceType [-id] <Int32[]> [-name] <String> [[-Session] <SnipeitSession>]
 [[-tag_color] <Object>] [-ProgressAction <ActionPreference>] [-WhatIf] [-Confirm] [<CommonParameters>]
```

## DESCRIPTION

Patches /api/v1/maintenance-types/{id}. Omission of tag_color triggers a GET inside ShouldProcess to preserve each
type's color. The lookup must return exactly one matching ID or the command stops before PATCH. Explicit tag_color
avoids the GET. WhatIf performs neither request. The read and write are not atomic; preserving color also requires view
permission.

## EXAMPLES

### Example 1

```powershell
Set-SnipeitMaintenanceType -id 2 -name 'Annual inspection' -WhatIf
```

Previews the operation without changing server data.

## PARAMETERS

### -id

Positive maintenance-type ID or array of IDs.

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

New maintenance-type name.

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: True
Position: 2
Default value: None
Accept pipeline input: True (ByPropertyName)
Accept wildcard characters: False
```

### -Session

Optional custom SnipeitSession instance.

```yaml
Type: SnipeitSession
Parameter Sets: (All)
Aliases:

Required: False
Position: 3
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -tag_color

Explicit color, empty string or null. When omitted, reads the current color before PATCH. The lookup requires view
permission. Missing color on a historical response keeps the historical name-only request. GET/PATCH is not an atomic
operation.

```yaml
Type: Object
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

### System.Management.Automation.PSObject

Accepts objects with matching properties: id, name.

## OUTPUTS

### System.Management.Automation.PSCustomObject

Returns the API response processed by the module dispatcher.

## NOTES

Requires a connection to a Snipe-IT server that supports this endpoint. Supports -WhatIf and -Confirm. Confirmation
impact is Medium.

## RELATED LINKS

[Connect-SnipeitPS](Connect-SnipeitPS.md)
