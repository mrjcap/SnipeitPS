# SnipeitPS

PowerShell API module for Snipe-IT Asset Management. Forked from [snazy2000/SnipeitPS](https://github.com/snazy2000/SnipeitPS) (archived). Actively maintained.

## Quick Reference

- **Language**: PowerShell 5.1+
- **License**: MIT
- **Version**: 1.12.0
- **Published**: PowerShell Gallery (`Install-Module SnipeitPS`)
- **CI**: AppVeyor
- **Tests**: 628 Pester v5 tests across 16 files

## Project Structure

```
SnipeitPS/
├── SnipeitPS/
│   ├── SnipeitPS.psd1       # Module manifest
│   ├── Public/              # 114 exported functions (one per file)
│   └── Private/             # 10 internal helpers
├── Tests/                   # 16 Pester v5 test files (628 tests)
├── docs/                    # Command documentation
├── build.ps1                # Build script
├── SnipeitPS.build.ps1      # InvokeBuild tasks
├── run-tests.ps1            # Test runner
└── appveyor.yml             # CI configuration
```

## Commands

```powershell
# Import locally
Import-Module ./SnipeitPS/SnipeitPS.psd1

# Run all tests
./run-tests.ps1
# or
Invoke-Pester -Path Tests/

# Run a single test file
Invoke-Pester -Path Tests/SnipeitPS.Tests.ps1

# Build
./build.ps1

# Publish to PSGallery (requires API key)
Publish-Module -Name SnipeitPS -NuGetApiKey $env:PS_GALLERY_API_KEY

# Connect to Snipe-IT instance
Connect-SnipeitPS -URL 'https://asset.example.com' -apiKey 'tokenKey'
```

## Key Patterns

- All functions: `Test-SnipeitAlias` in begin block, legacy param handling, `Reset-SnipeitPSLegacyApi` in end block
- Date handling: `.ToString("yyyy-MM-dd")`
- Pagination: recursive `-all` with offset loop
- One function per file in `Public/`

## Vault Notes

- [[powershell-module-structure]]
- [[powershell-http-verb-mapping]]
- [[powershell-legacy-api-handling]]
