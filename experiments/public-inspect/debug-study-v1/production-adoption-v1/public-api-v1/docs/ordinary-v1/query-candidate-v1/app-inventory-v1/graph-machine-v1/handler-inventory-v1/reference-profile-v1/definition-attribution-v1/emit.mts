// Entire exact recursive consumer, sampled copied-reference pipeline only.
import * as fs from 'node:fs';
import * as Bend from './compiler/bend.ts';
import * as Comp from './compiler/comp.ts';
import { withProfile } from './compiler/profile-helper.mjs';
import { armBudget, checkBudget } from './compiler/profile-budget.mjs';
const [entry, output, profilePath] = process.argv.slice(2);
if (!entry || !output || !profilePath || fs.existsSync(output) || fs.existsSync(profilePath)) throw new Error('exact entry and absent outputs required');
const started = Date.now();
function phase(event: string): void { console.error('REFERENCE_PHASE ' + JSON.stringify({event, elapsedMs: Date.now() - started})); }
await withProfile(async () => {
  armBudget(25000);
  const book = Bend.book_nil();
  const seen = new Map<string,string|null>();
  phase('book_load.begin');
  await Bend.book_load(book,entry,'',seen);
  phase('book_load.end');
  console.error('REFERENCE_LOADED_INPUTS ' + JSON.stringify([...seen.keys()].sort()));
  checkBudget();
  phase('book_valid.begin');
  Bend.book_valid(book);
  phase('book_valid.end');
  if (book.hols > 0) throw new Error('incomplete source');
  checkBudget();
  phase('compile_book.begin');
  try {
    const outputText = Comp.compile_book(book);
    phase('compile_book.end');
    fs.writeFileSync(output,outputText,{flag:'wx'});
    phase('write.end');
  } finally {
    try { Comp.diagnostic_definitions(); } catch (error) { console.error('REFERENCE_DEFINITION_REPORT_ERROR ' + String(error)); }
  }
}, profilePath);
