---
external help file: SnipeitPS-help.xml
Module Name: SnipeitPS
online version:
schema: 2.0.0
---

# Get-SnipeitUserConsumable

## SYNOPSIS

Lists consumable assignments for a user with inventory-safe IDs.

## SYNTAX

```
Get-SnipeitUserConsumable [-user_id] <Int32> [[-search] <String>] [[-sort] <String>] [[-order] <String>]
 [[-limit] <Int32>] [[-offset] <Int32>] [-all] [-PreserveResponse] [[-Session] <SnipeitSession>]
 [-ProgressAction <ActionPreference>] [<CommonParameters>]
```

## DESCRIPTION

Queries GET /api/v1/users/{user_id}/consumables. Results respect server permissions and company scoping. Normalized id
is the nested consumable inventory ID; checkout_id retains the assignment ID. Legacy rows without a nested consumable
remain unchanged. An invalid nested inventory ID raises SnipeitResourceIdentityError. Use PreserveResponse for the
unmodified response envelope. It takes precedence over all.

## EXAMPLES

### EXAMPLE 1

```
Get-SnipeitUserConsumable -user_id 7 -Session $session
```

## PARAMETERS

### -user_id

Positive user ID. Accepts pipeline properties named user_id or id.

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

### -search

Searches consumable names or assignment notes.

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: False
Position: 2
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -sort

Sorts by name or assignment created_at. Defaults to created_at.

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: False
Position: 3
Default value: Created_at
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
Position: 4
Default value: Desc
Accept pipeline input: False
Accept wildcard characters: False
```

### -limit

Records per page, from 1 to 500. Defaults to 50.

```yaml
Type: Int32
Parameter Sets: (All)
Aliases:

Required: False
Position: 5
Default value: 50
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
Position: 6
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
Position: 7
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
