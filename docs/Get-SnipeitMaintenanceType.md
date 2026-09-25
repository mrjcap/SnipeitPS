---
external help file: SnipeitPS-help.xml
Module Name: SnipeitPS
online version:
schema: 2.0.0
---

# Get-SnipeitMaintenanceType

## SYNOPSIS

Get maintenance types.

## SYNTAX

### List (Default)

```
Get-SnipeitMaintenanceType [-name <String>] [-search <String>] [-deleted <Boolean>] [-sort <String>]
 [-order <String>] [-limit <Int32>] [-offset <Int32>] [-all] [-Session <SnipeitSession>]
 [-ProgressAction <ActionPreference>] [<CommonParameters>]
```

### ById

```
Get-SnipeitMaintenanceType -id <Int32[]> [-Session <SnipeitSession>] [-ProgressAction <ActionPreference>]
 [<CommonParameters>]
```

## DESCRIPTION

GET /api/v1/maintenance-types lists types. GET /api/v1/maintenance-types/{id} retrieves each requested type. The default
List parameter set supports filters and pagination; ById cannot use list filters.

## EXAMPLES

### Example 1

```powershell
Get-SnipeitMaintenanceType -search Repair -all
```

Retrieves records using the current connection.

### Example 2

```powershell
Get-SnipeitMaintenanceType -id 2,3
```

Retrieves two maintenance types by ID.

## PARAMETERS

### -name

Exact maintenance type name filter.

```yaml
Type: String
Parameter Sets: List
Aliases:

Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -search

Search text matched within maintenance type names.

```yaml
Type: String
Parameter Sets: List
Aliases:

Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -deleted

Pass $true to request only deleted types. The default lists active types.

```yaml
Type: Boolean
Parameter Sets: List
Aliases:

Required: False
Position: Named
Default value: False
Accept pipeline input: False
Accept wildcard characters: False
```

### -sort

Sort field: id, name, created_at, or updated_at.

```yaml
Type: String
Parameter Sets: List
Aliases:

Required: False
Position: Named
Default value: name
Accept pipeline input: False
Accept wildcard characters: False
```

### -order

Sort direction: asc or desc.

```yaml
Type: String
Parameter Sets: List
Aliases:

Required: False
Position: Named
Default value: desc
Accept pipeline input: False
Accept wildcard characters: False
```

### -limit

Page size from 1 to 500. With -all, controls each page size.

```yaml
Type: Int32
Parameter Sets: List
Aliases:

Required: False
Position: Named
Default value: 50
Accept pipeline input: False
Accept wildcard characters: False
```

### -offset

Starting result offset from 0 to 2147483647.

```yaml
Type: Int32
Parameter Sets: List
Aliases:

Required: False
Position: Named
Default value: 0
Accept pipeline input: False
Accept wildcard characters: False
```

### -all

Fetch all matching pages rather than one page.

```yaml
Type: SwitchParameter
Parameter Sets: List
Aliases:

Required: False
Position: Named
Default value: False
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

### -id

One or more maintenance type IDs, each from 1 to 2147483647.

```yaml
Type: Int32[]
Parameter Sets: ById
Aliases:

Required: True
Position: Named
Default value: None
Accept pipeline input: True (ByPropertyName)
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

Accepts objects with matching properties: id.

## OUTPUTS

### System.Management.Automation.PSCustomObject

Returns the API response processed by the module dispatcher.

## NOTES

Requires a connection to a Snipe-IT server that supports this endpoint.

## RELATED LINKS

[Connect-SnipeitPS](Connect-SnipeitPS.md)
