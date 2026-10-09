// Portable synthetic Book/identity refusal controls. No Bend compiler imports.
import * as fs from 'node:fs';import * as os from 'node:os';import * as path from 'node:path';
import {capture} from './checked-book.mjs';import {validate} from './witness-gate.mjs';
const root=fs.mkdtempSync(path.join(os.tmpdir(),'bendvy-checked-book-'));
const entry=path.join(root,'entry.bend');fs.writeFileSync(entry,'def main(): 0\ndef target(~A): 0\ndef targetSimilar(): 1\n');
const Bend={term_lower:x=>x,term_key:x=>JSON.stringify(x)};
const Def=(n,x,v)=>({$:'Def',n,x,T:{type:'T'},v:{body:v},e:{checked:v}});
const make=()=>({hols:0,order:['main','target','targetSimilar'],ctrs:{},tlds:{main:Def(0,0,'main'),target:Def(1,1,'authored-target'),'target~0':Def(0,0,'checked-instantiation'),targetSimilar:Def(0,0,'unrelated')},tmps:{target:new Map([['closed-Array-type','target~0']])}});
function refuse(f){try{f();}catch{return;}throw new Error('mutated/unrelated identity accepted');}
try {
 const beforeBook=make(),afterBook=make();const before=capture(Bend,beforeBook,entry),after=capture(Bend,afterBook,entry);
 const baseline=[{kind:'decision',caller:'main',callee:'target~0',oldEligible:true,flat:false},{kind:'fuse',caller:'main',callee:'target~0',flat:false,tail:true}];
 const candidate=[{kind:'jump',caller:'main',callee:'target~0'}];
 validate('erased-specialization',baseline,candidate,before,after);
 for(const unrelated of ['target','target~00','targetSimilar','Other.target~0'])refuse(()=>validate('erased-specialization',baseline.map(r=>({...r,callee:unrelated})),candidate,before,after));
 beforeBook.tmps.target.set('closed-Array-type','targetSimilar');refuse(()=>before.verify());
 const changedBook=make(),changed=capture(Bend,changedBook,entry);changedBook.tlds['target~0']=changedBook.tlds.targetSimilar;refuse(()=>changed.verify());
 const replacedBook=make(),replaced=capture(Bend,replacedBook,entry);replacedBook.tlds['target~0']={...replacedBook.tlds['target~0']};refuse(()=>replaced.verify());
 const bodyBook=make(),body=capture(Bend,bodyBook,entry);bodyBook.tlds['target~0'].v={body:'wrong-source-body'};refuse(()=>body.verify());
 const invalid=make();invalid.tlds['target~0'].n=8;refuse(()=>capture(Bend,invalid,entry));
 const foreign=make();foreign.tmps.target.set('closed-Array-type','targetSimilar');refuse(()=>capture(Bend,foreign,entry));
 const shifted=make();shifted.tlds['target~1']=shifted.tlds['target~0'];shifted.tmps.target.set('closed-Array-type','target~1');refuse(()=>capture(Bend,shifted,entry));
 refuse(()=>validate('erased-specialization',baseline,candidate,before,{...after,bindingSHA256:'altered'}));
 const cacheBook=make(),cache=capture(Bend,cacheBook,entry);cacheBook.tlds['target~0'].e.checked='normalized-cache';cache.verify();
 const rootBook=make(),rootGuard=capture(Bend,rootBook,entry);rootBook.tlds['target~0'].e={...rootBook.tlds['target~0'].e};refuse(()=>rootGuard.verify());
 after.verify();fs.appendFileSync(entry,'# altered source\n');refuse(()=>after.verify());
 console.log('SYNTHETIC_CHECKED_BOOK_IDENTITY_PASS: exact map, source Def/reference/body/key and similar-name refusals; no compiler');
}finally{fs.rmSync(root,{recursive:true,force:true});}
