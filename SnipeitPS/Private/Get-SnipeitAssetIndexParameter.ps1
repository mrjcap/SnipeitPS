function Get-SnipeitAssetIndexParameter {
    [CmdletBinding()]
    [OutputType([hashtable])]
    param(
        [Parameter(Mandatory = $true)]
        [hashtable]$BoundParameters
    )

    $query = @{}
    foreach ($field in @(
        'search', 'filter', 'sort', 'order', 'offset', 'limit', 'status_type',
        'status_id', 'asset_tag', 'serial', 'requestable', 'model_id', 'category_id',
        'location_id', 'rtd_location_id', 'supplier_id', 'asset_eol_date',
        'assigned_to', 'assigned_type', 'company_id', 'expand_company_hierarchy',
        'manufacturer_id', 'depreciation_id', 'byod', 'order_number', 'components'
    )) {
        if ($BoundParameters.Contains($field)) { $query[$field] = $BoundParameters[$field] }
    }
    foreach ($field in @('byod', 'components')) {
        if ($null -ne $query[$field]) { $query[$field] = [int][bool]$query[$field] }
    }
    if ($null -ne $query['asset_eol_date']) {
        $query['asset_eol_date'] = $query['asset_eol_date'].ToString('yyyy-MM-dd', [Globalization.CultureInfo]::InvariantCulture)
    }
    if ($BoundParameters.Contains('asset_status')) { $query['status'] = $BoundParameters['asset_status'] }
    if ($BoundParameters['customfields']) {
        foreach ($entry in $BoundParameters['customfields'].GetEnumerator()) {
            if ($entry.Key -cnotmatch '^_snipeit_[a-zA-Z0-9_]+_\d+$') {
                throw "customfields requires internal Snipe-IT custom-field column names, not '$($entry.Key)'."
            }
            $query[$entry.Key] = $entry.Value
        }
    }
    return $query
}
