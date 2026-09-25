<#
.SYNOPSIS
Creates a new Company

.DESCRIPTION
Creates a new company on Snipe-IT system

.PARAMETER name
Company name

.PARAMETER image
Company image filename and path

.PARAMETER parent_id
Parent company ID. Use null for a top-level company.

.PARAMETER phone
Company phone number.

.PARAMETER fax
Company fax number.

.PARAMETER email
Company email address.

.PARAMETER tag_color
Company tag color.

.PARAMETER notes
Company notes.

.PARAMETER Session
Optional custom SnipeitSession instance.

.OUTPUTS

System.Management.Automation.PSCustomObject


.EXAMPLE
New-SnipeitCompany -name "Acme Company"

#>

function New-SnipeitCompany() {
    [CmdletBinding(
        SupportsShouldProcess = $true,
        ConfirmImpact = "Low"
    )]
    [OutputType([PSCustomObject])]

    Param(
        [parameter(mandatory = $true)]
        [string]$name,

        [ValidateScript({Test-Path $_})]
        [string]$image,

        [Nullable[int]]$parent_id,

        [Parameter(Mandatory = $false)]
        [SnipeitSession]$Session,

        [string]$phone,

        [string]$fax,

        [string]$email,

        [string]$tag_color,

        [string]$notes
    )
    begin {
        Write-Verbose "[$($MyInvocation.MyCommand.Name)] Starting"
        $Values = . Get-ParameterValue -Parameters $MyInvocation.MyCommand.Parameters -BoundParameters $PSBoundParameters
        foreach ($field in @('phone', 'fax', 'email')) {
            if ($Values.ContainsKey($field) -and [string]::IsNullOrEmpty($Values[$field])) {
                $Values[$field] = $null
            }
        }

        $Parameters = @{
            Api    = "$script:SnipeitApiPrefix/companies"
            Method = 'POST'
            Session = $Session
            Body   = $Values
        }
    }

    process {
        if ($PSCmdlet.ShouldProcess("Company '$name'", $MyInvocation.MyCommand.Name)) {
            $result = Invoke-SnipeitMethod @Parameters
            $result
        }
    }

    end {
        Write-Verbose "[$($MyInvocation.MyCommand.Name)] Complete"
    }
}

