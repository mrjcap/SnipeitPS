<#
.SYNOPSIS
Lists permission-scoped calendar events.
.DESCRIPTION
Queries GET /api/v1/calendar/events. The server uses a half-open start/end range
and defaults to three months before and after today. There is no offset or all
option. PreserveResponse retains events, total, and truncated. The total is a
coarse permission-filtered count; per-row access checks may reduce returned events.
.PARAMETER start
Inclusive range start as an ISO-8601 string. Omit to use the server default.
.PARAMETER end
Exclusive range end as an ISO-8601 string. Omit to use the server default.
.PARAMETER event_type
Event type strings. Sends a comma-separated filter; omission selects all types.
.PARAMETER limit
Maximum events, from 1 to 500. Defaults to 500.
.PARAMETER PreserveResponse
Returns the complete events/total/truncated envelope instead of event rows.
.PARAMETER Session
Optional custom SnipeitSession instance.
.EXAMPLE
Get-SnipeitCalendarEvent -event_type asset.audit_due -PreserveResponse
#>
function Get-SnipeitCalendarEvent {
    [CmdletBinding()]
    [OutputType([PSCustomObject])]
    param(
        [string]$start,
        [string]$end,
        [string[]]$event_type,
        [ValidateRange(1, 500)]
        [int]$limit = 500,
        [switch]$PreserveResponse,
        [SnipeitSession]$Session
    )

    $query = @{ limit = $limit }
    foreach ($key in @('start', 'end')) {
        if ($PSBoundParameters.ContainsKey($key)) { $query[$key] = $PSBoundParameters[$key] }
    }
    if ($PSBoundParameters.ContainsKey('event_type')) { $query['event_type'] = $event_type -join ',' }
    $response = Invoke-SnipeitMethod -Route "$script:SnipeitApiPrefix/calendar/events" -Method Get -GetParameters $query -Session $Session -PreserveResponse
    if ($PreserveResponse) { return $response }
    foreach ($calendarEvent in $response.events) {
        if ($null -eq $calendarEvent) { continue }
        $copy = $calendarEvent.PSObject.Copy()
        $copy.PSObject.TypeNames.Insert(0, 'SnipeitPS.CalendarEvent')
        $copy
    }
}
