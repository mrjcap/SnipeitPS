# SnipeitPS 60-Agent Code Review — 2026-03-30

Reviewed by: 20 Standard Reviewers + 20 Hostile Security Reviewers + 20 Devil's Advocate Architects

## CRITICAL BUGS (confirmed by multiple review groups)

### 1. Get-SnipeitFieldsetField uses POST instead of GET

- **File:** `Public/Get-SnipeitFieldsetField.ps1:38`
- **Found by:** std-19, hostile-19
- **Impact:** Every call to read fieldset fields sends a POST with empty body to a GET endpoint. Will fail on strict
  servers or generate false write-events in audit logs.
- **Fix:** Change `Method = 'Post'` to `Method = 'Get'` and remove `Body = @{}`

### 2. Invoke-SnipeitMethod query string guard is a no-op

- **File:** `Private/Invoke-SnipeitMethod.ps1:101`
- **Found by:** std-1
- **Impact:** `$apiUri -notlike "*\?*"` uses backslash which has no meaning in PowerShell `-notlike`. The condition is
  always true, so `$GetParameters` are always appended unconditionally. If the URL already has a query string,
  parameters get double-appended.
- **Fix:** Use `"*``?*"` (backtick-escaped) or `"*?*"` (literal ? is valid in -notlike)

### 3. API key leaked via Write-Debug in Invoke-SnipeitMethod

- **File:** `Private/Invoke-SnipeitMethod.ps1:219`
- **Found by:** hostile-1, hostile-3
- **Impact:** `Write-Debug` dumps the full `$splatParameters` hashtable including `Authorization: Bearer <token>`. Any
  session with `-Debug` or `$DebugPreference = 'Continue'` leaks the API key to console/transcript/CI logs. All 114
  public functions inherit this leak.
- **Fix:** Redact the Authorization header before debug output

### 4. API key leaked via Write-Debug in Connect-SnipeitPS

- **File:** `Public/Connect-SnipeitPS.ps1:147`
- **Found by:** hostile-3
- **Impact:** `Write-Debug "Site apikey: $($SnipeitPSSession.apiKey)"` prints the key to debug stream.
- **Fix:** Remove or redact

### 5. appveyor.yml deploy condition contradicts its comment

- **File:** `appveyor.yml:101-103`
- **Found by:** std-20, hostile-20
- **Impact:** `appveyor_repo_tag: false` with comment "deploy on tag push only". Actually deploys on every master push,
  not on tags. Could publish unintended versions.
- **Fix:** Change to `appveyor_repo_tag: true` or update comment

### 6. build.ps1 hardcoded NuGet API key

- **File:** `build.ps1:84`
- **Found by:** hostile-20
- **Impact:** `Publish-Module -NuGetApiKey 123456789` — placeholder key in committed source. Any real key rotated here
  would be exposed in git history.
- **Fix:** Use environment variable

---

## HIGH SEVERITY ISSUES (cross-group consensus)

### 7. ConfirmImpact = "Low" on ALL Remove-* functions

- **Files:** Every `Remove-Snipeit*.ps1` (15+ files)
- **Found by:** All three groups independently
- **Impact:** Destructive DELETE operations never prompt for confirmation at default `$ConfirmPreference = "High"`.
`Get-SnipeitAsset -all | Remove-SnipeitAsset` silently deletes everything.
- **Fix:** Change to `ConfirmImpact = "High"` on all Remove-* functions

### 8. ShouldProcess("ShouldProcess?") placeholder in ALL mutating functions

- **Files:** Every New-*/Set-*/Remove-*/Reset-*/Restore-*/Update-* function (~70 files)
- **Found by:** All three groups independently
- **Impact:** `-WhatIf` and `-Confirm` output shows "ShouldProcess?" instead of the resource ID. Operators cannot
  determine what will be affected in bulk operations.
- **Fix:** Use `$PSCmdlet.ShouldProcess("$ResourceType ID $item_id", $MyInvocation.MyCommand.Name)`

### 9. Get-SnipeitAsset $requestable = $false silently filters all searches

