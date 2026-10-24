---
external help file: SnipeitPS-help.xml
Module Name: SnipeitPS
online version:
schema: 2.0.0
---

# Restore-SnipeitComponent

## SYNOPSIS

Restores soft-deleted components or clears their archive flag.

## SYNTAX

```
Restore-SnipeitComponent [-id] <Int32[]> [[-Session] <SnipeitSession>] [-Unarchive]
 [-ProgressAction <ActionPreference>] [-WhatIf] [-Confirm] [<CommonParameters>]
```

## DESCRIPTION

By default, posts an empty JSON object to /api/v1/components/{id}/restore.
Restore requires delete permission.
Use Unarchive to post to
/api/v1/components/{id}/unarchive instead; this requires update permission.
Restoring a soft-deleted item does not clear its archive flag.
Unarchive does
not restore soft-deleted items.
Server errors remain on the error stream;
use ErrorAction Stop to terminate on an error.

## EXAMPLES

### EXAMPLE 1

```
Restore-SnipeitComponent -id 7 -WhatIf
```

### EXAMPLE 2

```
Restore-SnipeitComponent -id 7 -Unarchive -WhatIf
```

## PARAMETERS

### -id

Positive component inventory IDs.
Accepts pipeline properties named id or component_id.

```yaml
Type: Int32[]
Parameter Sets: (All)
Aliases: component_id

Required: True
Position: 1
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
Position: 2
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -Unarchive

Clear the archive flag instead of restoring a soft-deleted item.
Omit this switch or pass false to use restore.

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
-InformationVariable, -OutVariable, -OutBuffer, -PipelineVariable, -Verbose, -WarningAction, and -WarningVariable.
For more information, see [about_CommonParameters](http://go.microsoft.com/fwlink/?LinkID=113216).

## INPUTS

## OUTPUTS

### System.Management.Automation.PSObject

## NOTES

## RELATED LINKS
