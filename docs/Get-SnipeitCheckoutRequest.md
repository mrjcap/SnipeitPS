---
external help file: SnipeitPS-help.xml
Module Name: SnipeitPS
online version:
schema: 2.0.0
---

# Get-SnipeitCheckoutRequest

## SYNOPSIS

Lists pending checkout requests visible to an administrator.

## SYNTAX

```
Get-SnipeitCheckoutRequest [[-user_id] <Int32>] [[-requestable_type] <String>] [[-search] <String>]
 [[-sort] <String>] [[-order] <String>] [[-limit] <Int32>] [[-offset] <Int32>] [-all] [-PreserveResponse]
 [[-Session] <SnipeitSession>] [-ProgressAction <ActionPreference>] [<CommonParameters>]
```

## DESCRIPTION

Queries GET /api/v1/requests. Results respect server permissions and company scoping. Rows expose request_id instead of
id. Nested requestable IDs remain unchanged. This queue contains pending requests only. There is no admin approval,
fulfillment, or cancellation API in this server revision. Use PreserveResponse for the unmodified response envelope. It
takes precedence over all.

## EXAMPLES

### EXAMPLE 1

```
Get-SnipeitCheckoutRequest -Session $session
```

## PARAMETERS

### -user_id

Positive requesting user ID to filter by.

```yaml
Type: Int32
Parameter Sets: (All)
Aliases:

Required: False
Position: 1
Default value: 0
Accept pipeline input: False
Accept wildcard characters: False
```

### -requestable_type

Resource class to filter by. Sends the corresponding App\Models class name.

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

### -search

Server-side search text.

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: False
Position: 3
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -sort

Sort column. Defaults to requested_at. Also accepts start_date, end_date, quantity, or requestable.remaining.

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: False
Position: 4
Default value: Requested_at
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
Position: 5
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
Position: 6
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
Position: 7
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
Position: 8
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
