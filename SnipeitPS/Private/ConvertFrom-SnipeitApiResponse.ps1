function ConvertFrom-SnipeitApiResponse {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $false)]
        [object]$Response,

        [Parameter(Mandatory = $false)]
        [ValidateSet('StandardEnvelope', 'RowsTotal', 'Select2', 'DirectArray', 'DirectObject', 'ScalarText', 'NoContent', 'ImportResult', 'RawData')]
        [string]$ResponseKind,

        [Parameter(Mandatory = $false)]
        [string]$ResultTypeName,

        [switch]$PreserveResponse
    )

    if ($null -eq $Response) {
        return $null
    }

    # Helper to check properties across hashtables and PSCustomObjects
    $hasProp = {
        param($obj, [string]$name)
        if ($null -eq $obj) { return $false }
        if ($obj -is [System.Collections.IDictionary]) { return $obj.Contains($name) }
        return $null -ne $obj.PSObject.Properties[$name]
    }

    $getProp = {
        param($obj, [string]$name)
        if ($null -eq $obj) { return $null }
        if ($obj -is [System.Collections.IDictionary]) { return $obj[$name] }
        return $obj.$name
    }

    $hasResults = & $hasProp $Response 'results'
    $hasStatus = & $hasProp $Response 'status'
    $hasMessages = & $hasProp $Response 'messages'
    $isBulkResponse = $hasResults -and $hasStatus -and $hasMessages -and ($ResponseKind -ne 'Select2')

    if ($PreserveResponse -or $isBulkResponse) {
        return $Response
    }

    $statusVal = & $getProp $Response 'status'
    $messagesVal = & $getProp $Response 'messages'

    # Error handling for envelopes
    if ($statusVal -eq 'error' -or $statusVal -eq 'import-errors') {
        $formattedParts = [System.Collections.Generic.List[string]]::new()
        if ($statusVal -eq 'import-errors') {
            $formattedParts.Add("Snipe-IT API returned import-errors.")
        }
        if ($messagesVal -is [System.Management.Automation.PSCustomObject] -or $messagesVal -is [System.Collections.IDictionary]) {
            $msgProps = if ($messagesVal -is [System.Collections.IDictionary]) {
                $messagesVal.GetEnumerator()
            } else {
                $messagesVal.PSObject.Properties
            }
            foreach ($prop in $msgProps) {
                $fieldName = if ($null -ne $prop.Key) { $prop.Key } elseif ($null -ne $prop.Name) { $prop.Name } else { "$prop" }
                $fieldErrors = $prop.Value
                if ($fieldErrors -is [System.Collections.IEnumerable] -and $fieldErrors -isnot [string]) {
                    foreach ($msg in $fieldErrors) {
                        $formattedParts.Add("Validation failed for '$fieldName': $msg")
                    }
                } else {
                    $formattedParts.Add("Validation failed for '$fieldName': $fieldErrors")
                }
            }
            $errMsg = $formattedParts -join [System.Environment]::NewLine
        } else {
            $errMsg = if ($messagesVal) { ($messagesVal | Out-String).Trim() } else { "Snipe-IT API returned error status: $statusVal." }
        }

        $targetPayload = if ($Response -is [System.Management.Automation.PSCustomObject]) {
            $Response.PSObject.Copy()
        } else {
            $Response
        }
        $errRecord = [System.Management.Automation.ErrorRecord]::new(
            [System.Exception]::new($errMsg),
            'SnipeitApiError',
            [System.Management.Automation.ErrorCategory]::InvalidData,
            $targetPayload
        )
        $PSCmdlet.ThrowTerminatingError($errRecord)
    }

    if ($statusVal -eq 'warning') {
        $warnMsg = if ($messagesVal) { ($messagesVal | Out-String).Trim() } else { 'Snipe-IT API returned warning status.' }
        Write-Warning $warnMsg
    }

    switch ($ResponseKind) {
        'NoContent' {
            return $null
        }

        'ScalarText' {
            return [string]$Response
        }

        'ImportResult' {
            $payload = & $getProp $Response 'payload'
            $tally = & $getProp $payload 'tally'
            $redirectUrl = & $getProp $payload 'redirect_url'

            $importResult = [PSCustomObject]@{
                PSTypeName  = 'SnipeitPS.ImportResult'
                Status      = $statusVal
                Messages    = $messagesVal
                Tally       = $tally
                RedirectUrl = $redirectUrl
            }
            return $importResult
        }

        'Select2' {
            $results = & $getProp $Response 'results'
            if ($null -ne $results) {
                foreach ($item in $results) {
                    if ($item -is [System.Management.Automation.PSObject] -and -not $item.PSObject.TypeNames.Contains('SnipeitPS.SelectListItem')) {
                        $item.PSObject.TypeNames.Insert(0, 'SnipeitPS.SelectListItem')
                    }
                    $item
                }
            }
            return
        }

        'RowsTotal' {
            $rows = & $getProp $Response 'rows'
            if ($null -eq $rows -or ($rows -is [System.Collections.ICollection] -and $rows.Count -eq 0)) {
                return @()
            }
            foreach ($row in $rows) {
                if ($ResultTypeName -and $row -is [System.Management.Automation.PSObject] -and -not $row.PSObject.TypeNames.Contains($ResultTypeName)) {
                    $row.PSObject.TypeNames.Insert(0, $ResultTypeName)
                }
                $row
            }
            return
        }

        'DirectArray' {
            if ($Response -is [System.Collections.IEnumerable] -and $Response -isnot [string] -and $Response -isnot [System.Collections.IDictionary]) {
                foreach ($item in $Response) {
                    if ($ResultTypeName -and $item -is [System.Management.Automation.PSObject] -and -not $item.PSObject.TypeNames.Contains($ResultTypeName)) {
                        $item.PSObject.TypeNames.Insert(0, $ResultTypeName)
                    }
                    $item
                }
            } else {
                if ($ResultTypeName -and $Response -is [System.Management.Automation.PSObject] -and -not $Response.PSObject.TypeNames.Contains($ResultTypeName)) {
                    $Response.PSObject.TypeNames.Insert(0, $ResultTypeName)
                }
                $Response
            }
            return
        }

        'DirectObject' {
            if ($ResultTypeName -and $Response -is [System.Management.Automation.PSObject] -and -not $Response.PSObject.TypeNames.Contains($ResultTypeName)) {
                $Response.PSObject.TypeNames.Insert(0, $ResultTypeName)
            }
            return $Response
        }

        'StandardEnvelope' {
            $hasPayload = & $hasProp $Response 'payload'
            $result = if ($hasPayload) { & $getProp $Response 'payload' } else { $Response }
            if ($null -ne $result -and $ResultTypeName -and $result -is [System.Management.Automation.PSObject] -and -not $result.PSObject.TypeNames.Contains($ResultTypeName)) {
                $result.PSObject.TypeNames.Insert(0, $ResultTypeName)
            }
            return $result
        }

        default {
            # Legacy default unwrap
            $hasPayload = & $hasProp $Response 'payload'
            $hasRows = & $hasProp $Response 'rows'
            $hasTotal = & $hasProp $Response 'total'

            if ($hasPayload) {
                $result = & $getProp $Response 'payload'
            } elseif ($hasRows) {
                $rows = & $getProp $Response 'rows'
                $result = if ($null -eq $rows -or ($rows -is [System.Collections.ICollection] -and $rows.Count -eq 0)) { @() } else { $rows }
            } elseif ($hasTotal -and ((& $getProp $Response 'total') -eq 0)) {
                $result = @()
            } else {
                $result = $Response
            }

            if ($result -is [System.Collections.IEnumerable] -and $result -isnot [string] -and $result -isnot [System.Collections.IDictionary]) {
                foreach ($item in $result) {
                    if ($ResultTypeName -and $item -is [System.Management.Automation.PSObject] -and -not $item.PSObject.TypeNames.Contains($ResultTypeName)) {
                        $item.PSObject.TypeNames.Insert(0, $ResultTypeName)
                    }
                    $item
                }
            } else {
                if ($ResultTypeName -and $result -is [System.Management.Automation.PSObject] -and -not $result.PSObject.TypeNames.Contains($ResultTypeName)) {
                    $result.PSObject.TypeNames.Insert(0, $ResultTypeName)
                }
                $result
            }
        }
    }
}
