<#
.SYNOPSIS
Gets a list of Snipe-IT Users

.PARAMETER search
A text string to search the User data

.PARAMETER id
An ID of a specific User

.PARAMETER accessory_id
Get users that a specific accessory ID has been checked out to

.PARAMETER username
Optionally restrict User results to this username field

.PARAMETER email
Optionally restrict User results to this email field

.PARAMETER employee_num
Optionally restrict User results to this employee_num field

.PARAMETER state
Optionally restrict User results to this state field

.PARAMETER country
Optionally restrict User results to this country field

.PARAMETER zip
Optionally restrict User results to this zip field

.PARAMETER company_id
Optionally restrict User results to this company_id field

.PARAMETER location_id
Optionally restrict User results to this location_id field

.PARAMETER group_id
Optionally restrict User results to this group_id field

.PARAMETER department_id
Optionally restrict User results to this department_id field

.PARAMETER include_deleted
Include both active and deleted users. Maps to the server all filter independently of -all pagination.
The deleted filter takes precedence when both filters are true.

.PARAMETER deleted
Optionally restrict User results to deleted users only

.PARAMETER ldap_import
Optionally restrict User results to those with specified ldap_import value

.PARAMETER remote
Optionally restrict User results to those with specified remote worker value

.PARAMETER assets_count
Optionally restrict User results to those with the specified assets count

.PARAMETER licenses_count
Optionally restrict User results to those with the specified licenses count

.PARAMETER accessories_count
Optionally restrict User results to those with the specified accessories count

.PARAMETER consumables_count
Optionally restrict User results to those with the specified consumables count

.PARAMETER sort
Column to sort on

.PARAMETER order
Sort order for results, one of 'asc' or 'desc'. Defaults to 'desc'

.PARAMETER limit
Specify the number of results you wish to return. Defaults to 50. Defines batch size for -all

.PARAMETER offset
Offset to use

.PARAMETER all
Return all results, works with -offset and other parameters

.PARAMETER first_name
Match the user's first name.

.PARAMETER last_name
Match the user's last name.

.PARAMETER display_name
Match the user's display name.

.PARAMETER phone
Match a phone number.

.PARAMETER mobile
Match a mobile phone number.

.PARAMETER website
Match a website URL.

.PARAMETER locale
Match the preferred interface locale.

.PARAMETER manager_id
Restrict results to users reporting to this manager ID.

.PARAMETER created_by
Restrict results to the creating user's ID.

.PARAMETER start_date
Match the employment start date using yyyy-MM-dd.

.PARAMETER end_date
Match the employment end date using yyyy-MM-dd.

.PARAMETER activated
Filter by account activation state.

.PARAMETER vip
Filter by VIP status.

.PARAMETER autoassign_licenses
Filter by automatic license assignment eligibility.

.PARAMETER two_factor_enrolled
Filter by two-factor enrollment state.

.PARAMETER two_factor_optin
Filter by two-factor opt-in state.

.PARAMETER admins
Restrict results to administrators.

.PARAMETER superadmins
Restrict results to superadministrators.

.PARAMETER expand_company_hierarchy
Include descendant companies when filtering by company_id.

.PARAMETER manages_users_count
Match the number of users managed, including zero.

.PARAMETER manages_locations_count
Match the number of locations managed, including zero.

.PARAMETER assigned_maintenances_count
Match the number of assigned maintenances, including zero.

.PARAMETER filter
Server search filter, taking precedence over search.

.PARAMETER Session
Optional custom SnipeitSession instance.

.OUTPUTS

System.Management.Automation.PSCustomObject


.EXAMPLE
Get-SnipeitUser -search SomeSurname

.EXAMPLE
Get-SnipeitUser -id 3

.EXAMPLE
Get-SnipeitUser -username someuser

.EXAMPLE
Get-SnipeitUser -email user@somedomain.com

.EXAMPLE
Get-SnipeitUser -accessory_id 3
Get users that accessory ID 3 has been checked out to
#>

