BeforeDiscovery {
    Import-Module "$PSScriptRoot/../SnipeitPS/SnipeitPS.psd1" -Force
    $legacyPositions = @'
Get-SnipeitAccessoryOwner|__AllParameterSets|id,Session
Get-SnipeitActivity|__AllParameterSets|search,target_type,target_id,item_type,item_id,action_type,limit,offset,Session
Get-SnipeitAssetMaintenance|ByFilter|search,asset_id,sort,order,limit,offset,Session
Get-SnipeitComponentAsset|__AllParameterSets|id,limit,offset,Session
Get-SnipeitFieldsetField|__AllParameterSets|id,Session
Get-SnipeitLicenseSeat|__AllParameterSets|id,seat_id,limit,offset,Session
Get-SnipeitStatusAsset|__AllParameterSets|id,limit,offset,Session
Get-SnipeitUserAsset|__AllParameterSets|id,limit,offset,Session
Get-SnipeitUserEula|__AllParameterSets|id,Session
New-SnipeitAccessory|__AllParameterSets|name,qty,category_id,company_id,manufacturer_id,order_number,model_number,purchase_cost,purchase_date,min_amt,supplier_id,location_id,image,requestable,Session
New-SnipeitAssetMaintenance|ByAssetId|asset_id,supplier_id,asset_maintenance_type,title,start_date,expected_completion_date,is_warranty,cost,notes,assigned_to,responsible_party_id,Session
New-SnipeitCategory|__AllParameterSets|name,category_type,eula_text,image,Session
New-SnipeitCompany|__AllParameterSets|name,image,parent_id,Session
New-SnipeitComponent|__AllParameterSets|name,category_id,qty,company_id,location_id,order_number,purchase_date,purchase_cost,image,Session
New-SnipeitConsumable|__AllParameterSets|name,qty,category_id,min_amt,company_id,order_number,manufacturer_id,location_id,requestable,purchase_date,purchase_cost,model_number,item_no,image,Session
New-SnipeitCustomField|__AllParameterSets|name,help_text,element,format,field_values,field_encrypted,show_in_email,custom_format,Session
New-SnipeitDepartment|__AllParameterSets|name,company_id,location_id,manager_id,notes,image,Session
New-SnipeitLicense|__AllParameterSets|name,seats,category_id,company_id,expiration_date,license_email,license_name,maintained,manufacturer_id,notes,order_number,purchase_cost,purchase_date,reassignable,serial,supplier_id,termination_date,Session
New-SnipeitLocation|__AllParameterSets|name,address,address2,city,state,country,zip,currency,parent_id,manager_id,ldap_ou,image,Session
New-SnipeitManufacturer|__AllParameterSets|name,image,manufacturer_url,Session
New-SnipeitModel|__AllParameterSets|name,model_number,category_id,manufacturer_id,eol,fieldset_id,image,Session
New-SnipeitSupplier|__AllParameterSets|name,address,address2,city,state,country,zip,phone,fax,email,contact,notes,supplier_url,image,Session
New-SnipeitUser|__AllParameterSets|first_name,last_name,username,password,activated,notes,jobtitle,email,phone,companies,location_id,department_id,manager_id,groups,employee_num,ldap_import,image,Session
Reset-SnipeitAccessoryOwner|__AllParameterSets|assigned_pivot_id,Session
Reset-SnipeitAssetOwner|ById|id,status_id,location_id,note,Session
Save-SnipeitBackup|ByFilename|filename,path,Session
Set-SnipeitAccessory|__AllParameterSets|id,name,qty,category_id,company_id,manufacturer_id,model_number,order_number,purchase_cost,purchase_date,min_amt,supplier_id,location_id,image,requestable,RequestType,Session
Set-SnipeitAccessoryOwner|__AllParameterSets|id,assigned_to,checkout_to_type,note,Session
Set-SnipeitAsset|__AllParameterSets|id,asset_tag,name,status_id,model_id,last_checkout,assigned_to,company_id,serial,order_number,warranty_months,purchase_cost,purchase_date,supplier_id,requestable,archived,rtd_location_id,notes,RequestType,image,url,apiKey,customfields,Session
Set-SnipeitAssetOwner|ById|id,assigned_id,checkout_to_type,name,note,expected_checkin,checkout_at,status_id,Session
Set-SnipeitCategory|__AllParameterSets|id,name,category_type,eula_text,use_default_eula,require_acceptance,checkin_email,image,RequestType,Session
Set-SnipeitCompany|__AllParameterSets|id,name,image,parent_id,RequestType,Session
Set-SnipeitComponent|__AllParameterSets|id,qty,min_amt,name,company_id,location_id,order_number,purchase_date,purchase_cost,image,RequestType,Session
Set-SnipeitConsumable|__AllParameterSets|id,name,qty,category_id,min_amt,company_id,order_number,manufacturer_id,location_id,requestable,purchase_date,purchase_cost,model_number,item_no,image,RequestType,Session
Set-SnipeitCustomField|__AllParameterSets|id,name,help_text,element,format,field_values,field_encrypted,show_in_email,custom_format,RequestType,Session
Set-SnipeitDepartment|__AllParameterSets|id,name,company_id,location_id,manager_id,notes,image,RequestType,Session
Set-SnipeitLicense|__AllParameterSets|id,name,seats,category_id,company_id,expiration_date,license_email,license_name,maintained,manufacturer_id,notes,order_number,purchase_cost,purchase_date,reassignable,serial,supplier_id,termination_date,RequestType,Session
Set-SnipeitLocation|__AllParameterSets|id,name,address,address2,state,country,zip,city,currency,manager_id,ldap_ou,parent_id,image,RequestType,Session
Set-SnipeitManufacturer|__AllParameterSets|id,name,image,manufacturer_url,RequestType,Session
Set-SnipeitModel|__AllParameterSets|id,name,model_number,category_id,manufacturer_id,eol,custom_fieldset_id,image,RequestType,Session
Set-SnipeitSupplier|__AllParameterSets|id,name,address,address2,city,state,country,zip,phone,fax,email,contact,notes,image,supplier_url,RequestType,Session
Set-SnipeitUser|__AllParameterSets|id,first_name,last_name,username,jobtitle,email,phone,password,companies,location_id,department_id,manager_id,groups,employee_num,activated,notes,ldap_import,image,RequestType,Session
'@
    $cases = foreach ($line in ($legacyPositions -split '\r?\n')) {
        $parts = $line.Split('|')
        @{ Command = $parts[0]; ParameterSet = $parts[1]; Names = $parts[2].Split(',') }
    }
}

