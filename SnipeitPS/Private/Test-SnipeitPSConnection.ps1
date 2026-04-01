function Test-SnipeitPSConnection {
    [CmdletBinding()]
    param()
    #test API connection
    $Parameters = @{
        Api           = "$script:SnipeitApiPrefix/statuslabels"
        Method        = 'Get'
        GetParameters = @{'limit'=1}
    }
    Write-Verbose "Testing connection to $($SnipeitPSSession.url)."

    $result = Invoke-SnipeitMethod @Parameters

    if ( $result) {
        Write-Verbose "Connection to $($SnipeitPSSession.url) tested successfully."
        return $true
    } else {
        return $false
    }
}
