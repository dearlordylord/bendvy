// Exact qualified copied candidate compiler; no installed ELF attribution.
import fs from 'node:fs';
import * as Bend from '/workspace/formal-proofs/bendvy/.references/bend2/bend2/bend.ts';
import * as Candidate from './candidate.comp.ts';
const [entry,output,witness]=process.argv.slice(2);
let primary:unknown=null;
try {
 console.error('FULL71_BOOK_LOAD_BEGIN');const book=Bend.book_nil();await Bend.book_load(book,entry,'',new Map());console.error('FULL71_BOOK_LOAD_END');
 console.error('FULL71_BOOK_VALID_BEGIN');Bend.book_valid(book);console.error('FULL71_BOOK_VALID_END');
 if(book.hols!==0)throw Error('complete book holes');
 Candidate.diagnosticBoundaryReset();console.error('FULL71_COMPILE_BEGIN');
 const c=Candidate.compile_book(book);fs.writeFileSync(output,c,{flag:'wx'});console.error('FULL71_COMPILE_END');
}catch(error){primary=error;throw error;}
finally {
 try{fs.writeFileSync(witness,JSON.stringify({scope:'Copied compiler diagnostic only; source-current full consuming entry',entry,error:primary===null?null:String(primary),rows:Candidate.diagnosticBoundaryRows()}),{flag:'wx'});}
 catch(error){if(primary===null)throw error;console.error('SECONDARY_WITNESS_CAPTURE_FAILURE '+String(error));}
}
