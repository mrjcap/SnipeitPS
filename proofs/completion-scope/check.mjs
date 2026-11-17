import fs from 'node:fs';
import os from 'node:os';
import path from 'node:path';
import assert from 'node:assert/strict';
import { createHash } from 'node:crypto';
import { spawnSync } from 'node:child_process';
import { fileURLToPath, pathToFileURL } from 'node:url';
import { inspect, parseArgs } from 'node:util';
import * as view from './view.mjs';
const root = path.dirname(fileURLToPath(import.meta.url));
const { values: args } = parseArgs({ options: {
  statechart: { type: 'string' }, jar: { type: 'string' }, out: { type: 'string' },
} });
for (const key of ['statechart', 'jar', 'out']) assert.ok(args[key], `Missing --${key}`);
const hash = file => createHash('sha256').update(fs.readFileSync(file)).digest('hex');
assert.equal(hash(args.jar), '936a262061c914694dfd669a543be24573c45d5aa0ff20a8b96b23d01e050e88');
assert.equal(hash(path.join(args.statechart, 'run.ts')), '751d97cfde3c241bfeed8913fc74a7a7cbc6acd3829e37a441016af3eb78f0e0');
assert.equal(hash(path.join(args.statechart, 'pipeline.ts')), '8aa8d9295ab6762f7f2ffae91a0aee98b1a1314747c875edba4598fdab8ed543');
const out = path.resolve(args.out);
assert.ok(!fs.existsSync(out), 'Output must not exist');
fs.mkdirSync(out, { recursive: true });
const temporary = fs.mkdtempSync(path.join(os.tmpdir(), 'completion-chart-'));
fs.cpSync(args.statechart, temporary, { recursive: true,
  filter: source => !['node_modules', 'tests'].includes(path.basename(source)),
});
const runPath = path.join(temporary, 'run.ts');
let source = fs.readFileSync(runPath, 'utf8');
const replacements = [
  ['buf.toString("utf8", 0, cut).split("\\n")', 'buf.toString("utf8", 0, cut).split("\\n").map((line) => line.replace(/\\r+$/, ""))'],
  ['yield buf.toString("utf8", 0, kept);', 'yield buf.toString("utf8", 0, kept).replace(/\\r+$/, "");'],
  ['utf8.decode(buf.subarray(0, cut)).split("\\n")', 'utf8.decode(buf.subarray(0, cut)).split("\\n").map((line) => line.replace(/\\r+$/, ""))'],
  ['yield utf8.decode(rest);', 'yield utf8.decode(rest).replace(/\\r+$/, "");'],
];
for (const [before, after] of replacements) {
  assert.equal(source.split(before).length, 2, `Non-unique patch: ${before}`);
  source = source.replace(before, after);
}
fs.writeFileSync(runPath, source);
fs.writeFileSync(path.join(out, 'normalization.json'), JSON.stringify(replacements, null, 2));
const load = relative => import(pathToFileURL(path.join(temporary, relative)).href);
const { check, fileLines } = await load('run.ts');
const { compile } = await load('pipeline.ts');
const { checkView, json } = await load('frontends/view.ts');
const { readCounterexample } = await load('frontends/marks.ts');
const { plainText } = await load('backends/plain-text.ts');
fs.writeFileSync(path.join(temporary, 'line-probe.ts'), source + '\nexport { outputLines };\n');
const { outputLines } = await load('line-probe.ts');
fs.writeFileSync(path.join(temporary, 'line-original.ts'),
  fs.readFileSync(path.join(args.statechart, 'run.ts'), 'utf8') + '\nexport { outputLines };\n');
