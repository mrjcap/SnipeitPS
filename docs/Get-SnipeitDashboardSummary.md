---
external help file: SnipeitPS-help.xml
Module Name: SnipeitPS
online version:
schema: 2.0.0
---

# Get-SnipeitDashboardSummary

## SYNOPSIS

Lists permission-scoped dashboard category, company, or location summaries.

## SYNTAX

```
Get-SnipeitDashboardSummary [-By] <String> [[-sort] <String>] [[-order] <String>] [[-limit] <Int32>]
 [[-offset] <Int32>] [-all] [-PreserveResponse] [[-Session] <SnipeitSession>]
 [-ProgressAction <ActionPreference>] [<CommonParameters>]
```

## DESCRIPTION

Queries GET /api/v1/dashboard/categories, /companies, or /locations. Counts depend on view permissions. Missing counts
remain absent, not zero. For locations, assets_count and assigned_assets_count are separate counts. Rows have dashboard
summary types, not full resource types. Use PreserveResponse for the unmodified response envelope. It takes precedence
over all.

## EXAMPLES

### EXAMPLE 1

```
Get-SnipeitDashboardSummary -By Location -Session $session
```

## PARAMETERS

### -By

Selects Category, Company, or Location summaries.

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: True
Position: 1
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -sort

Column to sort by. Defaults to name. The server falls back to name for invalid or unauthorized count columns. Categories
also support category_type.

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: False
Position: 2
Default value: Name
Accept pipeline input: False
Accept wildcard characters: False
```

### -order

Sort direction. Defaults to desc.

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: False
Position: 3
Default value: Desc
Accept pipeline input: False
Accept wildcard characters: False
```

### -limit

Records per page, from 1 to 50. Defaults to 25.

```yaml
Type: Int32
Parameter Sets: (All)
Aliases:

Required: False
Position: 4
Default value: 25
Accept pipeline input: False
Accept wildcard characters: False
```

### -offset

Nonnegative row offset.

```yaml
Type: Int32
Parameter Sets: (All)
Aliases:

Required: False
Position: 5
Default value: 0
Accept pipeline input: False
Accept wildcard characters: False
```

### -all

Streams rows across pages until the total is reached or an empty page is returned.

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

### -PreserveResponse

Returns the first complete response without row normalization.

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

### -Session

Optional custom SnipeitSession instance.

```yaml
Type: SnipeitSession
Parameter Sets: (All)
Aliases:

Required: False
Position: 6
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -ProgressAction

Controls progress display in PowerShell 7.4 and later.

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

## RELATED LINKS
