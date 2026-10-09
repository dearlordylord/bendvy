// Source-reference diagnostic only; no installed ELF phase equivalence.
import * as fs from 'node:fs';
import * as Bend from './bend.ts';
import * as Comp from './comp.ts';
const [entry, output] = process.argv.slice(2);
if (!entry || !output || fs.existsSync(output)) throw new Error('exact entry and absent output required');
const started = Date.now();
function phase(event: string): void { console.error('REFERENCE_PHASE ' + JSON.stringify({event, elapsedMs: Date.now() - started})); }
const book = Bend.book_nil();
const seen = new Map<string,string|null>();
phase('book_load.begin');
await Bend.book_load(book,entry,'',seen);
phase('book_load.end');
console.error('REFERENCE_LOADED_INPUTS ' + JSON.stringify([...seen.keys()].sort()));
phase('book_valid.begin');
Bend.book_valid(book);
phase('book_valid.end');
if (book.hols > 0) throw new Error('incomplete source');
phase('compile_book.begin');
const outputText = Comp.compile_book(book);
phase('compile_book.end');
fs.writeFileSync(output,outputText,{flag:'wx'});
phase('write.end');
