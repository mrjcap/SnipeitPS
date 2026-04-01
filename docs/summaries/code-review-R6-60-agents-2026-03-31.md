# SnipeitPS Round 6 Code Review — 2026-03-31

60-agent review of 8 commits from R5 remaining fixes. 20 Standard + 20 Hostile + 20 Devil's Advocate.

## All 8 Fixes Verified Clean

- 701 tests pass, 0 failed
- Module loads with 115 exports
- PSScriptAnalyzer: zero new findings
- Zero breaking changes confirmed

## Key Discovery

Parens fix (commit 1de5b50) was a REAL bug fix, not cosmetic. PowerShell evaluates -and/-or left-to-right (not C-style precedence). Original code `A -and B -or C -and D` evaluated as `((A&B)|C)&D`. When user passed only `-url`, Reset-SnipeitPSLegacyApi was never called — a real session leak.

## New Critical/High Issues Found

| # | Issue | Scope |
|-|-|-|
| 1 | Get-SnipeitConsumable missing .Clone() on $SearchParameter + missing 10M safety cap | 1 file |
| 2 | $null leaks into pipeline on empty pagination results (all Get-* with -all) | ~27 files |
| 3 | New-SnipeitAssetLabel.ps1 has LF line endings (rest of repo is CRLF) | 1 file |
| 4 | Set-SnipeitLicenseSeat leaks seat_id into API body | 1 file |
| 5 | New-SnipeitAsset leaks checkout_to_type: "user" on non-checkout creates | 1 file |

## Medium Issues

| # | Issue |
|-|-|
| 6 | 29 param mismatches across 14 .md doc files (types, mandatory, syntax) |
| 7 | CHANGELOG missing ~10 recent commits; manifest still 1.12.0 |
| 8 | Unregister-SnipeitCustomField ConfirmImpact "Low" should be "High" |
| 9 | Update-SnipeitAssetAudit ConfirmImpact "Low" should be "Medium" |
| 10 | build.ps1 installs modules without version pins |
| 11 | 5 of 8 fixes have zero test coverage for specific behavior |
| 12 | Set-SnipeitInfo has no SupportsShouldProcess/ConfirmImpact |

## Low Issues

| # | Issue |
|-|-|
| 13 | Missing ValidateSet on asset_maintenance_type (2 files) |
| 14 | Incomplete action_type ValidateSet on Get-SnipeitActivity |
| 15 | Missing sort values in Get-SnipeitAsset ValidateSet |
| 16 | Commit 0803c25 has scope bleed (apikey changes in offset commit) |
| 17 | docs/about_SnipeitPS.md uses -apikey (lowercase) |

## Architectural Recommendations

| # | Recommendation | Impact |
|-|-|-|
| A | Extract pagination into helper function | -400 LOC, eliminates offset/null-leak bugs |
| B | Convert 6 remaining manual $Values builders to Get-ParameterValue | Eliminates dropped-param class |
| C | Extract legacy API boilerplate into Enter/Exit-SnipeitLegacyApi | -2100 LOC |
| D | Plan v2.0 removal of deprecated -url/-apiKey (5 years deprecated) | -2100 LOC + 3 helpers |

## R5 Items Status

All prior R5 items (1, 5, 11) confirmed fixed by devil-10. Only #2 (appveyor deploy condition) remains intentionally unaddressed.

## Fix Grades (Devil's Advocate Consensus)

| Fix | Grade |
|-|-|
| [Nullable[bool]] | ESSENTIAL |
| New-SnipeitModel $image | ESSENTIAL |
| Operator precedence parens | ESSENTIAL (real bug) |
| $offset ContainsKey | BENEFICIAL |
| Pin CI modules | BENEFICIAL |
| ConfirmImpact Medium | BENEFICIAL |
| Dead test removal | COSMETIC |
| $apiKey case | COSMETIC |
