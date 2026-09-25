---
external help file: SnipeitPS-help.xml
Module Name: SnipeitPS
online version:
schema: 2.0.0
---

# Get-SnipeitFile

## SYNOPSIS

Gets files associated with an entity in Snipe-IT.

## SYNTAX

### List (Default)

```
Get-SnipeitFile [-EntityType] <String> [-id] <Int32> [-search <String>] [-sort <String>] [-order <String>]
 [-offset <Int32>] [-limit <Int32>] [-All] [-Session <SnipeitSession>] [-ProgressAction <ActionPreference>]
 [<CommonParameters>]
```

### SingleFile

```
Get-SnipeitFile [-EntityType] <String> [-id] <Int32> [-file_id] <Int32> [-AsByteArray] [-inline]
 [-Session <SnipeitSession>] [-ProgressAction <ActionPreference>] [<CommonParameters>]
```

## DESCRIPTION

Retrieves file attachments or file metadata for an allowlisted Snipe-IT entity type. Supported entity types include
accessories, audits, assets, components, consumables, hardware, licenses, locations, maintenances, models, suppliers,
users, companies, and departments.

## EXAMPLES

### EXAMPLE 1

```powershell
Get-SnipeitFile -EntityType 'hardware' -id 100
```

### EXAMPLE 2

```powershell
Get-SnipeitFile -EntityType 'models' -id 5 -file_id 12 -AsByteArray
```

## PARAMETERS

### -EntityType

The type of object to retrieve files for. Supported types: accessories, audits, assets, components, consumables,
hardware, licenses, locations, maintenances, models, suppliers, users, companies, departments.

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

### -id

The ID of the parent entity.

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

### -file_id

The ID of a specific file to retrieve.

```yaml
Type: Int32
Parameter Sets: SingleFile
Aliases:

Required: True
Position: 3
Default value: 0
Accept pipeline input: False
Accept wildcard characters: False
```

### -search

Search query for filtering by filename or note.

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

Sort column for results. Allowed values: id, filename, action_type, action_date, note, created_at.

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

Fetch all pages automatically using pagination.

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

### -AsByteArray

Opt-in switch for single file retrieval returning binary content wrapped in SnipeitPS.FileContent.

```yaml
Type: SwitchParameter
Parameter Sets: SingleFile
Aliases:

Required: False
Position: Named
Default value: False
Accept pipeline input: False
Accept wildcard characters: False
```

### -inline

Requests inline disposition for a single file. The server only honors this for safe file extensions. Use AsByteArray to
preserve binary content; this switch changes disposition, not the response format.

```yaml
Type: SwitchParameter
Parameter Sets: SingleFile
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

### SnipeitPS.FileContent

## NOTES

## RELATED LINKS
