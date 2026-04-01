# SnipeitPS R8 Code Review — 2026-04-01

59 agents dispatched (20 Standard + 19 Hostile + 20 Devil's Advocate).
699 tests pass. 115 exports. 162 files changed.

## BLOCKERS — Must Fix Before Commit

| # | Sev | Sources | Finding | Fix |
|-|-|-|-|-|
| 1 | Critical | std-2, hostile-2, da-2, da-16 | TLS `=` replaces protocol instead of `-bor` — downgrades TLS 1.3 on PS7 | `[Net.ServicePointManager]::SecurityProtocol = [Net.ServicePointManager]::SecurityProtocol -bor [Net.SecurityProtocolType]::Tls12` |
| 2 | Critical | std-7, da-3 | Get-SnipeitAsset `$status` ValidateSet lost in merge | Add `[ValidateSet("RTD","Deployed","Undeployable","Pending","Archived","Requestable","Deleted")]` |
| 3 | Critical | hostile-12, da-7 | `/delete` suffix removal is a REGRESSION — Snipe-IT routes require it | Restore `/delete` in Remove-SnipeitAssetFile + Remove-SnipeitModelFile + tests |
| 4 | Bug | std-11 | Get-SnipeitLicenseSeat `$seat_id` falsy check lost in merge | Change `if($seat_id)` to `$PSBoundParameters.ContainsKey('seat_id')` |
| 5 | Bug | std-8 | Get-SnipeitConsumable `$limit` missing ValidateRange | Add `[ValidateRange(1,500)]` |
| 6 | Important | std-19, hostile-20, da-18 | `skip_tags: true` conflicts with `appveyor_repo_tag: true` — deploy is dead code | Change `skip_tags: false` or remove |
| 7 | Important | hostile-13 | New-SnipeitManufacturer still has dead `image_delete` switch | Remove param + .PARAMETER |

## SHOULD FIX — Before Release

| # | Sev | Sources | Finding |
|-|-|-|-|
| 8 | Important | std-18, hostile-15, da-17 | CHANGELOG: Set-SnipeitLicense phantom in Clone() list (lists 13, should be 12) |
| 9 | Important | std-18, da-8, da-18 | Manifest version not bumped (1.12.0), appveyor (1.12.{build}) — must match CHANGELOG |
| 10 | Important | da-4 | `purchase_cost` should be `[decimal]` not `[string]` — preserves JSON numeric type + precision + input validation |
| 11 | Important | da-12 | `$sort = "created_at"` default leaks into by-ID API calls via Get-ParameterValue — remove default to match Get-SnipeitAsset pattern |
| 12 | Important | da-6, hostile-14 | 52 doc Nullable[Int32]/Boolean type fixes will be overwritten by platyPS — revert type changes, keep Required + real type fixes |
| 13 | Low | std-10, hostile-10 | Test Coverage-New-Legacy.Tests.ps1:37 still uses `[float]99.99` assertion |
| 14 | Low | hostile-20, da-17 | CHANGELOG `v.1.14.0` extra dot format |
| 15 | Low | std-1 | Invoke-SnipeitMethod help text shows `$script:SnipeitApiPrefix` instead of literal path |

## ARCHITECTURAL INSIGHTS — For Future Sessions

| # | Sources | Insight |
|-|-|-|
| A | da-1 | Clone() should be ONE line in Invoke-SnipeitMethod (before mutations), not 12 caller-side clones. Current fix is incomplete — New-* image functions unprotected. |
| B | da-5, da-13 | API prefix extraction is halfway refactor — either revert to literals or complete by moving prefix into Invoke-SnipeitMethod. Current state adds indirection with no real benefit. |
| C | da-14 | 40 Set-*/Remove-* `$id` primary key params have NO ValidateRange — higher risk than FK IDs already covered (`Remove-SnipeitAsset -id 0` → `DELETE /hardware/0`). |
| D | da-8 | Release strategy: tag 33 committed fixes as v1.13.1, uncommitted R8 work as v1.14.0. Split 162-file batch into atomic commits. |
| E | da-13 | API prefix extraction (90 files) should be separate commit from bug fixes (66 files). |
| F | da-19 | Module is in good maintenance state. Pagination helper is highest ROI next step. Further code review rounds have diminishing returns — invest in integration tests. |
| G | da-9 | Tests provide regression value (88% mock invocation checks) but cannot validate against real API. Integration tests against Docker Snipe-IT needed. |
| H | da-10 | 2 genuinely breaking changes: image_delete removal (scripts error), ValidateRange on FK IDs (rejects 0). Both fix incorrect usage but warrant CHANGELOG notice. |
| I | da-11 | R8 is correct triage — symptom fixes within existing contract. Root causes (Invoke-SnipeitMethod mutation, [int] zero defaults, copy-paste architecture) need v2.0. |

## CONFIRMED CLEAN — No Issues Found

### Standard (12/20 clean)
std-1 (Invoke-SnipeitMethod), std-3 (Get-ParameterValue switch), std-4 ($Values.Clone()), std-5 (Remove-*File verified against API ref), std-6 (last_checkout), std-9 (sort params), std-12 (API prefix extraction), std-13 (API prefix Get-*), std-14 (API prefix New/Set/Remove), std-15 (doc type fixes), std-16 (New-SnipeitAssetLabel.md), std-17 (test changes), std-20 (module load 115 exports)

### Hostile (10/19 clean)
hostile-1 (Clone holds), hostile-4 (API prefix clean), hostile-6 (switch fix correct), hostile-8 (base64 correct), hostile-11 (sort default valid), hostile-16 (PS5/PS7 compat clean), hostile-19 (all 23 DateTimes formatted)

### Devil's Advocate (key verdicts)
- da-2: TLS placement in Connect begin{} IS correct
- da-3: ValidateSet on hardcoded server enums IS appropriate
- da-10: Only 2 genuinely breaking changes (both fix incorrect usage)
- da-11: R8 is correct strategy — symptom management for a maintained fork
- da-15: Write-Error is idiomatic PS, don't switch to throw, don't drop PS5
- da-19: Module architecture is correct for what it is — explicit beats clever

## STATISTICS

| Wave | Agents | Clean | Findings | Key Issues |
|-|-|-|-|-|
| Standard | 20 | 12 | 8 | 3 critical (TLS, ValidateSet, ValidateRange), 1 bug, 5 important |
| Hostile | 19 | 10 | 9 | /delete regression, image_delete miss, siteCred bypass, FK gaps, doc fragility |
| Devil's Advocate | 20 | n/a | 20 | Clone architecture, API prefix value, purchase_cost [decimal], sort leak, release readiness |
| **Total** | **59** | **22 clean** | **37 findings** | **7 blockers, 8 should-fix, 10 architectural insights** |
