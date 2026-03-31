BeforeAll {
    Import-Module "$PSScriptRoot\..\SnipeitPS\SnipeitPS.psd1" -Force
}

# ============================================================
# Fix 1: API key redacted from Write-Debug output
# ============================================================

Describe "Invoke-SnipeitMethod debug output" {
    It "Does not contain Authorization header value in debug parameters" {
        InModuleScope 'SnipeitPS' {
            # The Write-Debug line in Invoke-SnipeitMethod should use [REDACTED]
            $funcBody = (Get-Command Invoke-SnipeitMethod).ScriptBlock.ToString()
            $funcBody | Should -Match '\[REDACTED\]'
            $funcBody | Should -Not -Match 'Write-Debug.*\$splatParameters \| Out-String'
        }
    }
}

Describe "Connect-SnipeitPS debug output" {
    It "Does not leak apiKey in Write-Debug" {
        InModuleScope 'SnipeitPS' {
            $funcBody = (Get-Command Connect-SnipeitPS).ScriptBlock.ToString()
            $funcBody | Should -Not -Match 'Write-Debug.*\$\(.*apiKey\)'
            $funcBody | Should -Match 'apikey: \[REDACTED\]'
        }
    }
}

# ============================================================
# Fix 2: ConfirmImpact = "High" on all Remove-* functions
# ============================================================

Describe "Remove-* functions ConfirmImpact" {
    BeforeAll {
        $removeCommands = Get-Command -Module SnipeitPS -Name 'Remove-Snipeit*'
    }

    It "All Remove-* functions have ConfirmImpact = High" {
        foreach ($cmd in $removeCommands) {
            $attr = $cmd.ScriptBlock.Attributes | Where-Object { $_ -is [System.Management.Automation.CmdletBindingAttribute] }
            $attr.ConfirmImpact | Should -Be 'High' -Because "$($cmd.Name) should have ConfirmImpact = High for destructive operations"
        }
    }

    It "Has at least 20 Remove-* functions" {
        $removeCommands.Count | Should -BeGreaterOrEqual 20
    }
}

# ============================================================
# Fix 3: Get-SnipeitFieldsetField uses GET not POST
# ============================================================

Describe "Get-SnipeitFieldsetField HTTP method" {
    BeforeAll {
        InModuleScope 'SnipeitPS' {
            Mock Invoke-SnipeitMethod { return $null }
        }
    }

    It "Uses GET method, not POST" {
        InModuleScope 'SnipeitPS' {
            Get-SnipeitFieldsetField -id 1
            Should -Invoke Invoke-SnipeitMethod -Times 1 -ParameterFilter {
                $Method -eq "Get"
            }
        }
    }

    It "Does not send a Body parameter" {
        InModuleScope 'SnipeitPS' {
            Get-SnipeitFieldsetField -id 1
            Should -Invoke Invoke-SnipeitMethod -Times 1 -ParameterFilter {
                $null -eq $Body
            }
        }
    }
}

# ============================================================
# Fix 4: Get-SnipeitAsset -requestable is [switch], not [bool]
# ============================================================

Describe "Get-SnipeitAsset requestable parameter" {
    It "Parameter -requestable is a switch, not bool" {
        $param = (Get-Command Get-SnipeitAsset).Parameters['requestable']
        $param.ParameterType.Name | Should -Be 'SwitchParameter'
    }
}

# ============================================================
# Fix 5: Get-SnipeitUser -id is [int], not [string]
# ============================================================

Describe "Get-SnipeitUser parameter types" {
    It "Parameter -id is Int32" {
        $param = (Get-Command Get-SnipeitUser).Parameters['id']
        $param.ParameterType.Name | Should -Be 'Int32'
    }

    It "Parameter -accessory_id is Int32" {
        $param = (Get-Command Get-SnipeitUser).Parameters['accessory_id']
        $param.ParameterType.Name | Should -Be 'Int32'
    }
}