Describe 'Legacy public positional parameter contracts' {
    It '<Command> retains every original position in <ParameterSet>' -ForEach $cases {
        $set = (Get-Command $Command -Module SnipeitPS).ParameterSets | Where-Object Name -EQ $ParameterSet
        $set | Should -Not -BeNullOrEmpty
        for ($i = 0; $i -lt $Names.Count; $i++) {
            $parameter = $set.Parameters | Where-Object Name -EQ $Names[$i]
            $parameter | Should -Not -BeNullOrEmpty
            $parameter.Position | Should -Be $i -Because "$Command $($Names[$i]) occupied position $i before API parity"
        }
    }

    InModuleScope SnipeitPS {
        BeforeEach {
            $key = ConvertTo-SecureString 'test-only-key' -AsPlainText -Force
            $script:positionalSession = [SnipeitSession]::new('https://contract.invalid', $key)
            Mock Invoke-SnipeitMethod { param($Body, $GetParameters, $Session)
                [pscustomobject]@{ Body = $Body; Query = $GetParameters; Session = $Session }
            }
        }

        It 'Keeps a numeric checkout note separate from quantity and forwards the positional session' {
            $result = Set-SnipeitAccessoryOwner 1 2 user '5' $script:positionalSession -Confirm:$false
            $result.Body.note | Should -Be '5'
            $result.Body.ContainsKey('checkout_qty') | Should -BeFalse
            [object]::ReferenceEquals($result.Session, $script:positionalSession) | Should -BeTrue
        }

        It 'Keeps a maintenance search string at position zero' {
            $result = Get-SnipeitAssetMaintenance 'printer' 1 'created_at' 'desc' 50 0 $script:positionalSession
            $result.Query.search | Should -Be 'printer'
            $result.Query.asset_id | Should -Be 1
            [object]::ReferenceEquals($result.Session, $script:positionalSession) | Should -BeTrue
        }

        It 'Retains named maintenance ID retrieval' {
            Get-SnipeitAssetMaintenance -id 4 -Session $script:positionalSession
            Should -Invoke Invoke-SnipeitMethod -Times 1 -Exactly -ParameterFilter {
                $Route -eq '/api/v1/maintenances/4'
            }
        }
    }
}
