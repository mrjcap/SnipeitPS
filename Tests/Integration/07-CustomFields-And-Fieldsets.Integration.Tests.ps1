BeforeAll {
    Import-Module ./SnipeitPS/SnipeitPS.psd1 -Force
    $testUrl = $env:SNIPEIT_TEST_URL
    $testKey = $env:SNIPEIT_TEST_KEY
    if ([string]::IsNullOrWhiteSpace($testUrl) -or [string]::IsNullOrWhiteSpace($testKey)) {
        throw "Integration tests require SNIPEIT_TEST_URL and SNIPEIT_TEST_KEY environment variables."
    }
    Connect-SnipeitPS -URL $testUrl -apiKey $testKey
    $script:testTimestamp = [DateTimeOffset]::UtcNow.ToUnixTimeSeconds()
}

Describe "Live Snipe-IT Integration: Custom Fields & Fieldsets" -Tag "Integration" {
    Context "Custom Field Lifecycle" {
        BeforeAll {
            $script:fieldName = "INT-CF-$($script:testTimestamp)"
            $script:createdField = New-SnipeitCustomField -name $script:fieldName `
                -element "text" `
                -format "ANY" `
                -help_text "Integration test custom field"
        }

        AfterAll {
            if ($script:createdField -and $script:createdField.id) {
                Remove-SnipeitCustomField -id $script:createdField.id -Confirm:$false
            }
        }

        It "Creates a new custom field" {
            $script:createdField | Should -Not -BeNullOrEmpty
            $script:createdField.id | Should -BeGreaterThan 0
        }

        It "Retrieves custom field by ID" {
            $field = Get-SnipeitCustomField -id $script:createdField.id
            $field | Should -Not -BeNullOrEmpty
            $field.name | Should -Be $script:fieldName
        }

        It "Updates custom field details" {
            $updatedFieldName = "$($script:fieldName)-Upd"
            $null = Set-SnipeitCustomField -id $script:createdField.id -name $updatedFieldName -element "text" -format "ANY"
            $field = Get-SnipeitCustomField -id $script:createdField.id
            $field.name | Should -Be $updatedFieldName
        }
    }

    Context "Fieldset Lifecycle and Associations" {
        BeforeAll {
            $script:fieldsetName = "INT-Fieldset-$($script:testTimestamp)"
            $script:createdFieldset = New-SnipeitFieldset -name $script:fieldsetName

            $script:assocFieldName = "INT-AssocField-$($script:testTimestamp)"
            $script:assocField = New-SnipeitCustomField -name $script:assocFieldName -element "text" -format "ANY"
        }

        AfterAll {
            if ($script:assocField -and $script:assocField.id) {
                try {
                    Unregister-SnipeitCustomField -id $script:assocField.id -fieldset_id $script:createdFieldset.id -Confirm:$false
                } catch {}
                Remove-SnipeitCustomField -id $script:assocField.id -Confirm:$false
            }
            if ($script:createdFieldset -and $script:createdFieldset.id) {
                Remove-SnipeitFieldset -id $script:createdFieldset.id -Confirm:$false
            }
        }

        It "Creates a new fieldset" {
            $script:createdFieldset | Should -Not -BeNullOrEmpty
            $script:createdFieldset.id | Should -BeGreaterThan 0
        }

        It "Retrieves fieldset by ID" {
            $fieldset = Get-SnipeitFieldset -id $script:createdFieldset.id
            $fieldset | Should -Not -BeNullOrEmpty
            $fieldset.name | Should -Be $script:fieldsetName
        }

        It "Updates fieldset details" {
            $updatedFieldsetName = "$($script:fieldsetName)-Upd"
            $null = Set-SnipeitFieldset -id $script:createdFieldset.id -name $updatedFieldsetName
            $fieldset = Get-SnipeitFieldset -id $script:createdFieldset.id
            $fieldset.name | Should -Be $updatedFieldsetName
        }

        It "Associates custom field with fieldset" {
            $reg = Register-SnipeitCustomField -id $script:assocField.id -fieldset_id $script:createdFieldset.id
            $reg | Should -Not -BeNullOrEmpty
        }

        It "Retrieves fields in fieldset" {
            $fields = Get-SnipeitFieldsetField -id $script:createdFieldset.id
            $fields | Should -Not -BeNullOrEmpty
            ($fields | Where-Object { $_.id -eq $script:assocField.id }) | Should -Not -BeNullOrEmpty
        }

        It "Disassociates custom field from fieldset" {
            $unreg = Unregister-SnipeitCustomField -id $script:assocField.id -fieldset_id $script:createdFieldset.id -Confirm:$false
            $unreg | Should -Not -BeNullOrEmpty
        }
    }
}
