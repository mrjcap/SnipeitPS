# Bounded connection-scope evaluation

Recommendation: **limited use for design reviews**, not a runtime dependency or
replacement for Pester. This draft changes no application code and fixes nothing.
The existing cross-server cache finding is the baseline, not a new discovery.

## Intended contract

This is a proposed completion contract, not a claim that the current public API
already promises all of it:

1. Select an explicitly supplied `Session`, otherwise the stored default session.
2. Treat normalized HTTPS base URL plus an opaque credential/authorization
   identity as the scope. A different credential on the same server is a different
   scope. Never persist or display a real token to implement this identity.
3. Return only suggestions belonging to that selected scope. A fresh cache must
   not override scope selection. Passing `Session` must affect both fetch and
   cache selection.
4. Clear, expiry and module removal must prevent reuse of fresh old rows. An
   empty or failed fetch must not freshen an expired entry.

"Default" means the session actually stored when completion starts, not the last
verified connection. `Connect-SnipeitPS` publishes the candidate before probing
and throws if verification fails, without rolling it back. The failed-probe
control characterizes that behavior; this draft does not redesign reconnects.

## Observations and abstraction

Source anchors, relative to the repository root:

- `SnipeitPS/Classes/SnipeitCache.ps1`: entity-only key, TTL, synchronized factory,
  and no caching of null/empty factory output. An expired old entry can remain.
- `SnipeitPS/Classes/SnipeitCompleters.ps1`: model completer uses `Models`, a
  300-second TTL and `Get-SnipeitModel -all`; it ignores fake bound parameters.
- `SnipeitPS/Public/Connect-SnipeitPS.ps1`: URL/key assignment before the probe;
  no cache invalidation.
- `SnipeitPS/Private/Test-SnipeitPSConnection.ps1` and
  `SnipeitPS/Private/Invoke-SnipeitMethod.ps1`: real probe and dispatcher.
- `SnipeitPS/SnipeitPS.psm1`: module removal clears the cache.

The model has three opaque contexts: A1 (server A, credential 1, model 11), A2
(same server, credential 2, model 33), and B1 (server B, credential 3, model 22).
Disjoint rows make provenance observable. Real deployments may have overlapping
IDs, so tests also check display names and the HTTP route/identity.

`observed.cfg` models the current single cache entry and ignored explicit
session. `reference.cfg` enables a conceptual single-slot scoped policy that
honors explicit selection. The latter is a **model-only positive control**,
not an implemented fix or an optimal multi-key cache design.

The bound is four macro operations after initialization, with 11 choices at each
step. Connect includes publishing URL/key and probing. `UnloadReload` combines
real module removal, import and connection to A1. Failure/empty macros combine
expiry and a lookup. These are sequential, atomic abstractions, not proofs of
interleavings inside those operations. Tests cover those controls separately;
only generated counterexamples are replayed as entire model traces.

No symmetry, VIEW reduction, temporal property, fairness, concurrency, capacity
pruning, wall-clock drift, pagination variation, authorization revocation with
an unchanged token, other entity completers, or live server is modeled.
`CHECK_DEADLOCK FALSE` deliberately excludes deadlock checking at the operation
bound. There is no liveness or unbounded safety claim.

## Results and added assurance

| Check | Observed policy | Reference control |
| --- | --- | --- |
| Type, freshness, cleanup | Hold within bound | Hold within bound |
| Default server isolation | Fails | Holds within bound |
| Same-server credential isolation | Fails | Holds within bound |
| Explicit session isolation | Fails | Holds within bound |
| Full graph size | 186 states, 1,100 edges | 187 states, 1,243 edges |

Independent Java TLC runs check each of the six invariants separately. Each
observed isolation failure exits 12; the other nine checks exit 0. The wrapper
reports the same verdicts, with overall exits 1 and 0 respectively. The local
`check.mjs` exits 0 only when both those expected outcomes and its controls match.
Raw counts are not executable cyclomatic complexity or test coverage.

Generated paths, including initialization as step 0:

- Server: 0 connect A1; 1 complete default (11); 2 connect B1;
  3 complete default (11, contract requires 22).
- Credential: 0 connect A1; 1 complete default (11); 2 connect A2;
  3 complete default (11, contract requires 33).
