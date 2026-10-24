BeforeDiscovery {
    Import-Module "$PSScriptRoot/../SnipeitPS/SnipeitPS.psd1" -Force
}

Describe 'Inventory archive parity with Snipe-IT 95b7e49' {
    InModuleScope SnipeitPS {
        BeforeEach {
            $script:archiveSession = [SnipeitSession]::new('https://archive.invalid', (ConvertTo-SecureString 'offline' -AsPlainText -Force))
            $script:archiveSession.ThrottleLimit = 0
            $script:archiveCalls = [Collections.Generic.List[object]]::new()
            $script:archiveResponse = [pscustomobject]@{ status = 'success'; payload = [pscustomobject]@{ id = 7; archived = $true } }
            Mock Invoke-RestMethod {
                param($Uri, $Method, $Body)
                $json = if ($Body -is [byte[]]) { [Text.Encoding]::UTF8.GetString($Body) } else { [string]$Body }
                $script:archiveCalls.Add([pscustomobject]@{ Uri = ([uri]$Uri).AbsoluteUri; Method = [string]$Method; Json = $json })
                $script:archiveResponse
            }
        }

        Context '<Command> archive writes' -ForEach @(
            @{ Command = 'New-SnipeitAccessory'; Extra = @{ name = 'Fixture'; category_id = 3; qty = 0 }; Leaf = 'accessories'; Method = 'POST'; LastParameter = 'default_purchase_cost'; LastPosition = 18 },
            @{ Command = 'Set-SnipeitAccessory'; Extra = @{ id = 7 }; Leaf = 'accessories/7'; Method = 'PATCH'; LastParameter = 'default_purchase_cost'; LastPosition = 22 },
            @{ Command = 'New-SnipeitComponent'; Extra = @{ name = 'Fixture'; category_id = 3; qty = 0 }; Leaf = 'components'; Method = 'POST'; LastParameter = 'requestable'; LastPosition = 19 },
            @{ Command = 'Set-SnipeitComponent'; Extra = @{ id = 7 }; Leaf = 'components/7'; Method = 'PATCH'; LastParameter = 'requestable'; LastPosition = 23 },
            @{ Command = 'New-SnipeitConsumable'; Extra = @{ name = 'Fixture'; category_id = 3; qty = 0 }; Leaf = 'consumables'; Method = 'POST'; LastParameter = 'default_purchase_cost'; LastPosition = 19 },
            @{ Command = 'Set-SnipeitConsumable'; Extra = @{ id = 7 }; Leaf = 'consumables/7'; Method = 'PATCH'; LastParameter = 'default_purchase_cost'; LastPosition = 23 }
        ) {
            It 'serializes explicit true, false, and null without changing requestability' {
                foreach ($value in @($true, $false, $null)) {
                    & $Command @Extra -archived $value -Session $script:archiveSession -Confirm:$false | Out-Null
                    $call = $script:archiveCalls[$script:archiveCalls.Count - 1]
                    $call.Uri | Should -Be "https://archive.invalid/api/v1/$Leaf"
                    $call.Method | Should -Be $Method
                    $body = $call.Json | ConvertFrom-Json
                    $body.PSObject.Properties.Name | Should -Contain 'archived'
                    if ($null -eq $value) { $body.archived | Should -BeNullOrEmpty }
                    else {
                        $body.archived | Should -BeOfType ([bool])
                        $body.archived | Should -Be $value
                    }
                    $body.PSObject.Properties.Name | Should -Not -Contain 'requestable'
                    $body.PSObject.Properties.Name | Should -Not -Contain 'Session'
                }
                $script:archiveCalls.Count | Should -Be 3
            }

            It 'omits an unbound archive flag and retains explicit requestable false' {
                & $Command @Extra -requestable $false -Session $script:archiveSession -Confirm:$false | Out-Null
                $body = $script:archiveCalls[0].Json | ConvertFrom-Json
                $body.PSObject.Properties.Name | Should -Not -Contain 'archived'
                $body.requestable | Should -BeOfType ([bool])
                $body.requestable | Should -BeFalse
                $script:archiveCalls.Count | Should -Be 1
            }

            It 'suppresses archive writes under WhatIf' {
                & $Command @Extra -archived $true -Session $script:archiveSession -WhatIf
                $script:archiveCalls.Count | Should -Be 0
            }

            It 'preserves the server rejection for <Reason> without retrying or changing flags' -ForEach @(
                @{ Reason = 'outstanding assignments'; Message = 'Cannot archive an item with outstanding assignments.'; Requestable = $false },
                @{ Reason = 'requestable conflict'; Message = 'An item cannot be requestable and archived.'; Requestable = $true }
            ) {
                $script:archiveResponse = [pscustomobject]@{ status = 'error'; messages = [pscustomobject]@{ archived = @($Message) }; payload = $null }
                $caught = $null
                try { & $Command @Extra -archived $true -requestable $Requestable -Session $script:archiveSession -Confirm:$false -ErrorAction Stop }
                catch { $caught = $_ }
                $caught | Should -Not -BeNullOrEmpty
                $caught.FullyQualifiedErrorId | Should -BeLike 'SnipeitApiError*'
                $caught.Exception.Message | Should -Match ([regex]::Escape($Message))
                $caught.TargetObject.messages.archived[0] | Should -Be $Message
                $script:archiveCalls.Count | Should -Be 1
                $body = $script:archiveCalls[0].Json | ConvertFrom-Json
                $body.archived | Should -BeTrue
                $body.requestable | Should -Be $Requestable
            }

            It 'keeps the last existing positional parameter unchanged' {
                $set = (Get-Command $Command -Module SnipeitPS).ParameterSets[0]
                ($set.Parameters | Where-Object Name -EQ $LastParameter).Position | Should -Be $LastPosition
            }
        }

        Context '<Command> archive collection filters' -ForEach @(
            @{ Command = 'Get-SnipeitAccessory'; Leaf = 'accessories' },
            @{ Command = 'Get-SnipeitComponent'; Leaf = 'components' },
            @{ Command = 'Get-SnipeitConsumable'; Leaf = 'consumables' }
        ) {
            BeforeEach {
                $script:archiveResponse = [pscustomobject]@{ total = 1; rows = @([pscustomobject]@{ id = 7; archived = $true; extra = 'kept' }) }
            }

            It 'sends the exact <Status> collection status and preserves raw row fields' -ForEach @(
                @{ Status = 'Archived'; Expected = 'Archived' }, @{ Status = 'Deleted'; Expected = 'Deleted' },
                @{ Status = 'archived'; Expected = 'Archived' }, @{ Status = 'deleted'; Expected = 'Deleted' }
            ) {
                $row = & $Command -status $Status -Session $script:archiveSession
                $script:archiveCalls.Count | Should -Be 1
                $script:archiveCalls[0].Uri | Should -Match "/api/v1/$Leaf\?"
                $script:archiveCalls[0].Uri | Should -MatchExactly "[?&]status=$Expected(&|$)"
                $script:archiveCalls[0].Uri | Should -Not -Match 'Session='
                $script:archiveCalls[0].Method | Should -Be 'GET'
                $row.archived | Should -BeTrue
                $row.extra | Should -Be 'kept'
            }

            It 'omits an unbound status instead of imposing an archive visibility policy' {
                & $Command -Session $script:archiveSession | Out-Null
                $script:archiveCalls[0].Uri | Should -Not -Match '[?&]status='
                $script:archiveCalls.Count | Should -Be 1
            }

            It 'rejects unknown status values before HTTP with a validation error' {
                $caught = $null
                try { & $Command -status Invented -Session $script:archiveSession }
                catch { $caught = $_ }
                $caught.FullyQualifiedErrorId | Should -BeLike 'ParameterArgumentValidationError*'
                $script:archiveCalls.Count | Should -Be 0
            }

            It 'rejects a status filter on an ID lookup rather than silently ignoring it' {
                $caught = $null
                try { & $Command -id 7 -status Archived -Session $script:archiveSession }
                catch { $caught = $_ }
                $caught.FullyQualifiedErrorId | Should -BeLike 'AmbiguousParameterSet*'
                $script:archiveCalls.Count | Should -Be 0
            }

            It 'retains status across all pagination requests' {
                Mock Invoke-RestMethod {
                    param($Uri, $Method)
                    $script:archiveCalls.Add([pscustomobject]@{ Uri = ([uri]$Uri).AbsoluteUri; Method = [string]$Method })
                    $rowId = if (([uri]$Uri).Query -match '[?&]offset=1(&|$)') { 8 } else { 7 }
                    [pscustomobject]@{ total = 2; rows = @([pscustomobject]@{ id = $rowId; archived = $true }) }
                }
                $rows = @(& $Command -status Deleted -all -limit 1 -Session $script:archiveSession)
                $rows.Count | Should -Be 2
                $rows.id | Should -Be @(7, 8)
                $script:archiveCalls.Count | Should -Be 2
                foreach ($call in $script:archiveCalls) {
                    $call.Uri | Should -Match '[?&]status=Deleted(&|$)'
                    $call.Uri | Should -Not -Match '[?&]all='
                }
            }
        }

        Context 'Consumable boolean filters' -ForEach @(
            @{ Field = 'requestable' }, @{ Field = 'archived' }
        ) {
            It 'serializes true and false literally in the query' {
                foreach ($value in @($true, $false)) {
                    $arguments = @{ $Field = $value }
                    Get-SnipeitConsumable @arguments -Session $script:archiveSession | Out-Null
                    $script:archiveCalls[$script:archiveCalls.Count - 1].Uri | Should -Match "[?&]$Field=$($value.ToString().ToLowerInvariant())(&|$)"
                }
                $script:archiveCalls.Count | Should -Be 2
            }

            It 'omits the filter when unbound' {
                Get-SnipeitConsumable -Session $script:archiveSession | Out-Null
                $script:archiveCalls[0].Uri | Should -Not -Match "[?&]$Field="
            }

            It 'rejects collection flags on an ID lookup' {
                $arguments = @{ $Field = $true }
                $caught = $null
                try { Get-SnipeitConsumable -id 7 @arguments -Session $script:archiveSession }
                catch { $caught = $_ }
                $caught.FullyQualifiedErrorId | Should -BeLike 'AmbiguousParameterSet*'
                $script:archiveCalls.Count | Should -Be 0
            }

            It 'retains the flag and explicit archive scope across pagination requests' {
                Mock Invoke-RestMethod {
                    param($Uri, $Method)
                    $script:archiveCalls.Add([pscustomobject]@{ Uri = ([uri]$Uri).AbsoluteUri; Method = [string]$Method })
                    $rowId = if (([uri]$Uri).Query -match '[?&]offset=1(&|$)') { 8 } else { 7 }
                    [pscustomobject]@{ total = 2; rows = @([pscustomobject]@{ id = $rowId }) }
                }
                $arguments = @{ $Field = $true }
                $rows = @(Get-SnipeitConsumable @arguments -status Archived -all -limit 1 -Session $script:archiveSession)
                $rows.id | Should -Be @(7, 8)
                $script:archiveCalls.Count | Should -Be 2
                foreach ($call in $script:archiveCalls) {
                    $call.Uri | Should -Match "[?&]$Field=true(&|$)"
                    $call.Uri | Should -Match '[?&]status=Archived(&|$)'
                }
            }
        }
    }
}
