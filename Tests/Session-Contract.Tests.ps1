BeforeAll {
    Import-Module "$PSScriptRoot\..\SnipeitPS\SnipeitPS.psd1" -Force
}

Describe 'Typed session contract' {
    BeforeAll {
        $excludedCommands = @(
            'Set-SnipeitInfo',
            'Update-SnipeitAlias',
            'Connect-SnipeitPS',
            'Clear-SnipeitCache'
        )
        $networkingCommands = @(Get-Command -Module SnipeitPS -CommandType Function |
            Where-Object Name -notin $excludedCommands)
    }

    It 'exposes an optional typed Session parameter on all networking commands' {
        $networkingCommands.Count | Should -BeGreaterOrEqual 125

        foreach ($command in $networkingCommands) {
            $parameter = $command.Parameters['Session']
            $parameter | Should -Not -BeNullOrEmpty -Because $command.Name
            $parameter.ParameterType | Should -Be ([SnipeitSession]) -Because $command.Name
            $parameter.Attributes.Mandatory | Should -Not -Contain $true -Because $command.Name
        }
    }

    It 'does not expose object-typed public Session parameters' {
        foreach ($command in $networkingCommands) {
            $command.Parameters['Session'].ParameterType.FullName | Should -Not -Be 'System.Object' -Because $command.Name
        }
    }

    Context 'custom-session routing' {
        BeforeEach {
            $session = [SnipeitSession]::new('https://custom.example.test', (& {
                $secureString = [System.Security.SecureString]::new()
                foreach ($character in 'test-token'.ToCharArray()) {
                    $secureString.AppendChar($character)
                }
                $secureString.MakeReadOnly()
                $secureString
            }))
        }

        It 'passes a custom session through GET operations' {
            $capturedSession = InModuleScope SnipeitPS -Parameters @{ TestSession = $session } {
                Mock Invoke-SnipeitMethod { $Session }
                Get-SnipeitAccessory -search keyboard -Session $TestSession
            }
            [object]::ReferenceEquals($capturedSession, $session) | Should -BeTrue
        }

        It 'does not serialize Session into explicitly filtered query parameters' {
            $capture = [pscustomobject]@{ GetParameters = $null; Session = $null }
            InModuleScope SnipeitPS -Parameters @{ TestSession = $session; TestCapture = $capture } {
                Mock Invoke-SnipeitMethod {
                    $TestCapture.GetParameters = $GetParameters
                    $TestCapture.Session = $Session
                }
                Get-SnipeitAuditDue -Session $TestSession
            }

            $capture.GetParameters.ContainsKey('Session') | Should -BeFalse
            [object]::ReferenceEquals($capture.Session, $session) | Should -BeTrue
        }

        It 'does not serialize Session into explicitly filtered upload bodies' {
            $testFile = Join-Path $TestDrive 'asset-file.txt'
            Set-Content -Path $testFile -Value 'test'
            $capture = [pscustomobject]@{ Body = $null; Session = $null }
            InModuleScope SnipeitPS -Parameters @{
                TestSession = $session
                TestFile = $testFile
                TestCapture = $capture
            } {
                Mock Invoke-SnipeitMethod {
                    $TestCapture.Body = $Body
                    $TestCapture.Session = $Session
                }
                New-SnipeitAssetFile -id 1 -file $TestFile -Session $TestSession -Confirm:$false
            }

            $capture.Body.ContainsKey('Session') | Should -BeFalse
            [object]::ReferenceEquals($capture.Session, $session) | Should -BeTrue
        }

        It 'passes a custom session through mutation operations' {
            $capturedSession = InModuleScope SnipeitPS -Parameters @{ TestSession = $session } {
                Mock Invoke-SnipeitMethod { $Session }
                New-SnipeitCategory -name Laptops -category_type asset -Session $TestSession
            }
            [object]::ReferenceEquals($capturedSession, $session) | Should -BeTrue
        }

        It 'passes a custom session through each bulk deletion request' {
            $results = InModuleScope SnipeitPS -Parameters @{ TestSession = $session } {
                Mock Invoke-SnipeitMethod { [pscustomobject]@{ status = 'success'; messages = 'Deleted'; payload = $null } }
                Remove-SnipeitAssetBulk -Ids @(1, 2) -Session $TestSession -Confirm:$false
                Should -Invoke Invoke-SnipeitMethod -Times 2 -Exactly -ParameterFilter {
                    [object]::ReferenceEquals($Session, $TestSession) -and $Method -eq 'DELETE'
                }
            }
            $results.Count | Should -Be 2
            $results.id | Should -Be @(1,2)
        }

        It 'uses a custom session for backup downloads' {
            $tempPath = Join-Path $TestDrive 'backups'
            New-Item -Path $tempPath -ItemType Directory | Out-Null
            $capture = [pscustomobject]@{ Uri = $null }
            InModuleScope SnipeitPS -Parameters @{ TestSession = $session; TestPath = $tempPath; TestCapture = $capture } {
                Mock Invoke-WebRequest {
                    $TestCapture.Uri = $Uri
                    [IO.File]::WriteAllBytes($OutFile, [byte[]]@(0, 128, 255))
                }
                Save-SnipeitBackup -filename backup.sql -path $TestPath -Session $TestSession -Confirm:$false | Out-Null
            }
            $capture.Uri | Should -Be 'https://custom.example.test/api/v1/settings/backups/download/backup.sql'
        }
    }

    It 'clears every mutable SnipeitSession property to its initial default' {
        $session = [SnipeitSession]::new('https://custom.example.test', (& {
            $secureString = [System.Security.SecureString]::new()
            foreach ($character in 'test-token'.ToCharArray()) {
                $secureString.AppendChar($character)
            }
            $secureString.MakeReadOnly()
            $secureString
        }))
        $session.ThrottleLimit = 10
        $session.ThrottleThreshold = 80
        $session.ThrottleMode = 'Sleep'
        $session.ThrottlePeriod = 1000
        $session.LastRequestFileTime = 12345
        $session.ThrottledRequests = $null

        { $session.Clear() } | Should -Not -Throw

        $session.Url | Should -BeNullOrEmpty
        $session.ApiKey | Should -BeNullOrEmpty
        $session.ThrottleLimit | Should -Be 0
        $session.ThrottleThreshold | Should -Be 90
        $session.ThrottleMode | Should -Be 'Burst'
        $session.ThrottlePeriod | Should -Be 60000
        $session.LastRequestFileTime | Should -Be 0
        ($session.ThrottledRequests -is [System.Collections.Generic.Queue[long]]) | Should -BeTrue
        $session.ThrottledRequests.Count | Should -Be 0
    }
}