function Get-SnipeitUser() {
    [CmdletBinding(DefaultParameterSetName = 'Search')]
    [OutputType([PSCustomObject])]
    Param(
        [parameter(ParameterSetName='Search')]
        [string]$search,

        [parameter(ParameterSetName='Get with ID', ValueFromPipelineByPropertyName = $true)]
        [int]$id,

        [parameter(ParameterSetName='Get users a specific accessory id has been checked out to', ValueFromPipelineByPropertyName = $true)]
        [int]$accessory_id,

        [parameter(ParameterSetName='Search')]
        [ArgumentCompleter([SnipeitCompanyCompleter])]
        [int]$company_id,

        [parameter(ParameterSetName='Search')]
        [ArgumentCompleter([SnipeitLocationCompleter])]
        [int]$location_id,

        [parameter(ParameterSetName='Search')]
        [int]$group_id,

        [parameter(ParameterSetName='Search')]
        [ArgumentCompleter([SnipeitDepartmentCompleter])]
        [int]$department_id,

        [parameter(ParameterSetName='Search')]
        [string]$username,

        [parameter(ParameterSetName='Search')]
        [string]$email,

        [parameter(ParameterSetName='Search')]
        [string]$employee_num,

        [parameter(ParameterSetName='Search')]
        [string]$state,

        [parameter(ParameterSetName='Search')]
        [string]$zip,

        [parameter(ParameterSetName='Search')]
        [string]$country,

        [parameter(ParameterSetName='Search')]
        [Nullable[bool]]$include_deleted,

        [parameter(ParameterSetName='Search')]
        [Nullable[bool]]$deleted,

        [parameter(ParameterSetName='Search')]
        [Nullable[bool]]$ldap_import,

        [parameter(ParameterSetName='Search')]
        [Nullable[bool]]$remote,

        [parameter(ParameterSetName='Search')]
        [int]$assets_count,

        [parameter(ParameterSetName='Search')]
        [int]$licenses_count,

        [parameter(ParameterSetName='Search')]
        [int]$accessories_count,

        [parameter(ParameterSetName='Search')]
        [int]$consumables_count,

        [parameter(ParameterSetName='Search')]
        [string]$sort = "created_at",

        [parameter(ParameterSetName='Search')]
        [ValidateSet("asc", "desc")]
        [string]$order = "desc",

        [parameter(ParameterSetName='Search')]
        [ValidateRange(1,500)]
        [int]$limit = 50,

        [parameter(ParameterSetName='Search')]
        [int]$offset,

        [parameter(ParameterSetName='Search')]
        [parameter(ParameterSetName='Get users a specific accessory id has been checked out to')]
        [switch]$all = $false,

        [parameter(ParameterSetName='Search')]
        [string]$first_name,

        [parameter(ParameterSetName='Search')]
        [string]$last_name,

        [parameter(ParameterSetName='Search')]
        [string]$display_name,

        [parameter(ParameterSetName='Search')]
        [string]$phone,

        [parameter(ParameterSetName='Search')]
        [string]$mobile,

        [parameter(ParameterSetName='Search')]
        [string]$website,

        [parameter(ParameterSetName='Search')]
        [string]$locale,

        [parameter(ParameterSetName='Search')]
        [int]$manager_id,

        [parameter(ParameterSetName='Search')]
        [int]$created_by,

        [parameter(ParameterSetName='Search')]
        [string]$start_date,

        [parameter(ParameterSetName='Search')]
        [string]$end_date,

        [parameter(ParameterSetName='Search')]
        [Nullable[bool]]$activated,

        [parameter(ParameterSetName='Search')]
        [Nullable[bool]]$vip,

        [parameter(ParameterSetName='Search')]
        [Nullable[bool]]$autoassign_licenses,

        [parameter(ParameterSetName='Search')]
        [Nullable[bool]]$two_factor_enrolled,

        [parameter(ParameterSetName='Search')]
        [Nullable[bool]]$two_factor_optin,

        [parameter(ParameterSetName='Search')]
        [Nullable[bool]]$admins,

        [parameter(ParameterSetName='Search')]
        [Nullable[bool]]$superadmins,

        [parameter(ParameterSetName='Search')]
        [Nullable[bool]]$expand_company_hierarchy,

        [parameter(ParameterSetName='Search')]
        [int]$manages_users_count,

        [parameter(ParameterSetName='Search')]
        [int]$manages_locations_count,

        [parameter(ParameterSetName='Search')]
        [int]$assigned_maintenances_count,

        [parameter(ParameterSetName='Search')]
        [string]$filter,

        [Parameter(Mandatory = $false)]
        [SnipeitSession]$Session
    )

    begin {
        Write-Verbose "[$($MyInvocation.MyCommand.Name)] Starting"
$SearchParameter = . Get-ParameterValue -Parameters $MyInvocation.MyCommand.Parameters -BoundParameters $PSBoundParameters
        foreach ($field in @('activated', 'vip', 'autoassign_licenses', 'two_factor_enrolled', 'two_factor_optin', 'ldap_import', 'remote')) {
            if ($null -ne $SearchParameter[$field]) { $SearchParameter[$field] = [int][bool]$SearchParameter[$field] }
        }
    }
    process {
        $pathParams = @{}
        switch ($PsCmdlet.ParameterSetName) {
            'Search' { $route = "$script:SnipeitApiPrefix/users" }
            'Get with id' {
                $route = "$script:SnipeitApiPrefix/users/{id}"
                $pathParams['id'] = $id
            }
            'Get users a specific accessory id has been checked out to' {
                $route = "$script:SnipeitApiPrefix/accessories/{accessory_id}/checkedout"
                $pathParams['accessory_id'] = $accessory_id
            }
        }

        if ($SearchParameter.ContainsKey('all')) {
            $SearchParameter.Remove('all')
        }

        $SearchParameter.Remove('include_deleted')
        if ($PSBoundParameters.ContainsKey('include_deleted')) {
            $SearchParameter['all'] = $include_deleted
        }

        $Parameters = @{
            Route         = $route
            PathParameter = $pathParams
            Method        = 'Get'
            Session = $Session
            GetParameters = $SearchParameter
            Paginate      = [bool]$all
        }

        $result = Invoke-SnipeitMethod @Parameters
        $result
    }

    end {
        Write-Verbose "[$($MyInvocation.MyCommand.Name)] Complete"
    }
}
