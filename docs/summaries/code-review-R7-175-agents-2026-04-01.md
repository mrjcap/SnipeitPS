# SnipeitPS Round 7 Code Review — 2026-04-01

175 agents dispatched (83 Standard + 60 Hostile + 32 Devil's Advocate). ~155 returned results.
701 tests pass. 115 exports. PSScriptAnalyzer: 3 warnings (all empty catch blocks, intentional).

## All R6+R7 Fixes Verified

All 13 commits from R6 (8) + R7 (7) fix rounds confirmed in place by verification agents.
- 27/27 pagination null guards present
- 112/112 parens in end{} correct
- 112/112 $apiKey correct case
- All CRLF line endings (130 .ps1 files)
- 0 Co-Authored-By lines across 33 unpushed commits
- Module loads clean with 115 exports
- PS5/PS7 compatibility: CLEAN (no PS7-only syntax)

## NEW Critical Findings

### 1. Shared mutable $Values corruption on multi-ID image uploads (hostile-8)
$Values hashtable is built once in begin{} and shared by reference across all IDs in the foreach loop. Invoke-SnipeitMethod MUTATES $Body in-place during image handling (adds _method, replaces image with FileInfo, adds file[], removes file). Second ID in `Set-SnipeitAsset -id 1,2 -image foo.png` gets a corrupted body. Affects all Set-* functions with -image param.

### 2. PS5 base64 data URI has malformed `data:@` prefix (hostile-10)
Invoke-SnipeitMethod line 133: `'data:@'+$mimetype` produces `data:@application/octet-stream;base64,...`. The `@` is non-standard. Some Snipe-IT versions may reject or store corrupted images on PS5.

### 3. TLS not enforced in runtime module (hostile-15)
`[Net.ServicePointManager]::SecurityProtocol = Tls12` is only in build.ps1, NOT in the module itself. PS5.1 with older .NET defaults to TLS 1.0/1.1. API calls may fail silently or use insecure transport.

## NEW High Findings

| # | Issue | Source |
|-|-|-|
| 4 | $_ shadowing in inner catch loses HTTP status code on PS7 (cosmetic double-space in error msg) | hostile-6 |
| 5 | StreamReader not disposed in try/finally on PS5 error path | hostile-6 |
| 6 | $false from auth failure leaks into pipeline output via null guard | hostile-7 |
| 7 | Get-ParameterValue: negated switches (-Param:$false) not converted from SwitchParameter to $false | hostile-9 (Get-ParameterValue) |
| 8 | Throttle arithmetic goes negative on first Constant-mode request (empty ArrayList) | hostile-8 |
| 9 | New-SnipeitLocation has dead image_delete switch on create (copy-paste from Set-) | hostile-10 |
| 10 | No URI scheme validation in Connect-SnipeitPS (accepts file://, ftp://) | hostile-15 |
| 11 | Connect-SnipeitPS accepts empty string apiKey (no ValidateNotNullOrEmpty) | hostile-13 |

## Medium Findings (still open from R6)

| # | Issue |
|-|-|
| 12 | 29+ param mismatches across 14 .md doc files |
| 13 | CHANGELOG missing ~33 commits; manifest still 1.12.0 |
| 14 | README badges/links still point to snazy2000 archived repo (5 URLs) |
| 15 | build.ps1 installs modules without version pins |
| 16 | Missing ValidateSet on asset_maintenance_type (2 files) |
| 17 | Get-SnipeitConsumable missing ValidateRange on $limit |
| 18 | New-SnipeitLicense $seats accepts 0 (should ValidateRange(1,max)) |
| 19 | appveyor deploy condition contradicts comment (deploys on every push, not tags) |
| 20 | /api/v1/ prefix hardcoded in ~100 places |

## Architectural Recommendations (unchanged from R6)

| # | Recommendation | Impact |
|-|-|-|
| A | Extract pagination into helper function | -400 LOC |
| B | Convert 6 remaining manual $Values builders to Get-ParameterValue | Eliminates dropped-param class |
| C | Extract legacy API boilerplate into helper | -2100 LOC |
| D | Plan v2.0 removal of deprecated -url/-apiKey (5 years deprecated) | -2100 LOC |

## Additional Findings from Wave 3 (hostile param audits)

### NEW Critical
| # | Issue | Source |
|-|-|-|
| 21 | Set-SnipeitAsset $last_checkout [DateTime] never formatted with .ToString("yyyy-MM-dd") | hostile-29 |
| 22 | Remove-SnipeitAssetFile/ModelFile have spurious /delete suffix in API path (would 404) | hostile-31 |

### NEW Medium (param validation gaps)
| # | Issue | Files |
|-|-|-|
| 23 | image_delete switch on New-SnipeitLocation + New-SnipeitDepartment (nonsensical on create) | 2 |
| 24 | Missing ValidateRange on FK IDs ($category_id, $company_id, etc.) across 8+ functions | ~8 |
| 25 | $purchase_cost type inconsistency: [string] vs [float] vs [double] across functions | ~4 |
| 26 | Set-SnipeitComponent $qty mandatory on Set-* (should be optional for partial updates) | 1 |
| 27 | Missing $sort param on 8 Get-* functions that have $order but no sort | 8 |
| 28 | Get-SnipeitAsset $status missing ValidateSet (only accepts RTD/Deployed/etc.) | 1 |
| 29 | Get-SnipeitConsumable missing ValidateRange on $limit | 1 |
| 30 | Get-SnipeitLicenseSeat uses if($seat_id) falsy check instead of ContainsKey | 1 |
| 31 | 62 doc/code param type mismatches (38 Nullable[Int32], 17 Nullable[Boolean], 3 mandatory, 2 password, 1 switch, 1 int/string) | ~40 .md files |

### Confirmed clean
- All API endpoints correct (60 Get/New checked, 55 Set/Remove/etc checked)
- All ShouldProcess strings meaningful (72/73)
- All date params formatted (22/22)
- PS5/PS7 compatibility: CLEAN
- No credential leaks in verbose/debug
- No encoding/locale bugs

## Devil's Advocate Summary

### Release readiness
- Module version should be **v1.14.0** (not 1.12.0 or 1.13.0)
- CHANGELOG draft prepared by devil-5
- README badges need updating before release
- 33 commits ahead of origin, none pushed yet

### Test quality
- 701 tests, 799 It blocks, 100% function coverage
- BUT: mocks return $null (not realistic API shapes), no error path testing, no return value assertions, no integration tests

### Module comparison
- Test-to-code ratio: excellent (5.5 tests/function)
- Architecture: dated (2017 patterns, no typed output, no cross-platform CI)
- Security: needs TLS enforcement, URI scheme validation
