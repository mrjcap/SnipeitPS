import fs from 'node:fs';
import path from 'node:path';
import { createRequire } from 'node:module';
import { fileURLToPath } from 'node:url';
import { parseArgs } from 'node:util';
const { values } = parseArgs({ options: { parser: { type: 'string' } } });
const ts = createRequire(import.meta.url)(path.resolve(values.parser));
const root = path.dirname(fileURLToPath(import.meta.url));
const output = [];
for (const name of fs.readdirSync(root).filter(name => name.endsWith('.mjs'))) {
  const source = ts.createSourceFile(name, fs.readFileSync(path.join(root, name), 'utf8'),
    ts.ScriptTarget.Latest, true, ts.ScriptKind.JS);
  if (source.parseDiagnostics.length) throw new Error(`Parse failure: ${name}`);
  let units = 1;
  let decisions = 0;
  const counted = new Set([ts.SyntaxKind.IfStatement, ts.SyntaxKind.ForStatement,
    ts.SyntaxKind.ForOfStatement, ts.SyntaxKind.ForInStatement, ts.SyntaxKind.WhileStatement,
    ts.SyntaxKind.DoStatement, ts.SyntaxKind.CatchClause, ts.SyntaxKind.CaseClause,
    ts.SyntaxKind.ConditionalExpression]);
  const logical = new Set([ts.SyntaxKind.AmpersandAmpersandToken,
    ts.SyntaxKind.BarBarToken, ts.SyntaxKind.QuestionQuestionToken]);
  function visit(node) {
    if (ts.isFunctionLike(node) && node.body) units++;
    if (counted.has(node.kind)) decisions++;
    if (ts.isBinaryExpression(node) && logical.has(node.operatorToken.kind)) decisions++;
    ts.forEachChild(node, visit);
  }
  visit(source);
  output.push({ file: `proofs/completion-scope/${name}`, units, decisions, complexity: units + decisions });
}
console.log(JSON.stringify(output));
