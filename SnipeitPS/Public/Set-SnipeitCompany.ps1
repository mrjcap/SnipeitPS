<#
.SYNOPSIS
Updates company details

.DESCRIPTION
Updates company details on Snipe-IT system

.PARAMETER id
ID number of company

.PARAMETER name
Company name

.PARAMETER image
Image file name and path for item

.PARAMETER image_delete
Remove current image

.PARAMETER RequestType
HTTP request type to send to Snipe-IT system. Defaults to Patch. You could use Put if needed.

.PARAMETER parent_id
Parent company ID. Use null to clear the parent.

.PARAMETER phone
Company phone number. Use null to clear it.

.PARAMETER fax
Company fax number. Use null to clear it.

.PARAMETER email
Company email address. Use null to clear it.

.PARAMETER tag_color
Company tag color. Use an empty string to clear it.

.PARAMETER notes
Company notes. Use an empty string to clear them.

.PARAMETER Session
Optional custom SnipeitSession instance.

.OUTPUTS

System.Management.Automation.PSCustomObject


.EXAMPLE
Set-SnipeitCompany -id 1 -name "Updated Company Name"
Updates company name
#>
function Set-SnipeitCompany() {
    [CmdletBinding(
        SupportsShouldProcess = $true,
        ConfirmImpact = "Medium"
    )]
    [OutputType([PSCustomObject])]

    Param(
        [parameter(mandatory = $true,ValueFromPipelineByPropertyName)]
        [int[]]$id,

        [parameter(mandatory = $false)]
        [string]$name,

        [ValidateScript({Test-Path $_})]
        [string]$image,

        [Nullable[int]]$parent_id,

        [switch]$image_delete=$false,

        [ValidateSet("Put","Patch")]
        [string]$RequestType = "Patch",

        [Parameter(Mandatory = $false)]
        [SnipeitSession]$Session,

        [string]$phone,

        [string]$fax,

        [string]$email,

        [string]$tag_color,

        [string]$notes
    )

    begin{
        Write-Verbose "[$($MyInvocation.MyCommand.Name)] Starting"
        $Values = . Get-ParameterValue -Parameters $MyInvocation.MyCommand.Parameters -BoundParameters $PSBoundParameters
        foreach ($field in @('phone', 'fax', 'email')) {
            if ($Values.ContainsKey($field) -and [string]::IsNullOrEmpty($Values[$field])) {
                $Values[$field] = $null
            }
        }
    }

    process{
        foreach($company_id in $id) {
            $Parameters = @{
                Api    = "$script:SnipeitApiPrefix/companies/$company_id"
                Method = $RequestType
                Session = $Session
                Body   = $Values.Clone()
            }

            if ($PSCmdlet.ShouldProcess("Company ID $company_id", $MyInvocation.MyCommand.Name)) {
                $result = Invoke-SnipeitMethod @Parameters
                $result
            }
        }
    }
    end {
        Write-Verbose "[$($MyInvocation.MyCommand.Name)] Complete"
    }
}
