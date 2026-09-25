---
external help file: SnipeitPS-help.xml
Module Name: SnipeitPS
online version:
schema: 2.0.0
---

# Invoke-SnipeitImport

## SYNOPSIS

Processes an uploaded import file in Snipe-IT.

## SYNTAX

```
Invoke-SnipeitImport [-import_id] <Int32> [-ImportType] <String> [-ColumnMappings <Hashtable>] [-Update]
 [-SendWelcome] [-RunBackup] [-Offset <Int32>] [-Limit <Int32>] [-MatchUsername] [-MatchEmail]
 [-MatchFirstnameLastname] [-MatchFlastname] [-MatchFirstname] [-Session <SnipeitSession>]
 [-ProgressAction <ActionPreference>] [-WhatIf] [-Confirm] [<CommonParameters>]
```

## DESCRIPTION

Processes an existing uploaded CSV/TSV import in Snipe-IT using the specified import type, column mappings, and optional
processing flags. Slicing via Offset and Limit is supported.

## EXAMPLES

### EXAMPLE 1

```powershell
Invoke-SnipeitImport -import_id 5 -ImportType 'asset' -ColumnMappings @{ 'Asset Tag' = 'asset_tag' }
```

## PARAMETERS

### -import_id

The ID of the uploaded import record to process.

```yaml
Type: Int32
Parameter Sets: (All)
Aliases: id

Required: True
Position: 1
Default value: 0
Accept pipeline input: True (ByPropertyName)
Accept wildcard characters: False
```

### -ImportType

The entity type to import. Supported values: asset, assetHistory, assetModel, accessory, consumable, component, license,
user, location, supplier, manufacturer, category.

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: True
Position: 2
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -ColumnMappings

Hashtable mapping CSV headers to importer field names. Mapping values cannot be null.

```yaml
Type: Hashtable
Parameter Sets: (All)
Aliases:

Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -Update

Switch to update existing matching records rather than failing on duplicate keys. Supports explicit false via
-Update:$false.

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

### -SendWelcome

Switch to send welcome email notifications to newly created users. Supports explicit false via -SendWelcome:$false.

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

### -RunBackup

Switch to trigger an Artisan backup before processing the import file. Supports explicit false via -RunBackup:$false.

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

### -Offset

Starting record offset within the CSV file for sliced/chunked processing.

```yaml
Type: Int32
Parameter Sets: (All)
Aliases:

Required: False
Position: Named
Default value: 0
Accept pipeline input: False
Accept wildcard characters: False
```

### -Limit

Maximum number of records to process in this slice.

```yaml
Type: Int32
Parameter Sets: (All)
Aliases:

Required: False
Position: Named
Default value: 0
Accept pipeline input: False
Accept wildcard characters: False
```

### -MatchUsername

History-matching switch: match asset history user by username. Valid only when ImportType is assetHistory.

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

### -MatchEmail

History-matching switch: match asset history user by email. Valid only when ImportType is assetHistory.

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

### -MatchFirstnameLastname

History-matching switch: match asset history user by firstname.lastname. Valid only when ImportType is assetHistory.

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

### -MatchFlastname

History-matching switch: match asset history user by flastname. Valid only when ImportType is assetHistory.

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

### -MatchFirstname

History-matching switch: match asset history user by firstname. Valid only when ImportType is assetHistory.

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
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -WhatIf

Shows what would happen if the cmdlet runs. The cmdlet is not run.

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

### SnipeitPS.ImportResult

## NOTES

## RELATED LINKS
