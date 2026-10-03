BeforeDiscovery {
    Import-Module "$PSScriptRoot/../SnipeitPS/SnipeitPS.psd1" -Force
}

Describe 'Current API endpoint commands' {
    InModuleScope SnipeitPS {
        BeforeEach {
            $script:endpointSession = [SnipeitSession]::new('https://endpoints.invalid', (ConvertTo-SecureString 'offline' -AsPlainText -Force))
            $script:endpointSession.ThrottleLimit = 0
            $script:endpointCalls = [Collections.Generic.List[object]]::new()
            $script:endpointEnvelope = [pscustomobject]@{ total = 1; rows = @([pscustomobject]@{ id = 31; name = 'Item'; extra = 'kept' }); next_page_url = $null }
            Mock Invoke-RestMethod {
                param($Uri, $Method, $Body)
                $script:endpointCalls.Add(@{ Uri = ([uri]$Uri).AbsoluteUri; Method = $Method; Body = $Body })
                $script:endpointEnvelope
            }
        }

        It 'Exports <Command>' -ForEach @(
            @{ Command = 'Get-SnipeitCheckoutRequest' }, @{ Command = 'Get-SnipeitRequestableItem' },
            @{ Command = 'Get-SnipeitDashboardActivity' }, @{ Command = 'Get-SnipeitDashboardSummary' },
            @{ Command = 'Get-SnipeitCalendarEvent' }, @{ Command = 'Get-SnipeitLowStockItem' },
            @{ Command = 'Get-SnipeitModelAsset' }, @{ Command = 'Restore-SnipeitModel' },
            @{ Command = 'Get-SnipeitUserConsumable' }, @{ Command = 'Revoke-SnipeitCurrentToken' }
        ) {
            Get-Command $Command -Module SnipeitPS -ErrorAction Stop | Should -Not -BeNullOrEmpty
        }

        It 'Routes requestable <Type> without an ambiguous asset ID' -ForEach @(
            @{ Type = 'Model'; Leaf = 'models'; Key = 'model_id' },
            @{ Type = 'Accessory'; Leaf = 'accessories'; Key = 'accessory_id' },
            @{ Type = 'Consumable'; Leaf = 'consumables'; Key = 'consumable_id' },
            @{ Type = 'Component'; Leaf = 'components'; Key = 'component_id' },
            @{ Type = 'License'; Leaf = 'licenses'; Key = 'license_id' }
        ) {
            $row = Get-SnipeitRequestableItem -Type $Type -search 'a & b' -Session $script:endpointSession
            $script:endpointCalls[0].Uri | Should -Match "/api/v1/account/requestable/$Leaf\?"
            $script:endpointCalls[0].Uri | Should -Match 'search=a\+%26\+b'
            $script:endpointCalls[0].Uri | Should -Match 'limit=50'
            $script:endpointCalls[0].Uri | Should -Match 'offset=0'
            $row.$Key | Should -Be 31
            $row.PSObject.Properties.Name | Should -Not -Contain 'id'
            $row.extra | Should -Be 'kept'
            $script:endpointEnvelope.rows[0].id | Should -Be 31
            $raw = Get-SnipeitRequestableItem -Type $Type -PreserveResponse -Session $script:endpointSession
            $raw.rows[0].id | Should -Be 31
            $raw.PSObject.Properties.Name | Should -Contain 'next_page_url'
        }

        It 'Rejects remaining sort for non-model requestables' {
            { Get-SnipeitRequestableItem -Type Accessory -sort remaining -Session $script:endpointSession } | Should -Throw
            $script:endpointCalls.Count | Should -Be 0
            Get-SnipeitRequestableItem -Type Model -sort remaining -Session $script:endpointSession
            $script:endpointCalls[0].Uri | Should -Match 'sort=remaining'
        }

        It 'Lists pending admin requests with exact model type filters and safe request IDs' -ForEach @(
            @{ Type = 'Asset' }, @{ Type = 'AssetModel' }, @{ Type = 'Accessory' },
            @{ Type = 'Consumable' }, @{ Type = 'Component' }, @{ Type = 'License' }
        ) {
            $script:endpointEnvelope.rows = @([pscustomobject]@{ id = 91; requestable = $null; quantity = 1 })
            $row = Get-SnipeitCheckoutRequest -requestable_type $Type -user_id 7 -sort requestable.remaining -order asc -Session $script:endpointSession
            $script:endpointCalls[0].Uri | Should -Match '/api/v1/requests\?'
            [uri]::UnescapeDataString($script:endpointCalls[0].Uri) | Should -Match ([regex]::Escape("requestable_type=App\Models\$Type"))
            $row.request_id | Should -Be 91
            $row.PSObject.Properties.Name | Should -Not -Contain 'id'
            $row.requestable | Should -BeNullOrEmpty
        }

        It 'Keeps nested requestable IDs nested and raw request envelopes intact' {
            $script:endpointEnvelope.rows = @([pscustomobject]@{ id = 91; requestable = [pscustomobject]@{ id = 7; type = 'model' } })
            $row = Get-SnipeitCheckoutRequest -Session $script:endpointSession
            $row.request_id | Should -Be 91
            $row.requestable.id | Should -Be 7
            $raw = Get-SnipeitCheckoutRequest -PreserveResponse -all -Session $script:endpointSession
            $raw.rows[0].id | Should -Be 91
            $script:endpointCalls.Count | Should -Be 2
        }

        It 'Returns dedicated dashboard <By> summary rows without fabricated counts' -ForEach @(
            @{ By = 'Category'; Leaf = 'categories' }, @{ By = 'Company'; Leaf = 'companies' }, @{ By = 'Location'; Leaf = 'locations' }
        ) {
            $script:endpointEnvelope.rows = @([pscustomobject]@{ id = 31; name = 'Shelf'; tag_color = $null; assets_count = 0; assigned_assets_count = 4; available_actions = @{ view = $false } })
            $row = Get-SnipeitDashboardSummary -By $By -sort name -order asc -Session $script:endpointSession
            $script:endpointCalls[0].Uri | Should -Match "/api/v1/dashboard/$Leaf\?"
            $script:endpointCalls[0].Uri | Should -Match 'limit=25'
            $row.PSObject.TypeNames[0] | Should -Be "SnipeitPS.Dashboard${By}Summary"
            $row.PSObject.TypeNames | Should -Not -Contain "SnipeitPS.$By"
            $row.assets_count | Should -Be 0
            $row.assigned_assets_count | Should -Be 4
            $row.PSObject.Properties.Name | Should -Not -Contain 'users_count'
            $row.tag_color | Should -BeNullOrEmpty
            $row.available_actions.view | Should -BeFalse
            { Get-SnipeitDashboardSummary -By $By -search nope -Session $script:endpointSession } | Should -Throw
            $raw = Get-SnipeitDashboardSummary -By $By -PreserveResponse -Session $script:endpointSession
            $raw.rows[0].id | Should -Be 31
        }

        It 'Routes dashboard activity with only supported filters' {
            $row = Get-SnipeitDashboardActivity -search 'a & b' -Session $script:endpointSession
            $script:endpointCalls[0].Uri | Should -Match '/api/v1/dashboard/activity\?'
            $script:endpointCalls[0].Uri | Should -Match 'limit=25'
            $row.PSObject.TypeNames[0] | Should -Be 'SnipeitPS.Activity'
            foreach ($field in 'sort', 'order', 'days', 'action_type') {
                $parameters = @{ Session = $script:endpointSession; $field = '1' }
                { Get-SnipeitDashboardActivity @parameters } | Should -Throw
            }
        }

        It 'Routes model assets as assets and rejects ignored search filters' {
            $row = Get-SnipeitModelAsset -model_id 7 -Session $script:endpointSession
            $script:endpointCalls[0].Uri | Should -Match '/api/v1/models/7/assets\?'
            $row.PSObject.TypeNames[0] | Should -Be 'SnipeitPS.Asset'
            { Get-SnipeitModelAsset -model_id 7 -search nope -Session $script:endpointSession } | Should -Throw
        }

        It 'Normalizes user consumable assignment IDs without mutating the source' {
            $script:endpointEnvelope.rows = @([pscustomobject]@{ id = 91; consumable = [pscustomobject]@{ id = 7; name = 'Ink' }; note = 'kept'; purchase_cost = $null })
            $row = Get-SnipeitUserConsumable -user_id 2 -search note -sort name -Session $script:endpointSession
            $script:endpointCalls[0].Uri | Should -Match '/api/v1/users/2/consumables\?'
            $row.id | Should -Be 7
            $row.checkout_id | Should -Be 91
            $row.note | Should -Be 'kept'
            $row.PSObject.TypeNames[0] | Should -Be 'SnipeitPS.Consumable'
            $script:endpointEnvelope.rows[0].id | Should -Be 91
            $raw = Get-SnipeitUserConsumable -user_id 2 -PreserveResponse -Session $script:endpointSession
            $raw.rows[0].id | Should -Be 91
            $script:endpointEnvelope.rows[0].consumable.id = 0
            { Get-SnipeitUserConsumable -user_id 2 -Session $script:endpointSession -ErrorAction Stop } | Should -Throw '*valid consumable ID*'
        }

        It 'Preserves calendar metadata and emits typed events without pagination' {
            $script:endpointEnvelope = [pscustomobject]@{ total = 2; truncated = $true; events = @([pscustomobject]@{ id = 'event-31'; title = 'Due'; allDay = $true; extendedProps = @{ source_id = 7; source_type = 'App\Models\Asset' } }) }
            $event = Get-SnipeitCalendarEvent -start '2026-01-01T00:00:00Z' -end '2026-02-01T00:00:00Z' -event_type 'asset.audit_due','license.expiration' -limit 25 -Session $script:endpointSession
            $script:endpointCalls[0].Uri | Should -Match '/api/v1/calendar/events\?'
            [uri]::UnescapeDataString($script:endpointCalls[0].Uri) | Should -Match 'event_type=asset.audit_due,license.expiration'
            $event.id | Should -Be 'event-31'
            $event.PSObject.TypeNames[0] | Should -Be 'SnipeitPS.CalendarEvent'
            $event.extendedProps.source_id | Should -Be 7
            $raw = Get-SnipeitCalendarEvent -PreserveResponse -Session $script:endpointSession
            $raw.truncated | Should -BeTrue
            $raw.total | Should -Be 2
            { Get-SnipeitCalendarEvent -all -Session $script:endpointSession } | Should -Throw
            $script:endpointEnvelope.events = @()
            @(Get-SnipeitCalendarEvent -Session $script:endpointSession).Count | Should -Be 0
        }

        It 'Keeps low stock composite IDs and nested inventory IDs distinct' {
            $script:endpointEnvelope.rows = @([pscustomobject]@{ id = 'consumable-7'; item = @{ id = 7; type = 'consumable' }; remaining = 0; available_actions = @{ adjust_quantity = $false } })
            $row = Get-SnipeitLowStockItem -sort remaining -order asc -search Ink -Session $script:endpointSession
            $script:endpointCalls[0].Uri | Should -Match '/api/v1/low-stock\?'
            $row.id | Should -Be 'consumable-7'
            $row.item.id | Should -Be 7
            $row.PSObject.TypeNames[0] | Should -Be 'SnipeitPS.LowStockItem'
            $row.available_actions.adjust_quantity | Should -BeFalse
            { Get-SnipeitLowStockItem -threshold 2 -Session $script:endpointSession } | Should -Throw
        }

        It 'Streams <Command> pages using returned row count' -ForEach @(
            @{ Command = 'Get-SnipeitCheckoutRequest'; Extra = @{} },
            @{ Command = 'Get-SnipeitRequestableItem'; Extra = @{ Type = 'Model' } },
            @{ Command = 'Get-SnipeitDashboardActivity'; Extra = @{} },
            @{ Command = 'Get-SnipeitDashboardSummary'; Extra = @{ By = 'Location' } },
            @{ Command = 'Get-SnipeitModelAsset'; Extra = @{ model_id = 7 } },
            @{ Command = 'Get-SnipeitUserConsumable'; Extra = @{ user_id = 7 } },
            @{ Command = 'Get-SnipeitLowStockItem'; Extra = @{} }
        ) {
            Mock Invoke-RestMethod {
                param($Uri, $Method)
                $script:endpointCalls.Add(@{ Uri = [string]$Uri; Method = $Method })
                if ([string]$Uri -match 'offset=2') { [pscustomobject]@{ total = 3; rows = @([pscustomobject]@{ id = 3 }) } }
                else { [pscustomobject]@{ total = 3; rows = @([pscustomobject]@{ id = 1 }, [pscustomobject]@{ id = 2 }) } }
            }
            $rows = @(& $Command @Extra -all -limit 2 -Session $script:endpointSession)
            $rows.Count | Should -Be 3
            $script:endpointCalls.Count | Should -Be 2
            $script:endpointCalls[1].Uri | Should -Match 'offset=2'
            $script:endpointCalls[1].Uri | Should -Match 'limit=2'
            $rows[2].PSObject.TypeNames[0] | Should -Match '^SnipeitPS\.'
        }

        It 'Guards <Command> pagination before transport' -ForEach @(
            @{ Command = 'Get-SnipeitCheckoutRequest'; Extra = @{}; Ceiling = 500 },
            @{ Command = 'Get-SnipeitRequestableItem'; Extra = @{ Type = 'Model' }; Ceiling = 500 },
            @{ Command = 'Get-SnipeitDashboardActivity'; Extra = @{}; Ceiling = 500 },
            @{ Command = 'Get-SnipeitDashboardSummary'; Extra = @{ By = 'Location' }; Ceiling = 50 },
            @{ Command = 'Get-SnipeitModelAsset'; Extra = @{ model_id = 7 }; Ceiling = 500 },
            @{ Command = 'Get-SnipeitUserConsumable'; Extra = @{ user_id = 7 }; Ceiling = 500 },
            @{ Command = 'Get-SnipeitLowStockItem'; Extra = @{}; Ceiling = 500 }
        ) {
            { & $Command @Extra -limit 0 -Session $script:endpointSession } | Should -Throw
            { & $Command @Extra -limit ($Ceiling + 1) -Session $script:endpointSession } | Should -Throw
            { & $Command @Extra -offset -1 -Session $script:endpointSession } | Should -Throw
            $script:endpointCalls.Count | Should -Be 0
        }

        It 'Restores each model with ShouldProcess and an empty body' {
            $script:endpointEnvelope = [pscustomobject]@{ status = 'success'; payload = $null; messages = 'Restored' }
            Restore-SnipeitModel -id 7,8 -Session $script:endpointSession -WhatIf
            $script:endpointCalls.Count | Should -Be 0
            [pscustomobject]@{ id = 7 } | Restore-SnipeitModel -Session $script:endpointSession -Confirm:$false
            Restore-SnipeitModel -id 8 -Session $script:endpointSession -Confirm:$false
            $script:endpointCalls.Count | Should -Be 2
            $script:endpointCalls[0].Uri | Should -BeExactly 'https://endpoints.invalid/api/v1/models/7/restore'
            $script:endpointCalls[1].Uri | Should -BeExactly 'https://endpoints.invalid/api/v1/models/8/restore'
            $script:endpointCalls[0].Method | Should -Be 'Post'
            [Text.Encoding]::UTF8.GetString($script:endpointCalls[0].Body) | Should -Be '{}'
            { Restore-SnipeitModel -id 0 -Session $script:endpointSession -Confirm:$false } | Should -Throw
        }

        It 'Does not turn restore domain failures into successful rows' {
            $script:endpointEnvelope = [pscustomobject]@{ status = 'error'; payload = $null; messages = 'Not deleted' }
            { Restore-SnipeitModel -id 7 -Session $script:endpointSession -Confirm:$false -ErrorAction Stop } | Should -Throw '*Not deleted*'
        }

        It 'Propagates empty unauthorized token revocation and <Code> endpoint errors' -ForEach @(
            @{ Code = 401; Command = 'Revoke-SnipeitCurrentToken'; Extra = @{ Confirm = $false } },
            @{ Code = 403; Command = 'Get-SnipeitDashboardActivity'; Extra = @{} },
            @{ Code = 404; Command = 'Get-SnipeitModelAsset'; Extra = @{ model_id = 7 } },
            @{ Code = 409; Command = 'Get-SnipeitCheckoutRequest'; Extra = @{} }
        ) {
            Mock Invoke-RestMethod {
                $exception = [Exception]::new("HTTP $Code")
                $exception | Add-Member NoteProperty Response ([pscustomobject]@{ StatusCode = $Code })
                throw [Management.Automation.ErrorRecord]::new($exception, 'OfflineHttpError', [Management.Automation.ErrorCategory]::InvalidOperation, $null)
            }
            { & $Command @Extra -Session $script:endpointSession -ErrorAction Stop } | Should -Throw
            Should -Invoke Invoke-RestMethod -Times 1 -Exactly
        }

        It 'Rejects model and accessory requestable rows in asset request pipelines' -ForEach @(
            @{ Type = 'Model' }, @{ Type = 'Accessory' }
        ) {
            $row = Get-SnipeitRequestableItem -Type $Type -Session $script:endpointSession
            $script:endpointCalls.Clear()
            $errors = @($row | New-SnipeitAccountRequest -Session $script:endpointSession -Confirm:$false -ErrorAction Continue 2>&1)
            $errors.Count | Should -Be 1
            $errors[0].FullyQualifiedErrorId | Should -BeExactly 'InputObjectNotBound,New-SnipeitAccountRequest'
            $script:endpointCalls.Count | Should -Be 0
        }

        It 'Requests <Type> inventory directly from normalized requestable rows' -ForEach @(
            @{ Type = 'Consumable'; Leaf = 'consumable' }, @{ Type = 'Component'; Leaf = 'component' }, @{ Type = 'License'; Leaf = 'license' }
        ) {
            $row = Get-SnipeitRequestableItem -Type $Type -Session $script:endpointSession
            $script:endpointEnvelope = [pscustomobject]@{ status = 'success'; payload = $null; messages = 'Saved' }
            $row | New-SnipeitAccountRequest -Session $script:endpointSession -Confirm:$false
            $script:endpointCalls[1].Uri | Should -BeExactly "https://endpoints.invalid/api/v1/account/request/$Leaf/31"
        }

        It 'Revokes only the current bearer token explicitly and accepts empty success' {
            $script:endpointEnvelope = $null
            Revoke-SnipeitCurrentToken -Session $script:endpointSession -WhatIf
            $script:endpointCalls.Count | Should -Be 0
            @(Revoke-SnipeitCurrentToken -Session $script:endpointSession -Confirm:$false).Count | Should -Be 0
            $script:endpointCalls[0].Uri | Should -BeExactly 'https://endpoints.invalid/api/v1/logout'
            $script:endpointCalls[0].Method | Should -Be 'Post'
            [Text.Encoding]::UTF8.GetString($script:endpointCalls[0].Body) | Should -Be '{}'
            (Get-Command Revoke-SnipeitCurrentToken).ScriptBlock.Attributes.ConfirmImpact | Should -Contain 'High'
        }
    }
}
