// Entire exact recursive consumer, sampled copied-reference pipeline only.
import * as fs from 'node:fs';
import * as Bend from '/workspace/formal-proofs/bendvy-worktrees/parity-54-boxed-scan/experiments/public-inspect/closed-owner-carrier-v1/schema-partition-v1/garden-reference-diagnostic-v1/bend.ts';
import * as Comp from './profile-comp.ts';
import { withProfile } from '/workspace/formal-proofs/bendvy/experiments/public-inspect/closed-owner-carrier-v1/recursive-owner-v1/cpu-profile-v1/profile-helper.mjs';
import { armBudget, checkBudget } from '/workspace/formal-proofs/bendvy/experiments/public-inspect/closed-owner-carrier-v1/recursive-owner-v1/cpu-profile-v1/profile-budget.mjs';
import * as Provenance from './layout-provenance.mjs';
import { joined, templateInstances } from './book-provenance.mjs';
import { publish } from './publish-provenance.mjs';
import { createHash } from 'node:crypto';
const declarations: Array<any> = [];
const book = Bend.book_nil();
const seen = new Map<string,string|null>();
const [entry, output, profilePath, provenancePath] = process.argv.slice(2);
if (!entry || !output || !profilePath || !provenancePath || [output,profilePath,provenancePath].some(path => fs.existsSync(path) || (() => { try { fs.lstatSync(path); return true; } catch (error) { if (error.code === "ENOENT") return false; throw error; } })())) throw new Error('exact entry and absent outputs required');
const started = Date.now();
function phase(event: string): void { console.error('REFERENCE_PHASE ' + JSON.stringify({event, elapsedMs: Date.now() - started})); }
let primaryError;
let primaryFailed = false;
try {
await withProfile(async () => {
  armBudget(25000);
  phase('book_load.begin');
  await Bend.book_load(book,entry,'',seen);
  phase('book_load.end');
  console.error('REFERENCE_LOADED_INPUTS ' + JSON.stringify([...seen.keys()].sort()));
  for (const [source, namespace] of seen) {
    if (namespace === null) throw new Error('incomplete loaded namespace');
    const bytes = fs.readFileSync(source);
    const sourceSHA256 = createHash('sha256').update(bytes).digest('hex');
    bytes.toString('utf8').split('\n').forEach((line, i) => {
      const match = /^def ([A-Za-z_][A-Za-z_0-9]*)/.exec(line);
      if (match) declarations.push({source, definition:match[1], line:i+1, sourceSHA256});
    });
  }
  checkBudget();
  phase('book_valid.begin');
  Bend.book_valid(book);
  phase('book_valid.end');
  if (book.hols > 0) throw new Error('incomplete source');
  checkBudget();
  Provenance.loadedBook(book);
  phase('compile_book.begin');
  const outputText = Comp.compile_book(book);
  phase('compile_book.end');
  fs.writeFileSync(output,outputText,{flag:'wx'});
  phase('write.end');
}, profilePath);

} catch (error) {
  primaryFailed = true; primaryError = error;
} finally {
 try {
  const observed = Provenance.snapshot();
  const mapping = [...new Set([...observed.definitionCounts.map(([definition]) => definition), ...observed.rows.map(row => row.definition)])].map(def => joined(def, book, seen, declarations));
  publish(provenancePath, {observed,mapping,loaded:[...seen],templateInstances:templateInstances(book),bookDefinitions:Object.entries(book.tlds).map(([key,value]) => ({key,tag:value.$,namespace:value.m ?? null}))});
 } catch (error) {
  console.error('REFERENCE_PROVENANCE_PUBLICATION_ERROR ' + String(error));
  if (!primaryFailed) throw error;
 }
}
if (primaryFailed) throw primaryError;
