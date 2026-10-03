function ConvertTo-SnipeitResourceIdentity {
    [CmdletBinding()]
    [OutputType([object])]
    param(
        [AllowNull()]
        [object]$InputObject,
        [string]$Route
    )

    $resourceKey = $null
    $relatedIdProperty = 'request_id'
    $requestableKey = $null
    if ($Route -match '/users/[^/]+/(accessories|licenses|consumables)(?:\?|$)') {
        $resourceKey = @{ accessories = 'accessory'; licenses = 'license'; consumables = 'consumable' }[$Matches[1]]
        $relatedIdProperty = if ($resourceKey -eq 'license') { 'seat_id' } else { 'checkout_id' }
    } elseif ($Route -match '/account/requestable/(models|accessories|consumables|components|licenses)(?:\?|$)') {
        $requestableKey = @{ models = 'model'; accessories = 'accessory'; consumables = 'consumable'; components = 'component'; licenses = 'license' }[$Matches[1]]
        $relatedIdProperty = "${requestableKey}_id"
    } elseif ($Route -notmatch '/(?:account/)?requests(?:\?|$)') {
        return $InputObject
    }
    if ($null -eq $InputObject) { return }

    $record = if ($InputObject -is [System.Collections.IDictionary]) {
        [pscustomobject]$InputObject
    } else {
        $InputObject.PSObject.Copy()
    }
    if (-not $record.PSObject.Properties['id']) { return $InputObject }
    if ($resourceKey -and -not $record.PSObject.Properties[$resourceKey]) { return $InputObject }

    $resourceId = 0
    if ($resourceKey -and (-not [int]::TryParse([string]$record.$resourceKey.id, [ref]$resourceId) -or $resourceId -le 0)) {
        $errorRecord = [System.Management.Automation.ErrorRecord]::new(
            [System.ArgumentException]::new("API assignment row has no valid $resourceKey ID."),
            'SnipeitResourceIdentityError',
            [System.Management.Automation.ErrorCategory]::InvalidData,
            $InputObject
        )
        $PSCmdlet.ThrowTerminatingError($errorRecord)
    }
    $record | Add-Member -NotePropertyName $relatedIdProperty -NotePropertyValue $record.id -Force
    if ($resourceKey) {
        $record.id = $resourceId
    } else {
        $record.PSObject.Properties.Remove('id')
    }
    $record
}
