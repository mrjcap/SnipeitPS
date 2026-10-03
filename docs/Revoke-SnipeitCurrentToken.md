---
external help file: SnipeitPS-help.xml
Module Name: SnipeitPS
online version:
schema: 2.0.0
---

# Revoke-SnipeitCurrentToken

## SYNOPSIS

Revokes the Passport access token authenticating this request.

## SYNTAX

```
Revoke-SnipeitCurrentToken [[-Session] <SnipeitSession>] [-ProgressAction <ActionPreference>] [-WhatIf]
 [-Confirm] [<CommonParameters>]
```

## DESCRIPTION

Posts an empty body to /api/v1/logout with explicit high-impact confirmation. The server revokes the current access
token and its associated refresh tokens. Success is HTTP 204 with no output. An authentication flow without a Passport
token can return an empty HTTP 401 error. This does not revoke an OIDC provider session, disconnect the module, or
revoke any other user's tokens. Revocation is never performed automatically by disconnecting a local session.

## EXAMPLES

### EXAMPLE 1

```
Revoke-SnipeitCurrentToken -WhatIf
```

## PARAMETERS

### -Session

Optional custom SnipeitSession instance whose bearer token should be revoked.

```yaml
Type: SnipeitSession
Parameter Sets: (All)
Aliases:

Required: False
Position: 1
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