- Explicit: 0 connect A1; 1 complete with B1 Session (11, contract requires 22).

The passing replay run characterizes all three paths action by action and adds
six positive controls, for 9/9 passing tests. A separate `-Negative` run adds the
contract assertion at the end of each witness: exactly three failures and six
passes are intentional. An unexpected failure, skipped test or container error
is not an acceptable negative control. The exact-revision full-suite outcome
belongs in the PR verification record, not in these intended outcomes.

Only `Invoke-RestMethod` and `Invoke-WebRequest` are mocked in these tests.
Connect, probe, completer, cache, getter, session selection and dispatcher are
real. The canonical runner adds process-local network guards and requires
Pester 5.8.0. Requests use `.invalid` hosts and dummy tokens, never live credentials.

The old replay mocked both `Get-SnipeitModel` and the probe. Its existing
cross-server witness and old 23-pass/1-intentional-failure result do not prove
the HTTP path. This draft adds that path, same-server credentials, explicit
selection, and systematic bounded ordering exploration. It does not establish
a newly discovered production vulnerability. Three short HTTP-only Pester
examples can catch these same mismatches without TLA+; Pester remains the
cheaper regression guard for this particular problem.

## What the chart does and does not prove

TLC explores the written transition system under the written configuration.
It does not inspect or execute PowerShell. Replay links three witnesses to the
application, not every explored state or every future implementation change.
The reference model passing proves nothing about a production fix.

The pure `view.mjs` functions label only their arguments and hide no steps.
Labels retain every variable, including the operation count, so distinct
modeled states do not merge. Raw TLC actions say `Next`; the event field supplies
macro action labels. The charts are deliberately large diagnostic artifacts,
not readable product documentation. See `evidence/observed.mmd` and
`evidence/reference.mmd`. SVG rendering with Pele was not checked because Pele
was unavailable; Mermaid text was generated, not independently rendered.

Statechart validates view export types and label shapes at runtime, not purity,
semantic truth, or correspondence with PowerShell. Controls reject an invalid
view export and a view that hides all counterexample steps.

## Tool pin and Windows limits

The inspected upstream is [cursor/plugins statechart][statechart] at commit
`bf0c7cd80abdbf7fe47b634978a7d1b4071f71a7`. Read its skill and implementation;
it is not a general PowerShell analyzer. Do not vendor its source into this module.

[statechart]: https://github.com/cursor/plugins/tree/bf0c7cd80abdbf7fe47b634978a7d1b4071f71a7/pstack/skills/statechart

`check.mjs` accepts an external scripts directory. It enforces SHA-256 pins for
`run.ts`, `pipeline.ts` and TLC 1.7.4, and trusts the remaining files from that
pinned checkout. It copies the toolkit to a disposable directory and applies
exactly four unique replacements to `run.ts`: strip trailing CRs on the split
and final lines in both `fileLines` and `outputLines`. No installed file changes.
`normalization.json` records the replacements. Separate diagnostic copies export
`outputLines` only to test both paths with LF, CRLF and CRCRLF, chunked input and
a final CR-terminated line without a newline. Unmodified functions serve as
negative controls. Actual TLC output also passes through the patched readers.

The stock launcher and cancellation code spawn absolute `/bin/sh`. The local
runner bypasses the launcher and calls `check`, `compile` and `checkView`
directly; it does not repair POSIX process-group cleanup, detached workers,
staging or cancellation. Do not call it generally portable. Failed runs may
leave disposable directories for diagnosis. This is Windows PS7 evidence only,
not Windows PowerShell 5.1 or Linux/macOS evidence.

Verified tool versions: Node 26.13.1, Microsoft Java 17.0.21 and Pester 5.8.0.
The jar is from release v1.7.4; its own TLC banner reports version 2.19.
The independent raw transcript preserves Windows CR/CRCRLF line endings.
Native TS execution needs a supported runtime; the upstream shell launcher
accepts Node 22.18.x-22.x or 23.6+, Bun 1.1.5+, or Deno 2.0+. This local runner
uses Node APIs. It supplies `TLA2TOOLS` explicitly, so it never invokes the
upstream automatic mise Java/TLC installation path. No package was installed.

## Reproduce offline

