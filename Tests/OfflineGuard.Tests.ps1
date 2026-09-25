BeforeDiscovery {
    Import-Module "$PSScriptRoot/../SnipeitPS/SnipeitPS.psd1" -Force
}

Describe 'Offline Process Guards and Seams' {
    BeforeAll {
        # Ensure offline guards are installed for the test suite
        foreach ($cmdletName in @('Invoke-RestMethod', 'Invoke-WebRequest')) {
            $cmd = Get-Command -Name "Microsoft.PowerShell.Utility\$cmdletName" -CommandType Cmdlet -ErrorAction SilentlyContinue
            if ($null -ne $cmd) {
                $meta = New-Object System.Management.Automation.CommandMetadata $cmd
                $paramBlock = [System.Management.Automation.ProxyCommand]::GetParamBlock($meta)
                $funcDef = @"
function global:$cmdletName {
    [CmdletBinding()]
    param(
$paramBlock
    )
    process {
        throw [System.InvalidOperationException]::new('LIVE NETWORK BLOCKED: Unmocked network call to $cmdletName')
    }
}
"@
                $sb = [scriptblock]::Create($funcDef)
                & $sb
            }
        }
    }

    Context 'Proxy Command Parameter Metadata' {
        It 'Invoke-RestMethod guard retains real command parameter metadata' {
            $cmd = Get-Command -Name 'Invoke-RestMethod' -CommandType Function
            $cmd | Should -Not -BeNullOrEmpty
            $cmd.Parameters.ContainsKey('Uri') | Should -BeTrue
            $cmd.Parameters.ContainsKey('Method') | Should -BeTrue
            $cmd.Parameters.ContainsKey('Headers') | Should -BeTrue
        }

        It 'Invoke-WebRequest guard retains real command parameter metadata' {
            $cmd = Get-Command -Name 'Invoke-WebRequest' -CommandType Function
            $cmd | Should -Not -BeNullOrEmpty
            $cmd.Parameters.ContainsKey('Uri') | Should -BeTrue
            $cmd.Parameters.ContainsKey('Method') | Should -BeTrue
            $cmd.Parameters.ContainsKey('Headers') | Should -BeTrue
        }
    }

    Context 'Direct Guard Invocations Fail Closed' {
        It 'Direct Invoke-RestMethod throws LIVE NETWORK BLOCKED' {
            { Invoke-RestMethod -Uri 'https://snipeit.invalid/api/v1/test' } |
                Should -Throw -ExpectedMessage '*LIVE NETWORK BLOCKED: Unmocked network call to Invoke-RestMethod*'
        }

        It 'Direct Invoke-WebRequest throws LIVE NETWORK BLOCKED' {
            { Invoke-WebRequest -Uri 'https://snipeit.invalid/api/v1/test' } |
                Should -Throw -ExpectedMessage '*LIVE NETWORK BLOCKED: Unmocked network call to Invoke-WebRequest*'
        }
    }

    Context 'Dispatcher Unmocked Request Fails Closed' {
        InModuleScope SnipeitPS {
            BeforeEach {
                $script:SnipeitPSSession.url = 'https://contract.invalid'
                $script:SnipeitPSSession.apiKey = 'test-only-key'
                $script:SnipeitPSSession.throttleLimit = 0
            }

            It 'Invoke-SnipeitMethod fails closed with LIVE NETWORK BLOCKED when unmocked' {
                { Invoke-SnipeitMethod -Api 'unmocked-path' -Method 'GET' -ErrorAction Stop } |
                    Should -Throw -ExpectedMessage '*LIVE NETWORK BLOCKED*'
            }

            It 'Pester Mock takes precedence over global guard when active' {
                Mock Invoke-RestMethod {
                    return [pscustomobject]@{
                        status = 'success'
                        messages = 'Mocked response'
                        payload = [pscustomobject]@{ id = 42 }
                    }
                }

                $res = Invoke-SnipeitMethod -Api 'mocked-path' -Method 'GET'
                $res | Should -Not -BeNullOrEmpty
                $res.id | Should -Be 42
            }
        }
    }
}
