---
external help file: SnipeitPS-help.xml
Module Name: SnipeitPS
online version:
schema: 2.0.0
---

# Get-SnipeitModelAsset

## SYNOPSIS

Lists assets belonging to an asset model.

## SYNTAX

```
Get-SnipeitModelAsset [-model_id] <Int32> [[-limit] <Int32>] [[-offset] <Int32>] [-all] [-PreserveResponse]
 [[-Session] <SnipeitSession>] [-ProgressAction <ActionPreference>] [<CommonParameters>]
```

## DESCRIPTION

Queries GET /api/v1/models/{model_id}/assets and returns asset rows. The former /models/assets route is broken and is
not used. Results respect server permissions and company scoping. Search and sorting are not supported by this endpoint.
Use PreserveResponse for the unmodified response envelope. It takes precedence over all.

## EXAMPLES

### EXAMPLE 1

```
Get-SnipeitModelAsset -model_id 7 -Session $session
```

## PARAMETERS

### -model_id

Positive model ID. Accepts pipeline properties named model_id or id.

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

### -limit

Records per page, from 1 to 500. Defaults to 50.

```yaml
Type: Int32
Parameter Sets: (All)
Aliases:

Required: False
Position: 2
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
Position: 3
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
Position: 4
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