Provision the pinned external checkout and TLC jar yourself. This draft neither
installs nor downloads dependencies. From the repository root in PowerShell 7,
use fresh output paths outside the repository:

```powershell
$tool = 'C:/external/plugins/pstack/skills/statechart/scripts'
$jar = 'C:/external/tla2tools.jar'
$out = 'C:/temp/completion-proof-new'
node proofs/completion-scope/check.mjs --statechart $tool --jar $jar --out $out
pwsh -NoProfile -NonInteractive -File proofs/completion-scope/VerifyReplay.ps1 `
  -Traces "$out/observed/traces.json" -ResultFile "$out/replay.xml"
pwsh -NoProfile -NonInteractive -File proofs/completion-scope/VerifyReplay.ps1 `
  -Traces "$out/observed/traces.json" -ResultFile "$out/negative.xml" -Negative
# The previous command must fail, only for the three final contract assertions.
pwsh -NoProfile -NonInteractive -File run-tests.ps1 -ResultFile "$out/full.xml"
$measure = 'proofs/completion-scope/MeasureComplexity.ps1'
pwsh -NoProfile -NonInteractive -File $measure `
  -TypeScriptParser 'C:/external/typescript/lib/typescript.js'
```

The optional measurement uses an already available TypeScript parser, not a
runtime or module dependency. No TypeScript static type check is implied.
`summary.json`, per-rule independent TLC output, raw witness text, traces,
Mermaid and reports are written under `$out`. Checked-in evidence is a sample
from the same proof sources; the PR records the final SHA and fresh checks.

## Complexity and scores

The reproducible AST metric sums one per PS script block (including anonymous
blocks), or JS function plus module, then adds if clauses, loops, catches,
nondefault cases, ternaries and short-circuit Boolean decisions. Regex and TLA+
syntax are excluded. Unresolved PS type names are ignored for AST measurement,
not for execution tests. This is a stated decision-count variant of cyclomatic
complexity, not a claim that all tools will report identical numbers.

The four inspected production files measure 21 + 45 + 14 + 186 = 266 before
and after: **delta 0**. They are byte-identical to the base revision. New proof
executables measure 113 versus 0 before: **delta +113**, including tests and the
measurement tools themselves. Two disposable CR-normalization map callbacks add
+2 to the external toolkit by this method; its source is not committed here.
No executable simplification occurred.

Scores use 0 (worst) through 5 (best), for this application problem:

| Dimension | Score | Confidence |
| --- | --- | --- |
| Model/config/view API | 3 | High |
| Public PowerShell API improvement | 0 | High |
| Type safety | 2 | High |
| Testability | 4 | High |
| Executable complexity | 1 | High |
| Documentation quality | 3 | Medium |
| Operational fit | 2 | High |

- Model API: small interface, but subtle bounds and projection semantics.
- Public API: no production change.
- Types: TypeOK and view checks help; TS stripping, JS and fake-bound maps do not.
- Tests: deterministic witnesses and faults; expiry diagnostics use private state.
- Complexity: production delta 0 and proof delta +113, with no simplification.
- Docs: raw evidence and reproduction, but large charts and a manual abstraction.
- Operations: development-only dependencies and a Windows launcher workaround.

PowerShell contracts still rely on typed `SnipeitSession`, parameter validation,
HTTP behavior and Pester. TLA TypeOK applies only to the finite model; it neither
adds TS static checking nor strengthens runtime PowerShell contracts.

Production requirements are unchanged: no Node, Java, TLC, renderer or new
module dependency. The unchanged `.gitlab-ci.yml` uses Windows-tagged
Test/Verification jobs invoking `powershell.exe` and the canonical runner;
Integration is protected/manual. These opt-in tests live outside root
`Tests/*.Tests.ps1`, so current CI does not discover or validate this proof.
Adding a proof job or supporting PS5.1 requires a separate approved change.

Adopt selectively when competing cache/invalidation policies or asynchronous
orderings justify maintaining a model. Prefer HTTP-only Pester for this known,
small synchronous defect. Reconsider broader adoption after native Windows
supervision, independently rendered diagrams, PS5.1 validation and automated
model-to-code conformance checks are available. Effort and maintenance increase;
monetary cost was not measured. This draft makes no deployment or merge proposal.
