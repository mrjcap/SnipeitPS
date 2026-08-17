BeforeAll {
    Import-Module ./SnipeitPS/SnipeitPS.psd1 -Force
    $testUrl = $env:SNIPEIT_TEST_URL ?? 'http://192.168.1.47'
    $testKey = $env:SNIPEIT_TEST_KEY ?? 'eyJ0eXAiOiJKV1QiLCJhbGciOiJSUzI1NiJ9.eyJhdWQiOiIzIiwianRpIjoiMjk1OGM2ZWY2ZDU3ZTAxZWM4NmIxN2NjMGFlZjA1NGVkY2UwOThlMzllNzQ3MTZmMTE4NDhmMTdjNTVlYzc4ODFhMGNjMDE5ZDdiM2NiODYiLCJpYXQiOjE3ODY5MDkzNjIuNjQ5NDgzLCJuYmYiOjE3ODY5MDkzNjIuNjQ5NDksImV4cCI6MjQxODA2MTM2Mi42MjUwOTEsInN1YiI6IjEiLCJzY29wZXMiOltdfQ.E3MaayqG_D3GJ4vBMyQjNJG261xR6Gl5MtZrVLcpUL9hWoCdz7gq3-ModyV2t36JjXMiG2_z_-wNYkmJSTH-K8BKetGjAP9ofUXVieNZbrsqthZffGZV23AZwHnMPDTfXFzkC9xRn9Qf0T55gyHytCGEWl524Zg4EkvUkeGbGBhlvsZ0hJfMg3RpvU1ONtEqAAvLlu4nCJUNscqEltoAuVvqbFhn4oYS20M8o1VJTvdj36V_oP-5BEXWP-x6i5_v2WDk2EF8BItj2g3Q3XGDmX63n3mvXKKuO1xFpLp5zNZISJ1Xl8FWqszrFRnP4x2qz8aWQMeXI2_-hAc4bOjKDZuw_4YUEYB9CE3PHKVjdXQtDpTOsbRu6t-661lk75oOwZpR6dUe-3LB7vQ0tBblJgRNX9wNr7AV0fm1DmLctwkSEFzhW0KqbnzBi_iba8NAwRoZksISUHz9AaBOkcV_kTD1P8NCLl8BkZ8YDuxlLVac0lQmhVIbaOov84qLW3sP_bOhGi64EQXE3FEapNae8cMfSk5_bzQWV2_4vIxsWtpzMjHt7IWpFvb07W6KyjzcQSZKRkbBFJWGduhy9_LcERPh5Gu2izKBP7nRili41JDLsGQ_7Pt0vnBoxdwOMuJBZtph5ZFjHWtOdrDkpJ-pLjQnNiRGIYSGYHC9XfvFaR4'
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
