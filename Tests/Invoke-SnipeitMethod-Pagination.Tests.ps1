BeforeAll {
    Import-Module "$PSScriptRoot/../SnipeitPS/SnipeitPS.psd1" -Force
}

Describe 'Invoke-SnipeitMethod singleton pagination' {
    It 'Counts a singleton <Shape> row as one record on every page' -TestCases @(
        @{ Shape = 'PSCustomObject' },
        @{ Shape = 'Hashtable' }
    ) {
        param($Shape)
        InModuleScope SnipeitPS -Parameters @{ Shape = $Shape } {
            param($Shape)
            $session = [pscustomobject]@{ Url = 'https://pagination.invalid'; ApiKey = 'test-only-key'; ThrottleLimit = 0 }
            $script:paginationShape = $Shape
            Mock Invoke-RestMethod {
                $id = if ($Uri -match 'offset=1') { 2 } else { 1 }
                $row = @{ id = $id; name = "Row$id" }
                if ($script:paginationShape -eq 'PSCustomObject') { $row = [pscustomobject]$row }
                [pscustomobject]@{ total = 2; rows = @($row) }
            }
            $rows = @(Invoke-SnipeitMethod -Session $session -Api '/api/v1/hardware' -GetParameters @{ limit = 1; offset = 0 } -Paginate)
            $rows.Count | Should -Be 2
            $rows[0].id | Should -Be 1
            $rows[1].id | Should -Be 2
            Should -Invoke Invoke-RestMethod -Times 2 -Exactly
            Should -Invoke Invoke-RestMethod -Times 1 -Exactly -ParameterFilter { $Uri -match 'offset=1' }
        }
    }
}
