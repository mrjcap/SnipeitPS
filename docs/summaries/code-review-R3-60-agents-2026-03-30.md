# SnipeitPS Round 3 Code Review — 2026-03-30

Post-fix review (after all 10 fixes). 60 agents: 20 Standard + 20 Hostile + 20 Devil's Advocate.

## All 10 Previous Fixes Confirmed Clean

| Fix | Confirmed by | Status |
|-|-|-|
| 1. API key redacted in Write-Debug | r3-std-1, r3-hostile-1, r3-hostile-19 | PASS |
| 2. ConfirmImpact="High" on all 20 Remove-* | r3-hostile-3, r3-hostile-4 (all 19 checked) | PASS |
| 3. Get-SnipeitFieldsetField uses GET | r3-std-4, r3-hostile-19 | PASS |
| 4. $requestable is [switch] | r3-std-2, r3-hostile-7, r3-hostile-19 | PASS |
| 5. Get-SnipeitUser $id is [int] | r3-std-2, r3-hostile-19 | PASS |
| 6. ShouldProcess with meaningful targets | r3-std-2 thru r3-std-11, r3-devil-2 | PASS (74 files) |
| 7. Query string guard uses [?] | r3-std-1, r3-hostile-1 | PASS |
| 8. New-SnipeitComponent $qty is [int] | r3-std-3, r3-hostile-7 | PASS |
| 9. Update-SnipeitAlias uses [regex]::Escape | r3-std-3, r3-hostile-7 | PASS |
| 10. $Values body pollution (false positive) | r3-hostile-5, r3-hostile-15 confirmed clean | PASS |

**No regressions introduced.** All fixes are consistently applied across the codebase.

## Remaining Issues (ranked by cross-group consensus)

### Tier 1: High severity (flagged by multiple groups)

| # | Issue | Files | Groups |
|-|-|-|-|
| 1 | **Pagination bugs** (no .Clone(), no $limit validation, no max-iter) | ~27 Get-* | std, hostile, devil |
| 2 | **Password as [string]** in New/Set-SnipeitUser | 2 files | std, hostile, devil |
| 3 | **`if ($id)` falsy check** on [int] instead of $PSBoundParameters.ContainsKey | ~15 Get-* | std, hostile, devil |
| 4 | **$id leaks into query string** in sub-resource Get-* (custom DefaultExcludeParameter overrides default) | 6 files | std-14, hostile-12, hostile-18 |
| 5 | **Set-SnipeitCustomField $element mandatory** blocks PATCH | 1 file | std, hostile, devil |
| 6 | **Set-SnipeitStatus $type mandatory** blocks PATCH | 1 file | std, hostile, devil |
| 7 | **Set-SnipeitCompany $name mandatory** blocks PATCH | 1 file | std, hostile |
| 8 | **No HTTPS enforcement** on Connect-SnipeitPS URL | 1 file | hostile-2, hostile-16 |
| 9 | **Commented-out version/manifest tests** | 1 file | std-12, hostile-10 |
| 10 | **appveyor.yml deploy condition inverted** | 1 file | std-12, hostile-10 |

### Tier 2: Medium severity

| # | Issue | Files | Groups |
|-|-|-|-|
| 11 | [bool] params with defaults ($activated, $ldap_import, $maintained, $reassignable) always inject false into body | 4 files | std-2, std-10, hostile-7 |
| 12 | Set-SnipeitAsset $requestable still [bool] (only Get- was fixed to [switch]) | 1 file | std-2 |
| 13 | Save-SnipeitBackup duplicates auth resolution without PS7 branch | 1 file | std-1, hostile-1, hostile-2 |
| 14 | New-SnipeitModel silently drops $image parameter | 1 file | std-8, hostile-14 |
| 15 | Owner/checkout functions leak $id into POST body | 4 files | std-20, hostile-8 |
| 16 | ConfirmImpact inconsistency on Set-* functions (some Low, some Medium) | ~8 files | std-9, std-17 |
| 17 | build.ps1 hardcoded NuGet API key + dead internal repo | 1 file | hostile-10 |
| 18 | Unpinned module installs in CI | 1 file | hostile-10 |
| 19 | Date .ToString() without InvariantCulture | 4 functions | hostile-15 |
| 20 | Unregister-SnipeitCustomField ConfirmImpact="Low" on destructive op | 1 file | std-11 |

### Tier 3: Design themes (devil's advocate, unchanged)

1. **Pagination duplication** — 1,140+ identical lines across 27 functions
2. **Begin/end boilerplate** — 14 identical lines x 114 functions = ~1,596 lines
3. **Legacy param removal** — recommended for v2.0
4. **Owner/checkout naming** — misleading verb semantics
5. **AuditDue/AuditOverdue redundancy** — two byte-identical functions
6. **Pipeline ergonomics gaps** — Get | Remove chains don't work for files/accessories

## Round 3 vs Round 2 vs Round 1 Comparison

| Metric | R1 | R2 | R3 |
|-|-|-|-|
| Critical bugs | 6 | 0 | 0 |
| High severity | ~20 | ~15 | ~10 |
| Medium severity | ~30 | ~25 | ~20 |
| Fixes confirmed clean | N/A | 5/5 | 10/10 |
| No regressions | N/A | Yes | Yes |

## Recommended Next Fix Batch

1. **Pagination centralization** — new private `Invoke-SnipeitPaginatedRequest` (fixes 4 bugs in 1 place, reduces 27 files)
2. **$id leaks into query string** — fix 6 sub-resource Get-* DefaultExcludeParameter to include 'id'
3. **Mandatory params on Set-*** — remove Mandatory from $element, $type, $name on 3 Set-* functions
4. **[bool] params → [switch]** or [Nullable[bool]] on $activated, $ldap_import, $maintained, $reassignable, $requestable (Set-SnipeitAsset)
5. **New-SnipeitModel $image** — add to $Values (currently silently dropped)
