Describe "Phase 1 security and CI controls" {
    BeforeAll {
        $repositoryRoot = Split-Path -Parent $PSScriptRoot
        $integrationFiles = @(
            Join-Path $repositoryRoot "run-integration-tests.ps1"
            Get-ChildItem (Join-Path $repositoryRoot "Tests/Integration") -Filter "*.Integration.Tests.ps1" -File |
                Select-Object -ExpandProperty FullName
        )
        $ciFile = Join-Path $repositoryRoot ".gitlab-ci.yml"
    }

    It "does not contain credential fallbacks in integration test files" {
        foreach ($file in $integrationFiles) {
            $content = Get-Content -LiteralPath $file -Raw
            (($content -match '\?\?') -or ($content -match 'eyJ[a-zA-Z0-9_-]{20,}')) | Should -BeFalse
        }
    }

    It "requires integration credentials without exposing them" {
        foreach ($file in $integrationFiles) {
            $content = Get-Content -LiteralPath $file -Raw
            ($content -match 'SNIPEIT_TEST_URL') | Should -BeTrue
            ($content -match 'SNIPEIT_TEST_KEY') | Should -BeTrue
            ($content -match 'require SNIPEIT_TEST_URL and SNIPEIT_TEST_KEY') | Should -BeTrue
        }
    }

    It "does not disable TLS certificate validation in CI" {
        ((Get-Content -LiteralPath $ciFile -Raw) -match 'GIT_SSL_NO_VERIFY') | Should -BeFalse
    }

    It "uses repository test entry points in CI" {
        $content = Get-Content -LiteralPath $ciFile -Raw
        ($content -match 'build\.ps1') | Should -BeFalse
        ($content -match 'run-tests\.ps1') | Should -BeTrue
    }

    It "logs only the safe URL components in the integration runner" {
        $runner = Join-Path $repositoryRoot "run-integration-tests.ps1"
        $tempDirectory = Join-Path ([System.IO.Path]::GetTempPath()) ("snipeit-runner-test-" + [Guid]::NewGuid().ToString())
        New-Item -ItemType Directory -Path $tempDirectory -Force | Out-Null
        $fixture = Join-Path $tempDirectory "runner.Tests.ps1"
        @'
Describe "runner fixture" -Tag "Integration" {
    It "passes" { $true | Should -BeTrue }
}
'@ | Set-Content -LiteralPath $fixture

        try {
            $engine = if (Test-Path (Join-Path $PSHOME "pwsh.exe")) {
                Join-Path $PSHOME "pwsh.exe"
            } else {
                Join-Path $PSHOME "powershell.exe"
            }
            $output = & $engine -NoProfile -File $runner `
                -URL "https://user:password@example.test:8443/private/path?token=secret#fragment" `
                -ApiKey "test-key" -Path $fixture 2>&1 | Out-String
        } finally {
            Remove-Item -LiteralPath $tempDirectory -Recurse -Force -ErrorAction SilentlyContinue
        }

        $output | Should -Match "Targeting live Snipe-IT instance at https://example.test:8443/private/path"
        $output | Should -Not -Match "https://user:password@"
        $output | Should -Not -Match "\?token=secret"
        $output | Should -Not -Match "#fragment"
    }

    It "marks an invalid integration URL safely" {
        $runner = Join-Path $repositoryRoot "run-integration-tests.ps1"
        $tempDirectory = Join-Path ([System.IO.Path]::GetTempPath()) ("snipeit-runner-test-" + [Guid]::NewGuid().ToString())
        New-Item -ItemType Directory -Path $tempDirectory -Force | Out-Null
        $fixture = Join-Path $tempDirectory "runner.Tests.ps1"
        @'
Describe "runner fixture" -Tag "Integration" {
    It "passes" { $true | Should -BeTrue }
}
'@ | Set-Content -LiteralPath $fixture

        try {
            $engine = if (Test-Path (Join-Path $PSHOME "pwsh.exe")) {
                Join-Path $PSHOME "pwsh.exe"
            } else {
                Join-Path $PSHOME "powershell.exe"
            }
            $output = & $engine -NoProfile -File $runner -URL "not a URL" -ApiKey "test-key" -Path $fixture 2>&1 | Out-String
        } finally {
            Remove-Item -LiteralPath $tempDirectory -Recurse -Force -ErrorAction SilentlyContinue
        }

        $output | Should -Match "Targeting live Snipe-IT instance at \[invalid URL\]"
    }

    It "skips file upload setup and tests before PowerShell 7" {
        $uploadFile = Join-Path $repositoryRoot "Tests/Integration/09-File-Uploads-And-Attachments.Integration.Tests.ps1"
        $content = Get-Content -LiteralPath $uploadFile -Raw
        ($content -match '\$script:uploadTestsSupported\s*=\s*\$PSVersionTable\.PSVersion\.Major\s*-ge\s*7') | Should -BeTrue
        ($content -match 'Describe\s+"Live Snipe-IT Integration: File Uploads & Attachments"[\s\S]*-Skip:\(\-not \$script:uploadTestsSupported\)') | Should -BeTrue
        $content.IndexOf('BeforeAll {') | Should -BeGreaterThan $content.IndexOf('Describe "Live Snipe-IT Integration: File Uploads & Attachments"')
    }

    It "uses generated per-run passwords for temporary integration users" {
        $temporaryUserFiles = @(
            "02-Org-Hierarchy.Integration.Tests.ps1"
            "04-Asset-Operations.Integration.Tests.ps1"
            "05-Accessories-Components.Integration.Tests.ps1"
            "06-Licenses-And-Seats.Integration.Tests.ps1"
            "10-Audits-Restores-Backups.Integration.Tests.ps1"
            "11-Component-Assignments-And-Relationships.Integration.Tests.ps1"
            "13-Pairwise-Asset-Permutations.Integration.Tests.ps1"
        )

        foreach ($fileName in $temporaryUserFiles) {
            $content = Get-Content -LiteralPath (Join-Path $repositoryRoot "Tests/Integration/$fileName") -Raw
            $content | Should -Not -Match '(?im)-password\s+["'']'
            $content | Should -Match '(?s)BeforeAll\s*\{.*?\$script:testPassword\s*='
            ([regex]::Matches($content, '\$script:testPassword\s*=')).Count | Should -Be 1
            $content | Should -Match 'RandomNumberGenerator'
            $content | Should -Match '(?im)-password\s+\$script:testPassword\b'
        }
    }
}
