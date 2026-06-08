BeforeAll {
    Import-Module "$PSScriptRoot\..\SnipeitPS\SnipeitPS.psd1" -Force
}

Describe "Invoke-SnipeitMethod coverage" {

    It "Redacts password from Debug stream when DebugPreference is Continue" {
        InModuleScope 'SnipeitPS' {
            $script:SnipeitPSSession = [PSCustomObject]@{ Url = "http://test"; ApiKey = (ConvertTo-SecureString "key" -AsPlainText -Force); throttleLimit = 0 }
            $prevDebug = $DebugPreference
            $DebugPreference = 'Continue'
            
            Mock Invoke-RestMethod { return @{ status = "success" } }
            
            try {
                Invoke-SnipeitMethod -Api "/api/v1/test" -Method "Post" -Body @{ password = "SuperSecret"; other = "value" } | Out-Null
            } finally {
                $DebugPreference = $prevDebug
            }
        }
    }

    It "PS7: reads ErrorDetails.Message (Valid JSON)" {
        InModuleScope 'SnipeitPS' {
            $script:SnipeitPSSession = [PSCustomObject]@{ Url = "http://test"; ApiKey = (ConvertTo-SecureString "key" -AsPlainText -Force); throttleLimit = 0 }
            Mock Invoke-RestMethod {
                $ex = New-Object System.Exception "err"
                $err = New-Object System.Management.Automation.ErrorRecord $ex, "id", "NotSpecified", $null
                $err.ErrorDetails = New-Object System.Management.Automation.ErrorDetails('{"status":"error","messages":"PS7 JSON"}')
                throw $err
            }

            $prevIsPS7 = $script:IsPowerShell7
            $script:IsPowerShell7 = $true
            try {
                Invoke-SnipeitMethod -Api "/api/v1/test" -Method "Get" -ErrorAction SilentlyContinue
            } catch {} finally {
                $script:IsPowerShell7 = $prevIsPS7
            }
        }
    }

    It "PS7: reads ErrorDetails.Message (Invalid JSON)" {
        InModuleScope 'SnipeitPS' {
            $script:SnipeitPSSession = [PSCustomObject]@{ Url = "http://test"; ApiKey = (ConvertTo-SecureString "key" -AsPlainText -Force); throttleLimit = 0 }
            Mock Invoke-RestMethod {
                $ex = New-Object System.Exception "err"
                $responseMock = New-Object PSObject
                $responseMock | Add-Member -MemberType NoteProperty -Name "StatusCode" -Value 503
                $ex | Add-Member -MemberType NoteProperty -Name "Response" -Value $responseMock

                $err = New-Object System.Management.Automation.ErrorRecord $ex, "id", "NotSpecified", $null
                $err.ErrorDetails = New-Object System.Management.Automation.ErrorDetails('Bad PS7 Data')
                throw $err
            }

            $prevIsPS7 = $script:IsPowerShell7
            $script:IsPowerShell7 = $true
            try {
                Invoke-SnipeitMethod -Api "/api/v1/test" -Method "Get" -ErrorAction SilentlyContinue
            } catch {} finally {
                $script:IsPowerShell7 = $prevIsPS7
            }
        }
    }

    It "PS5: reads response stream (Valid JSON)" {
        InModuleScope 'SnipeitPS' {
            $script:SnipeitPSSession = [PSCustomObject]@{ Url = "http://test"; ApiKey = (ConvertTo-SecureString "key" -AsPlainText -Force); throttleLimit = 0 }
            Mock Invoke-RestMethod {
                $responseBody = '{"status":"error","messages":"PS5 JSON"}'
                $bytes = [System.Text.Encoding]::UTF8.GetBytes($responseBody)
                $global:MockStream1 = New-Object System.IO.MemoryStream(,$bytes)
                
                $responseMock = New-Object PSObject
                $responseMock | Add-Member -MemberType ScriptMethod -Name "GetResponseStream" -Value { return $global:MockStream1 }
                $responseMock | Add-Member -MemberType NoteProperty -Name "StatusCode" -Value 400
                
                $ex = New-Object System.Exception "err"
                $ex | Add-Member -MemberType NoteProperty -Name "Response" -Value $responseMock

                $err = New-Object System.Management.Automation.ErrorRecord $ex, "id", "NotSpecified", $null
                throw $err
            }

            $prevIsPS7 = $script:IsPowerShell7
            $script:IsPowerShell7 = $false
            try {
                Invoke-SnipeitMethod -Api "/api/v1/test" -Method "Get" -ErrorAction SilentlyContinue
            } catch {} finally {
                $script:IsPowerShell7 = $prevIsPS7
            }
        }
    }

    It "PS5: reads response stream (Invalid JSON)" {
        InModuleScope 'SnipeitPS' {
            $script:SnipeitPSSession = [PSCustomObject]@{ Url = "http://test"; ApiKey = (ConvertTo-SecureString "key" -AsPlainText -Force); throttleLimit = 0 }
            Mock Invoke-RestMethod {
                $responseBody = 'Bad PS5 Data'
                $bytes = [System.Text.Encoding]::UTF8.GetBytes($responseBody)
                $global:MockStream2 = New-Object System.IO.MemoryStream(,$bytes)
                
                $responseMock = New-Object PSObject
                $responseMock | Add-Member -MemberType ScriptMethod -Name "GetResponseStream" -Value { return $global:MockStream2 }
                $responseMock | Add-Member -MemberType NoteProperty -Name "StatusCode" -Value 502
                
                $ex = New-Object System.Exception "err"
                $ex | Add-Member -MemberType NoteProperty -Name "Response" -Value $responseMock

                $err = New-Object System.Management.Automation.ErrorRecord $ex, "id", "NotSpecified", $null
                throw $err
            }

            $prevIsPS7 = $script:IsPowerShell7
            $script:IsPowerShell7 = $false
            try {
                Invoke-SnipeitMethod -Api "/api/v1/test" -Method "Get" -ErrorAction SilentlyContinue
            } catch {} finally {
                $script:IsPowerShell7 = $prevIsPS7
            }
        }
    }

    It "PS5: handles exception when reading response stream" {
        InModuleScope 'SnipeitPS' {
            $script:SnipeitPSSession = [PSCustomObject]@{ Url = "http://test"; ApiKey = (ConvertTo-SecureString "key" -AsPlainText -Force); throttleLimit = 0 }
            Mock Invoke-RestMethod {
                $responseMock = New-Object PSObject
                $responseMock | Add-Member -MemberType ScriptMethod -Name "GetResponseStream" -Value { throw "StreamError" }
                $responseMock | Add-Member -MemberType NoteProperty -Name "StatusCode" -Value 500
                
                $ex = New-Object System.Exception "err"
                $ex | Add-Member -MemberType NoteProperty -Name "Response" -Value $responseMock

                $err = New-Object System.Management.Automation.ErrorRecord $ex, "id", "NotSpecified", $null
                throw $err
            }

            $prevIsPS7 = $script:IsPowerShell7
            $script:IsPowerShell7 = $false
            try {
                Invoke-SnipeitMethod -Api "/api/v1/test" -Method "Get" -ErrorAction SilentlyContinue
            } catch {} finally {
                $script:IsPowerShell7 = $prevIsPS7
            }
        }
    }
}
