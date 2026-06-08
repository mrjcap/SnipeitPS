# SnipeitPS

PowerShell API module for Snipe-IT Asset Management. Forked from [snazy2000/SnipeitPS](https://github.com/snazy2000/SnipeitPS) (archived). Actively maintained.

## Quick Reference

- **Language**: PowerShell 5.1+
- **License**: MIT
- **Version**: 1.14.0
- **Published**: PowerShell Gallery (`Install-Module SnipeitPS`)
- **CI**: None (manual publish to PSGallery)
- **Tests**: 699 Pester v5 tests across 16 files

## Project Structure

```
SnipeitPS/
├── SnipeitPS/
│   ├── SnipeitPS.psd1       # Module manifest
│   ├── Public/              # 115 exported functions (one per file)
│   └── Private/             # 10 internal helpers
├── Tests/                   # Pester v5 test files
├── docs/                    # Command documentation
└── run-tests.ps1            # Test runner
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