- **File:** `Public/Get-SnipeitAsset.ps1:179`
- **Found by:** std-4, hostile-4, devil-4
- **Impact:** `[bool]$requestable = $false` means every Search call sends `requestable=false` to the API, hiding
  requestable assets even when the caller didn't specify the parameter.
- **Fix:** Use `[Nullable[bool]]$requestable` or gate on `$PSBoundParameters.ContainsKey('requestable')`

### 10. Password as plaintext [string] in New/Set-SnipeitUser

- **Files:** `Public/New-SnipeitUser.ps1:87-88`, `Public/Set-SnipeitUser.ps1:104`
- **Found by:** hostile-11
- **Impact:** `$password` is `[string]`, flows into body as JSON plaintext, appears in `-Verbose`/`-Debug` output and
  `$PSBoundParameters`.
- **Fix:** Accept `[SecureString]` and convert at the last moment before body construction

### 11. Get-SnipeitUser $id is [string] — enables path traversal

- **Files:** `Public/Get-SnipeitUser.ps1:107,110`
- **Found by:** std-11, hostile-11
- **Impact:** `$id` and `$accessory_id` are `[string]` (not `[int]`), interpolated directly into URL path. Allows
  `Get-SnipeitUser -id "../assets/1"` to hit arbitrary endpoints.
- **Fix:** Change to `[int]` like all other functions

### 12. `if ($id)` falsy check on [int] across ALL Get-* functions

- **Files:** ~20 Get-* functions
- **Found by:** Nearly every agent across all groups
- **Impact:** `[int]$id` defaults to 0. `if ($id)` is falsy for 0, so `-id 0` silently falls back to list-all endpoint
  instead of erroring. While ID 0 is invalid in Snipe-IT, the pattern is incorrect.
- **Fix:** Use `$PSBoundParameters.ContainsKey('id')` consistently

### 13. $Values body includes id/url/apiKey in many Set-* functions

- **Files:** Set-SnipeitManufacturer, Set-SnipeitSupplier, Set-SnipeitComponentOwner, Set-SnipeitConsumable,
  Set-SnipeitConsumableOwner, and others
- **Found by:** std-6, std-8, std-9, std-15, hostile-6, hostile-8, hostile-9, hostile-15, hostile-19
- **Impact:** `Get-ParameterValue` called without `-DefaultExcludeParameter` for `id`, `url`, `apiKey`. These leak into
  the API request body as unexpected JSON fields. `id` array in body can confuse server-side routing.
- **Fix:** Add `-DefaultExcludeParameter 'id','url','apiKey','RequestType','Debug','Verbose'` to all affected calls

### 14. No HTTPS enforcement on Connect-SnipeitPS URL

- **File:** `Public/Connect-SnipeitPS.ps1:71/112`
- **Found by:** hostile-3
- **Impact:** `[Uri]$url` accepts `http://`, `ftp://`, `file://`. Bearer token sent over plaintext HTTP if caller
  provides `http://` URL.
- **Fix:** Add `[ValidateScript({ $_.Scheme -eq 'https' })]` or at minimum a warning

### 15. Commented-out version/manifest tests

- **File:** `Tests/SnipeitPS.Tests.ps1:31-108`
- **Found by:** std-20, hostile-20
- **Impact:** Entire manifest/changelog/AppVeyor version cross-checks are wrapped in `<# #>`. No automated drift
  detection. AppVeyor version is 1.10 while module is 1.12.
- **Fix:** Uncomment and update, or replace with new v5-style tests

### 16. New-SnipeitComponent $qty typed as [string] not [int]

- **File:** `Public/New-SnipeitComponent.ps1:61`
- **Found by:** std-8, hostile-8
- **Impact:** Accepts non-numeric strings ("abc", "-1", "999999999999") with no validation. Set-SnipeitComponent
  correctly uses `[int]`.
- **Fix:** Change to `[int]$qty`

### 17. Update-SnipeitAlias regex injection via alias keys

- **File:** `Public/Update-SnipeitAlias.ps1:42`
- **Found by:** hostile-18
- **Impact:** `-replace $key, $value` treats `$key` as regex. If any alias key contains metacharacters (`.`, `*`, `+`),
  the replacement pattern is uncontrolled, potentially corrupting output .ps1 files.
