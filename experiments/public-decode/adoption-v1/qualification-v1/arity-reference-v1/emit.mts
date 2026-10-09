// Reference-pipeline diagnostic only; no installed compiler source binding.
import * as fs from 'node:fs';
import * as Bend from './bend.ts';
import * as Comp from './comp.ts';
const [entry, output] = process.argv.slice(2);
if (!entry || !output) throw new Error('exact entry and output required');
if (fs.existsSync(output)) throw new Error('output must start absent');
const book = Bend.book_nil();
const seen = new Map<string,string|null>();
await Bend.book_load(book,entry,'',seen);
Bend.book_valid(book);
if (book.hols > 0) throw new Error('incomplete source');
console.error('REFERENCE_LOADED_INPUTS ' + JSON.stringify([...seen.keys()].sort()));
fs.writeFileSync(output,Comp.compile_book(book),{flag:'wx'});
