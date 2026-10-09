// Copied compiler controls only; old/new branch witnesses are actual emitter events.
import * as fs from 'node:fs';
import * as path from 'node:path';
import {validate} from './witness-gate.mjs';
import {capture,snapshot} from './checked-book.mjs';
import * as Bend from '/workspace/formal-proofs/bendvy/.references/bend2/bend2/bend.ts';
import * as Before from './baseline.comp.ts';
import * as After from './candidate.comp.ts';
const [output]=process.argv.slice(2);
if(!output || fs.existsSync(output)) throw new Error('absent report required');
const names=['physical-owners','erased-specialization','parallel-return','recursive-tail','layout-cut'];
const rows:unknown[]=[];let active:Record<string,unknown>|null=null;let failure:unknown=null;
async function load(entry:string) {
 const book=Bend.book_nil();await Bend.book_load(book,entry,'',new Map());Bend.book_valid(book);
 if(book.hols)throw new Error('control source holes');return book;
}
try {
 for(const name of names) {
  const entry=path.join(import.meta.dirname,name+'.bend');active={name,entry};
  console.error('BOUNDARY_CONTROL_BEGIN '+name);
  Before.diagnosticBoundaryReset();
  const baselineBook=await load(entry);const baselineSnapshot=snapshot(Bend,baselineBook,entry);
  Object.assign(active,{baselineCheckedBook:baselineSnapshot.artifact,baselineBookSHA256:baselineSnapshot.sha256});
  const baselineIdentity=capture(Bend,baselineBook,entry,baselineSnapshot);Object.assign(active,{baselineAllowed:baselineIdentity.allowed});
  const baselineC=Before.compile_book(baselineBook);
  const baselineWitness=Before.diagnosticBoundaryRows() as any[];
  Object.assign(active,{baselineC,baselineWitness,baselineCheckedBookAfter:snapshot(Bend,baselineBook,entry)});
  baselineIdentity.verify();
  After.diagnosticBoundaryReset();
  const candidateBook=await load(entry);const candidateSnapshot=snapshot(Bend,candidateBook,entry);
  Object.assign(active,{candidateCheckedBook:candidateSnapshot.artifact,candidateBookSHA256:candidateSnapshot.sha256});
  const candidateIdentity=capture(Bend,candidateBook,entry,candidateSnapshot);Object.assign(active,{candidateAllowed:candidateIdentity.allowed});
  const candidateC=After.compile_book(candidateBook);
  const candidateWitness=After.diagnosticBoundaryRows() as any[];
  Object.assign(active,{candidateC,candidateWitness,candidateCheckedBookAfter:snapshot(Bend,candidateBook,entry)});
  candidateIdentity.verify();
  validate(name,baselineWitness,candidateWitness,baselineIdentity,candidateIdentity);
  rows.push(active);active=null;console.error('BOUNDARY_CONTROL_EMITTED '+name);
 }
}catch(error){failure=error;throw error;}
finally {
 const report={scope:'Actual copied compiler emission/branch witnesses only; Native full logical gates pending',status:failure===null?'EMISSION_CONTROLS_PASS':'INCOMPLETE',cases:rows,active,error:failure===null?null:String(failure)};
 try{fs.writeFileSync(output,JSON.stringify(report),{flag:'wx'});}catch(writeError){if(failure===null)throw writeError;console.error('REPORT_WRITE_FAILURE '+String(writeError));}
}