const original = await load('line-original.ts');
for (const ending of ['\n', '\r\n', '\r\r\n']) {
  const bytes = Buffer.from(`first${ending}last\r\r`);
  const fixture = path.join(temporary, 'lines.txt');
  fs.writeFileSync(fixture, bytes);
  assert.deepEqual([...fileLines(fixture)], ['first', 'last']);
  assert.deepEqual([...outputLines([bytes.subarray(0, 3), bytes.subarray(3)])], ['first', 'last']);
  assert.notDeepEqual([...original.fileLines(fixture)], ['first', 'last']);
  assert.notDeepEqual([...original.outputLines([bytes])], ['first', 'last']);
}
assert.throws(() => checkView({ state: 7 }, inspect), /state must be a function/);
const checkedView = checkView(view, inspect);
process.env.TLA2TOOLS = path.resolve(args.jar);
const rules = ['TypeOK', 'DefaultServerIsolation', 'DefaultCredentialIsolation',
  'ExplicitSessionIsolation', 'FailureDoesNotFreshen', 'CleanupRemovesEntry'];
const broken = rules.slice(1, 4);
const summary = { node: process.version, java: process.env.JAVA || 'java', bounds: 4,
  controls: ['LF/CRLF/CRCRLF fileLines and outputLines', 'invalid view rejected'], runs: [] };
for (const policy of ['observed', 'reference']) {
  const target = path.join(out, policy);
  fs.mkdirSync(target);
  fs.copyFileSync(path.join(root, 'CompletionScope.tla'), path.join(target, 'CompletionScope.tla'));
  const result = await check(path.join(root, 'CompletionScope.tla'), path.join(root, `${policy}.cfg`));
  const { files, exit } = compile(result, checkedView);
  for (const [name, parts] of files) {
    const fd = fs.openSync(path.join(target, name), 'wx');
    try { for (const part of parts) fs.writeSync(fd, typeof part === 'string' ? Buffer.from(part) : part); }
    finally { fs.closeSync(fd); }
  }
  assert.equal(exit, policy === 'observed' ? 1 : 0);
  if (policy === 'observed') {
    assert.throws(() => compile(result, checkView({ ...view, step: () => null }, inspect)), /returned null.*path to.*bug/);
    summary.controls.push('hidden counterexample steps rejected');
  }
  const traces = [];
  for (const entry of result.rules) {
    const name = entry.rule.name;
    const trace = readCounterexample(entry.messages ?? []).map(({ action, vars }) => ({ action,
      state: Object.fromEntries(Object.entries(vars).map(([key, value]) => [key, json(value)])),
    }));
    if (trace.length) {
      traces.push({ rule: name, trace });
      fs.writeFileSync(path.join(target, `${name}.txt`), [...plainText(entry.messages)].join(''));
    }
  }
  assert.deepEqual(traces.map(t => t.rule).sort(), policy === 'observed' ? [...broken].sort() : []);
  fs.writeFileSync(path.join(target, 'traces.json'), JSON.stringify(traces, null, 2));
  const independent = [];
  for (const rule of rules) {
    const cfg = path.join(target, `${rule}.cfg`);
    fs.writeFileSync(cfg, fs.readFileSync(path.join(root, `${policy}.cfg`), 'utf8')
      .replace(/INVARIANTS[^\n]+/, `INVARIANT ${rule}`));
    const raw = spawnSync(process.env.JAVA || 'java', ['-cp', path.resolve(args.jar), 'tlc2.TLC',
      '-tool', '-workers', '1', '-fp', '0', '-lncheck', 'final', '-metadir', path.join(target, `states-${rule}`),
      '-config', `${rule}.cfg`, 'CompletionScope'], { cwd: target, encoding: 'utf8', maxBuffer: 32 * 1024 * 1024 });
    assert.ifError(raw.error);
    fs.writeFileSync(path.join(target, `independent-${rule}.out`), raw.stdout + raw.stderr);
    const expectedFailure = policy === 'observed' && broken.includes(rule);
    assert.equal(raw.status, expectedFailure ? 12 : 0, `${policy}/${rule}: ${raw.stdout}`);
    assert.equal(raw.stdout.includes(`Invariant ${rule} is violated`), expectedFailure);
    independent.push({ rule, exit: raw.status, counts: raw.stdout.match(/^\d+ states generated[^\n]*/gm) });
  }
  summary.runs.push({ policy, wrapperExit: exit, independent });
}
fs.writeFileSync(path.join(out, 'summary.json'), JSON.stringify(summary, null, 2));
console.log(JSON.stringify(summary, null, 2));
fs.rmSync(temporary, { recursive: true, force: true });
