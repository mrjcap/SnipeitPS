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

### ById (Default)

```
New-SnipeitAudit [-id <Int32[]>] [-location_id <Int32>] [-next_audit_date <DateTime>] [-note <String>]
 [-image <String>] [-update_location <Boolean>] [-clear_name <Boolean>] [-customfields <Hashtable>]
 [-Session <SnipeitSession>] [-ProgressAction <ActionPreference>] [-WhatIf] [-Confirm] [<CommonParameters>]
```

### ByTag

```
New-SnipeitAudit [-asset_tag <String>] [-location_id <Int32>] [-next_audit_date <DateTime>] [-note <String>]
 [-image <String>] [-update_location <Boolean>] [-clear_name <Boolean>] [-customfields <Hashtable>]
 [-Session <SnipeitSession>] [-ProgressAction <ActionPreference>] [-WhatIf] [-Confirm] [<CommonParameters>]
```

### BySerial

```
New-SnipeitAudit [-serial <String>] [-location_id <Int32>] [-next_audit_date <DateTime>] [-note <String>]
 [-image <String>] [-update_location <Boolean>] [-clear_name <Boolean>] [-customfields <Hashtable>]
 [-Session <SnipeitSession>] [-ProgressAction <ActionPreference>] [-WhatIf] [-Confirm] [<CommonParameters>]
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

### -id

The unique ID or array of IDs of the asset(s) to audit (bulk audit)

```yaml
Type: Int32[]
Parameter Sets: ById
Aliases:

Required: False
Position: Named
Default value: None
Accept pipeline input: True (ByPropertyName)
Accept wildcard characters: False
```

### -asset_tag

The asset tag of the asset you wish to audit

```yaml
Type: String
Parameter Sets: ByTag
Aliases: tag

Required: False
Position: Named
Default value: None
Accept pipeline input: True (ByPropertyName)
Accept wildcard characters: False
```

### -serial

Raw serial number of the asset to audit. The server must have unique_serial enabled.

```yaml
Type: String
Parameter Sets: BySerial
Aliases:

Required: False
Position: Named
Default value: None
Accept pipeline input: True (ByPropertyName)
Accept wildcard characters: False
```

### -location_id

ID of the location you want to associate with the audit

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

### -next_audit_date

Due date for the asset's next audit

```yaml
Type: DateTime
Parameter Sets: (All)
Aliases:

Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -note

Optional note for the audit log entry

```yaml
Type: String
Parameter Sets: (All)
Aliases: notes

Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -image

Path to an image file to upload and attach to the audit log

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

### -update_location

Write location_id to the asset rather than only recording the audit location. Allows an explicit null location.

```yaml
Type: Boolean
Parameter Sets: (All)
Aliases:

Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -clear_name

Clear the asset name when true.

```yaml
Type: Boolean
Parameter Sets: (All)
Aliases:

Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -customfields

Custom audit values keyed by internal _snipeit_ database column names. Only fields enabled for audit are persisted.
Encrypted custom fields additionally require the server's encrypted-field permission.

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

Action preference for progress events generated by this cmdlet.

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
