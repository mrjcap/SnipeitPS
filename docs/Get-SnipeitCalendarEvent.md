---
external help file: SnipeitPS-help.xml
Module Name: SnipeitPS
online version:
schema: 2.0.0
---

# Get-SnipeitCalendarEvent

## SYNOPSIS

Lists permission-scoped calendar events.

## SYNTAX

```
Get-SnipeitCalendarEvent [[-start] <String>] [[-end] <String>] [[-event_type] <String[]>] [[-limit] <Int32>]
 [-PreserveResponse] [[-Session] <SnipeitSession>] [-ProgressAction <ActionPreference>] [<CommonParameters>]
```

## DESCRIPTION

Queries GET /api/v1/calendar/events. The server uses a half-open start/end range and defaults to three months before and
after today. There is no offset or all option. PreserveResponse retains events, total, and truncated. The total is a
coarse permission-filtered count; per-row access checks may reduce returned events.

## EXAMPLES

### EXAMPLE 1

```
Get-SnipeitCalendarEvent -event_type asset.audit_due -PreserveResponse
```

## PARAMETERS

### -start

Inclusive range start as an ISO-8601 string. Omit to use the server default.

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: False
Position: 1
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -end

Exclusive range end as an ISO-8601 string. Omit to use the server default.

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

### -event_type

Event type strings. Sends a comma-separated filter; omission selects all types.

```yaml
Type: String[]
Parameter Sets: (All)
Aliases:

Required: False
Position: 3
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -limit

Maximum events, from 1 to 500. Defaults to 500.

```yaml
Type: Int32
Parameter Sets: (All)
Aliases:

Required: False
Position: 4
Default value: 500
Accept pipeline input: False
Accept wildcard characters: False
```

### -PreserveResponse

Returns the complete events/total/truncated envelope instead of event rows.

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
Position: 5
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
