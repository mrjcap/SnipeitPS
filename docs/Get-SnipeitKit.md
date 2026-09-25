---
external help file: SnipeitPS-help.xml
Module Name: SnipeitPS
online version:
schema: 2.0.0
---

# Get-SnipeitKit

## SYNOPSIS

Gets predefined kits from Snipe-IT.

## SYNTAX

### List (Default)

```
Get-SnipeitKit [-search <String>] [-sort <String>] [-order <String>] [-offset <Int32>] [-limit <Int32>] [-All]
 [-Session <SnipeitSession>] [-ProgressAction <ActionPreference>] [<CommonParameters>]
```

### SingleKit

```
Get-SnipeitKit [-id] <Int32> [-Session <SnipeitSession>] [-ProgressAction <ActionPreference>]
 [<CommonParameters>]
```

## DESCRIPTION

Retrieves one or all predefined kits from Snipe-IT. Supports search filtering, sorting, and pagination.

## EXAMPLES

### EXAMPLE 1

```powershell
Get-SnipeitKit
```

### EXAMPLE 2

```powershell
Get-SnipeitKit -id 5
```

## PARAMETERS

### -id

The ID of a specific kit to retrieve.

```yaml
Type: Int32
Parameter Sets: SingleKit
Aliases:

Required: True
Position: 1
Default value: 0
Accept pipeline input: True (ByPropertyName)
Accept wildcard characters: False
```

### -search

Search string for filtering kits by name.

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

### -sort

Field to sort results by. Allowed values: id, name, created_at, updated_at, created_by.

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

### -order

Sort direction: asc or desc.

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

### -offset

Starting record offset for pagination.

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

### -limit

Maximum number of records to return per page.

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

### -All

Fetches all pages automatically using pagination.

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

Optional custom SnipeitSession instance.

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

### System.Management.Automation.PSCustomObject

## NOTES

## RELATED LINKS
