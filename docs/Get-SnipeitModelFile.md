---
external help file: SnipeitPS-help.xml
Module Name: SnipeitPS
online version:
schema: 2.0.0
---

# Get-SnipeitModelFile

## SYNOPSIS
Gets files associated with a model

## SYNTAX

### Search (Default)
```
Get-SnipeitModelFile [-id] <Int32> [-url <String>] [-apiKey <String>] [<CommonParameters>]
```

### Get with file ID
```
Get-SnipeitModelFile [-id] <Int32> [-file_id <Int32>] [-url <String>] [-apiKey <String>]
 [<CommonParameters>]
```

## DESCRIPTION
Gets files associated with a specific Snipe-IT asset model.

## EXAMPLES

### EXAMPLE 1
```
Get-SnipeitModelFile -id 1
```

## PARAMETERS

### -apiKey
Deprecated parameter, please use Connect-SnipeitPS instead.
Users API Key for Snipeit.

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

### -file_id
An id of specific file

```yaml
Type: Int32
Parameter Sets: Get with file ID
Aliases:

Required: False
Position: Named
Default value: 0
Accept pipeline input: False
Accept wildcard characters: False
```

### -id
An id of specific Model

```yaml
Type: Int32
Parameter Sets: (All)
Aliases:

Required: True
Position: Named
Default value: 0
Accept pipeline input: False
Accept wildcard characters: False
```

### -url
Deprecated parameter, please use Connect-SnipeitPS instead.
URL of Snipeit system.

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

### CommonParameters
This cmdlet supports the common parameters: -Debug, -ErrorAction, -ErrorVariable, -InformationAction, -InformationVariable, -OutVariable, -OutBuffer, -PipelineVariable, -Verbose, -WarningAction, and -WarningVariable. For more information, see [about_CommonParameters](http://go.microsoft.com/fwlink/?LinkID=113216).

## INPUTS

## OUTPUTS

## NOTES

## RELATED LINKS
