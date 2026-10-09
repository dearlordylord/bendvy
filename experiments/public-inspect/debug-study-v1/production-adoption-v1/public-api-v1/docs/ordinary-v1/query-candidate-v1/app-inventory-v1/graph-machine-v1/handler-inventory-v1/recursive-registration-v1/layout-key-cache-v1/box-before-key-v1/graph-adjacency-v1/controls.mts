// Source-prepared differential compiler controls; no installed tool/native runtime.
import * as fs from 'node:fs';
import * as path from 'node:path';
import { createHash } from 'node:crypto';
import * as Bend from '../baseline/bend.ts';
import * as Before from '../optimized/comp.ts';
import * as After from './optimized/comp.ts';
import { withProfile } from '../baseline/profile-helper.mjs';
import { armBudget, checkBudget } from '../baseline/profile-budget.mjs';
const [output,profilePath]=process.argv.slice(2);
if (!output || !profilePath || fs.existsSync(output) || fs.existsSync(profilePath)) throw new Error('exact absent outputs required');
const names=['array','nested-array','io-op','recursive-list','recursive-owner','mutual-recursion','family-cycle','parameter-products'];
const sha=(text:string)=>createHash('sha256').update(text).digest('hex');
const rows:unknown[]=[];
let active:Record<string,unknown>|null=null;
let primaryFailure:unknown=null;
async function loaded(entry:string) {
  const book=Bend.book_nil();const seen=new Map<string,string|null>();
  await Bend.book_load(book,entry,'',seen);Bend.book_valid(book);
  if(book.hols>0)throw new Error('incomplete control source: '+entry);
  return book;
}
function errorOf(action:()=>unknown):string {
  try {action();}catch(error){return error instanceof Error?error.message:String(error);}
  throw new Error('open element was unexpectedly accepted');
}
try {
await withProfile(async()=>{
  armBudget(25000);
  for(const name of names) {
    checkBudget();const entry=path.join(import.meta.dirname,'../cases',name+'.bend');
    active={name};
    console.error('BOX_CONTROL_BEGIN '+name);
    const beforeBook=await loaded(entry);const afterBook=await loaded(entry);
    Before.diagnosticResetLayouts();After.diagnosticResetLayouts();
    const beforeType=Bend.tele_unbind(beforeBook,beforeBook.tlds.main.T).ret;
    const afterType=Bend.tele_unbind(afterBook,afterBook.tlds.main.T).ret;
    const beforeLayout=Before.diagnosticLayout(beforeBook,beforeType);
    const afterLayout=After.diagnosticLayout(afterBook,afterType);
    Object.assign(active,{beforeLayout,afterLayout});
    if(beforeLayout!==afterLayout)throw new Error('layout mismatch: '+name);
    const unit=Bend.ADT('Unit',[]);
    const opBefore=Before.diagnosticLayout(beforeBook,Bend.ADT('IO.OP',[unit]));
    const opAfter=After.diagnosticLayout(afterBook,Bend.ADT('IO.OP',[unit]));
    if(opBefore!==opAfter)throw new Error('IO.OP layout mismatch: '+name);
    const openBefore=errorOf(()=>Before.diagnosticArrayElement(beforeBook,Bend.Var('Open',0)));
    const openAfter=errorOf(()=>After.diagnosticArrayElement(afterBook,Bend.Var('Open',0)));
    if(openBefore!==openAfter||openBefore!=='an open Array element type')throw new Error('open element error mismatch: '+name);
    const boundBefore=Bend.Var('Bound',-1,undefined,Bend.ADT('U32',[]));
    const boundAfter=Bend.Var('Bound',-1,undefined,Bend.ADT('U32',[]));
    const arrayBefore=Before.diagnosticLayout(beforeBook,Bend.ADT('Array',[boundBefore]));
    const arrayAfter=After.diagnosticLayout(afterBook,Bend.ADT('Array',[boundAfter]));
    if(arrayBefore!==arrayAfter)throw new Error('boundVar Array layout mismatch: '+name);
    console.error('BOX_CONTROL_BOUND_VAR '+JSON.stringify({name,before:{index:boundBefore.i,head:boundBefore.v?.$},after:{index:boundAfter.i,head:boundAfter.v?.$}}));
    const beforeC=Before.compile_book(beforeBook);Object.assign(active,{beforeC});checkBudget();
    const afterC=After.compile_book(afterBook);Object.assign(active,{afterC});checkBudget();
    if(beforeC!==afterC)throw new Error('emitted C byte mismatch: '+name);
    const row={name,layout:beforeLayout,ioOpLayout:opBefore,openElementError:openBefore,baselineCSHA256:sha(beforeC),optimizedCSHA256:sha(afterC),emittedC:beforeC};
    rows.push(row);active=null;console.error('BOX_CONTROL_PASS '+JSON.stringify({name,cSHA256:sha(beforeC),bytes:Buffer.byteLength(beforeC)}));
  }
},profilePath);
} catch(error) {
  primaryFailure=error;
  throw error;
} finally {
  // Retain actual completed/active C strings even on a mismatch or cutoff.
  // A report-write refusal must not replace the original compiler failure.
  try {
    fs.writeFileSync(output,JSON.stringify({scope:'Copied-only exact layout/C differential; no installed compiler or runtime',status:primaryFailure===null?'CONTROL_PASS':'INCOMPLETE',cases:rows,active,error:primaryFailure===null?null:primaryFailure instanceof Error?primaryFailure.message:String(primaryFailure)}),{flag:'wx'});
  } catch(writeError) {
    if(primaryFailure===null)throw writeError;
    console.error('BOX_CONTROL_REPORT_FAILURE '+String(writeError));
  }
}
