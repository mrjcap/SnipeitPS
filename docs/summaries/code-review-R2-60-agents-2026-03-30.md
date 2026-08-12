# SnipeitPS Round 2 Code Review — 2026-03-30

Post-fix review (after 5 critical fixes applied). 60 agents: 20 Standard + 20 Hostile + 20 Devil's Advocate.

## Confirmed Fixed (no longer flagged)

1. Get-SnipeitFieldsetField — uses GET, not POST (confirmed by std-12, hostile-10)
2. API key redacted in Write-Debug (confirmed by std-1, hostile-1, std-3)
3. ConfirmImpact = "High" on all 20 Remove-* functions (confirmed by all groups)
4. Get-SnipeitAsset $requestable is now [switch] (confirmed by std-4)
5. Get-SnipeitUser $id and $accessory_id are now [int] (confirmed by std-8, hostile-6)

## NEW Top Priority Issues (not in Round 1 top-5)

### 1. ShouldProcess("ShouldProcess?") placeholder — ALL ~70 mutating functions

- **Consensus:** All 60 agents flagged this. Unanimous highest-priority remaining issue.
- **Impact:** `-WhatIf` and `-Confirm` output is completely uninformative for bulk operations
- **Fix:** `$PSCmdlet.ShouldProcess("$ResourceType ID $item_id", $MyInvocation.MyCommand.Name)`

### 2. Pagination bugs in ~27 Get-* functions (4 bugs, copy-pasted identically)

- **Consensus:** hostile-12, hostile-17, devil-12 all confirmed all 4 bugs in all 6 sampled functions
- **Bugs:** (a) `$callargs = $SearchParameter` — no `.Clone()`, mutates original (b) `$limit=0` infinite loop (c) no
  max-iteration guard (d) `$offset` falsy check
- **Fix:** Centralize in new private helper or fix in-place across 27 files

### 3. $Values body pollution in Set-*/Owner functions (6+ functions)

- **Consensus:** hostile-13 confirmed ALL 6 sampled functions leak `id`/`url`/`apiKey` into body
- **Functions:** Set-SnipeitManufacturer, Set-SnipeitSupplier, Set-SnipeitComponent, Set-SnipeitConsumable,
  Set-SnipeitComponentOwner, Set-SnipeitConsumableOwner
- **Fix:** Add `-DefaultExcludeParameter 'id','url','apiKey','RequestType'` to each `Get-ParameterValue` call

### 4. Password as plaintext [string] in New/Set-SnipeitUser

- **Consensus:** hostile-6, hostile-16, devil-6 all flagged HIGH
- **Fix:** Accept [SecureString] or at minimum add [REDACTED] to debug output

### 5. Invoke-SnipeitMethod query string guard is a no-op

- **Consensus:** std-1, hostile-1 confirmed — `$apiUri -notlike "*\?*"` backslash has no meaning in -notlike
- **Fix:** Change to `"*?*"` (literal `?` is valid in -notlike glob patterns)

### 6. New-SnipeitComponent $qty still typed as [string]

- **Consensus:** std-6, std-15, devil-4 confirmed — should be [int]
- **Note:** This was item #16 from Round 1 but was not in the top-5 fix batch

### 7. Update-SnipeitAlias regex injection via alias keys

- **Consensus:** hostile-9 confirmed — `-replace $key` treats key as regex pattern
- **Fix:** Use `[regex]::Escape($key)`

## Remaining Known Issues (from Round 1, still present)

| # | Issue | Severity | Scope |
| - | - | - | - |
| 8 | `if ($id)` falsy check on [int] across ~20 Get-* | Medium | Module-wide |
| 9 | No HTTPS enforcement on Connect-SnipeitPS URL | High | 1 file |
| 10 | Commented-out version/manifest tests | High | 2 files |
| 11 | appveyor.yml deploy condition contradicts comment | High | 1 file |
| 12 | build.ps1 hardcoded NuGet API key placeholder | Medium | 1 file |
| 13 | Save-SnipeitBackup duplicates auth resolution | Medium | 1 file |
| 14 | Save-SnipeitBackup path traversal via encoded filename | Medium | 1 file |
| 15 | Set-SnipeitCustomField $element mandatory blocks PATCH | Medium | 1 file |
| 16 | Set-SnipeitCompany $name mandatory blocks PATCH | Medium | 1 file |
| 17 | Set-SnipeitComponent $qty mandatory blocks PATCH | Medium | 1 file |
| 18 | Set-SnipeitStatus $type mandatory blocks PATCH | Medium | 1 file |
| 19 | Unpinned module installs in CI | Medium | 1 file |
| 20 | Date .ToString() without InvariantCulture | Medium | 4 functions |

## Design Themes (devil's advocate consensus, unchanged from R1)

1. **Singleton session** — accepted as-is per user decision
2. **~60% boilerplate** — 1,596 identical lines across 114 functions (14 lines each)
3. **Pagination duplicated** — 405 identical lines across 27 functions (15 lines each)
4. **Legacy param removal** — recommended for v2.0
5. **ShouldProcess placeholder** — unanimously the #1 UX defect

## Round 2 vs Round 1 Comparison

| Metric | Round 1 | Round 2 | Delta |
| - | - | - | - |
| Critical bugs | 6 | 0 | -6 (all fixed) |
| High severity | ~20 | ~15 | -5 |
| Medium severity | ~30 | ~25 | -5 |
| Module-wide patterns | 5 | 4 | -1 (ConfirmImpact fixed) |

## Recommended Next Fix Batch

1. ShouldProcess target strings (~70 files, mechanical)
2. $Values body pollution fix (6 files, add DefaultExcludeParameter)
3. Invoke-SnipeitMethod query string guard (1 line fix)
4. New-SnipeitComponent $qty [string]→[int] (1 line fix)
5. Update-SnipeitAlias regex escape (1 line fix)