- **Fix:** Use `[regex]::Escape($key)` in the -replace pattern

### 18. New/Set-SnipeitGroup unvalidated permissions hashtable

- **Files:** `Public/New-SnipeitGroup.ps1:52`, `Public/Set-SnipeitGroup.ps1:60`
- **Found by:** hostile-18
- **Impact:** `[hashtable]$permissions` passed raw to API body. Attacker-controlled keys (e.g., `superuser=1`) go
  straight to the server.
- **Note:** This is a design decision — the module is a thin API wrapper. Server-side validation is the last line of
  defense. But client-side key validation would be a defense-in-depth improvement.

### 19. Save-SnipeitBackup server-side path traversal via encoded filename

- **File:** `Public/Save-SnipeitBackup.ps1:26/66`
- **Found by:** hostile-3
- **Impact:** Filename validation rejects `..` and `/\` but not URL-encoded variants. The filename is sent to the server
  API path, where `..%2F` could be decoded by the server before path resolution.
- **Fix:** Canonicalize the filename and reject any encoded characters

### 20. Infinite pagination loop when -limit 0 or exact-count edge case

- **Files:** All functions with `-all` pagination (~20 files)
- **Found by:** hostile-7, hostile-10, hostile-13, hostile-14, devil-4
- **Impact:** No max-iteration guard. If API returns exactly `$limit` items on last page, one extra round trip. If
  `$limit = 0`, infinite loop (`0 -lt 0` is false, but offset increments by 0).
- **Fix:** Add `[ValidateRange(1,500)]` on `$limit` and add a max-iteration safety cap

---

## MEDIUM SEVERITY ISSUES

### 21. Set-SnipeitCustomField $element mandatory blocks partial updates

- **File:** `Public/Set-SnipeitCustomField.ps1:62-63`
- **Impact:** PATCH should allow updating just `$name` without requiring `$element`.

### 22. Set-SnipeitCompany $name mandatory blocks partial updates

- **File:** `Public/Set-SnipeitCompany.ps1:43`
- **Impact:** Same issue — PATCH semantics require optional fields.

### 23. Set-SnipeitComponent $qty mandatory blocks partial updates

- **File:** `Public/Set-SnipeitComponent.ps1:65`
- **Impact:** Can't update component name without also specifying quantity.

### 24. Get-SnipeitActivity uses `throw` instead of `$PSCmdlet.ThrowTerminatingError()`

- **File:** `Public/Get-SnipeitActivity.ps1:88-95`
- **Impact:** `throw` in `begin{}` is not interceptable via `-ErrorAction`.

### 25. New-SnipeitAssetFile swallows return value

- **File:** `Public/New-SnipeitAssetFile.ps1:76`
- **Impact:** `Invoke-SnipeitMethod @Parameters` result is not captured or output. Callers cannot determine
  success/failure.

### 26. Operator precedence in legacy reset conditions

- **Files:** ~20 files in `end{}` block
- **Impact:** `$x -and $y -or $z -and $w` without parentheses. Works by coincidence (AND binds tighter), but fragile and
  easily misread.

### 27. Shared $SearchParameter hashtable mutation in -all loops

- **Files:** All pagination functions
- **Impact:** `$callargs = $SearchParameter` is a reference copy, not clone. `.Remove('all')` and offset assignment
  mutate the original, corrupting state on repeated calls.
- **Fix:** Use `$callargs = $SearchParameter.Clone()`

### 28. Save-SnipeitBackup duplicates auth resolution from Invoke-SnipeitMethod

- **File:** `Public/Save-SnipeitBackup.ps1:54-62`
- **Impact:** Manual token extraction will diverge if Invoke-SnipeitMethod auth flow changes.

### 29. Pester v4 invocation in build.ps1 and SnipeitPS.build.ps1

- **Files:** `build.ps1:25`, `SnipeitPS.build.ps1:104`
- **Impact:** `Invoke-Pester -PassThru` without `New-PesterConfiguration` is legacy v4 style. Test files use v5. May
  produce wrong results or deprecation warnings.

### 30. Unpinned module installs in CI

- **File:** `appveyor.yml:44-49`
- **Impact:** `Install-Module InvokeBuild` etc. with no `-RequiredVersion`. Supply chain risk — compromised PSGallery
  module executes in CI.

---

## DESIGN CHALLENGES (Devil's Advocate consensus themes)

### D1. Module-scoped singleton session prevents multi-instance connections

All 20 devil's advocates flagged this. `$SnipeitPSSession` is a module-level variable — one PowerShell session can only
connect to one Snipe-IT instance at a time.
**Recommendation:** Accept a `-Session` parameter on all functions, defaulting to module-scope for backward compat.

### D2. Massive boilerplate duplication across 115 functions

Categories, Companies, Departments, Locations, Manufacturers, Suppliers — each has nearly identical Get/New/Set/Remove
functions. ~60% of the codebase is template code.
**Recommendation:** Consider a code generator or a generic `Invoke-SnipeitCrud -Resource departments` base function.

### D3. Pagination logic duplicated in ~20 functions

The `-all` loop (while/break/offset increment) is copy-pasted across every Get-* function with pagination support.
**Recommendation:** Centralize in `Invoke-SnipeitMethod` with a `-GetAll` parameter.

### D4. Legacy parameter support adds ~15 lines to every function

`$url`/`$apiKey` deprecated params + `Set-SnipeitPSLegacyUrl`/`Set-SnipeitPSLegacyApiKey` + `Reset-SnipeitPSLegacyApi` —
15 lines of boilerplate in begin{}/end{} of every function for backward compatibility.
**Recommendation:** Set a removal date (e.g., v2.0) and start warning with a timeline.

### D5. Response parsing uses field-sniffing instead of HTTP status codes

`Invoke-SnipeitMethod` determines what to return by checking for `payload`, `rows`, `status`, `total` fields on the
response object rather than HTTP status codes.
**Recommendation:** Use `Invoke-WebRequest` to get status code, then route on that.

### D6. Get-SnipeitAsset has 8 parameter sets — should be multiple functions

The function covers search, by-ID, by-tag, by-serial, by-user, by-component — fundamentally different operations
shoehorned into one function.
**Recommendation:** Keep the main Get-SnipeitAsset for search/ID lookup; split the others into `Get-SnipeitUserAsset`
etc. (some already exist).

### D7. ValidateScript({Test-Path $_}) on -image/-file params allows arbitrary file paths

Any locally readable file passes validation — including sensitive system files. No extension/size/MIME check.
**Recommendation:** Add extension allowlist and/or warn on non-image extensions.

---

## STATISTICS

| Group | Agents | Unique Issues Found | Critical | High | Medium | Low |
| - | - | - | - | - | - | - |
| Standard Reviewers | 20 | ~95 | 1 | 8 | 32 | 54 |
| Hostile Reviewers | 20 | ~120 | 2 | 25 | 42 | 51 |
| Devil's Advocate | 20 | ~85 | 0 | 0 | 0 | 0* |

*Devil's advocate issues are design challenges, not bugs — they don't have severity ratings.

**Cross-group consensus** (issue found by 2+ groups): 22 issues
**Module-wide patterns** (affecting 10+ files): 5 issues
**Total unique actionable findings after dedup:** ~45

## TOP 10 PRIORITY FIXES

1. Get-SnipeitFieldsetField — POST→GET (Critical, trivial fix)
2. Write-Debug API key leakage in Invoke-SnipeitMethod (Critical, security)
3. ConfirmImpact = "High" on all Remove-* functions (High, safety)
4. ShouldProcess target strings with actual resource IDs (High, usability)
5. Get-SnipeitAsset $requestable default filtering (High, data correctness)
6. Get-SnipeitUser $id [string]→[int] (High, security)
7. Add -DefaultExcludeParameter to all Get-ParameterValue calls (High, API correctness)
8. Fix or uncomment version/manifest tests (High, CI integrity)
9. New-SnipeitComponent $qty [string]→[int] (High, type safety)
10. Update-SnipeitAlias regex escape (High, correctness)
