---
external help file: SnipeitPS-help.xml
Module Name: SnipeitPS
online version:
schema: 2.0.0
---

# New-SnipeitAudit

## SYNOPSIS

Add a new Audit to Snipe-IT asset system (supports single and bulk audits)

## SYNTAX

```powershell
New-SnipeitAudit [[-tag] <String>] [[-id] <Int32[]>] [[-location_id] <Int32>] [[-next_audit_date] <DateTime>]
 [[-note] <String>] [[-image] <String>] [[-url] <String>] [[-apiKey] <String>] [-WhatIf] [-Confirm]
 [<CommonParameters>]
```

## DESCRIPTION

Add a new Audit to Snipe-IT asset system. Supports single asset tag/ID and bulk audits via array of IDs.

## EXAMPLES

### EXAMPLE 1

```powershell
New-SnipeitAudit -tag 1 -location_id 1
```

### EXAMPLE 2

```powershell
New-SnipeitAudit -id 42, 43 -note "Annual audit" -next_audit_date (Get-Date).AddMonths(6)
```

## PARAMETERS

### -apiKey

Deprecated parameter, please use Connect-SnipeitPS instead.
User's API Key for Snipe-IT.

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: False
Position: 5
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -location_id

ID of the location you want to associate with the audit

```yaml
Type: Int32
Parameter Sets: (All)
Aliases:

Required: False
Position: 2
Default value: 0
Accept pipeline input: False
Accept wildcard characters: False
```

### -next_audit_date

Due date for the asset's next audit

```yaml
Type: DateTime
Parameter Sets: (All)
Aliases:

Required: False
Position: 3
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -tag

The asset tag of the asset you wish to audit

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

### -url

Deprecated parameter, please use Connect-SnipeitPS instead.
URL of Snipe-IT system.

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: False
Position: 4
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

### CommonParameters

This cmdlet supports the common parameters: -Debug, -ErrorAction, -ErrorVariable, -InformationAction,
-InformationVariable, -OutVariable, -OutBuffer, -PipelineVariable, -Verbose, -WarningAction, and -WarningVariable. For
more information, see [about_CommonParameters](http://go.microsoft.com/fwlink/?LinkID=113216).

## INPUTS

## OUTPUTS

## NOTES

## RELATED LINKS
