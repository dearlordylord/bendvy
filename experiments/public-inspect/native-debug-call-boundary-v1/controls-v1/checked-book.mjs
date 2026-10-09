// Diagnostic representation of the checked Book, not an alternative checker.
import * as fs from 'node:fs';
import {createHash} from 'node:crypto';
const sha=value=>createHash('sha256').update(value).digest('hex');
export function snapshot(Bend,book,entry) {
 const source=fs.readFileSync(entry);
 const term=x=>x==null?null:Bend.term_key(Bend.term_lower(x));
 const definitions={};
 for(const [name,def] of Object.entries(book.tlds)) {
  definitions[name]=def.$==='Def'?{kind:def.$,n:def.n,x:def.x,T:term(def.T),v:term(def.v),e:def.e==null?null:Bend.term_key(def.e),b:def.b??null,u:def.u??null,i:def.i??null,m:def.m??null}:{kind:def.$,n:def.n,g:def.g,T:term(def.T),b:def.b??null,c:def.c.map(c=>({k:c.k,n:c.n,T:term(c.T)}))};
 }
 const artifact={sourcePath:fs.realpathSync(entry),sourceSHA256:sha(source),hols:book.hols,order:[...book.order],definitions,constructors:Object.fromEntries(Object.entries(book.ctrs).map(([k,c])=>[k,{k:c.k,n:c.n,T:term(c.T)}])),templates:Object.fromEntries(Object.entries(book.tmps).map(([k,v])=>[k,[...v.entries()]]))};
 return {artifact,sha256:sha(JSON.stringify(artifact))};
}
export function capture(Bend,book,entry,initial=snapshot(Bend,book,entry)) {
 if(book.hols!==0)throw new Error('unchecked Book holes');
 const authored=new Set([...fs.readFileSync(entry,'utf8').matchAll(/^def (\w+)\(/gm)].map(m=>m[1]));
 const allowed={};
 for(const name of ['main','target','countdown']) {
  if(!authored.has(name)){if(name==='countdown')continue;throw new Error('missing exact authored def: '+name);}
  const def=book.tlds[name];if(!def||def.$!=='Def'||def.v===null)throw new Error('missing checked source Def: '+name);
  if(def.x===0)allowed[name]=[name];
  else {
   const map=book.tmps[name];if(!(map instanceof Map)||map.size===0)throw new Error('missing checked specialization map: '+name);
   allowed[name]=[];let index=0;
   for(const [key,emitted]of map.entries()) {
    // Exact pinned instantiation algorithm (bend.ts3758–3770), not suffix matching.
    const inst=book.tlds[emitted];
    if(typeof key!=='string'||emitted!==name+'~'+index++||!inst||inst.$!=='Def'||inst.x!==0||inst.n!==def.n-def.x||inst.v===null||inst.e===undefined)throw new Error('invalid checked specialization Def: '+name);
    allowed[name].push(emitted);
   }
  }
 }
 for(const names of Object.values(allowed))Object.freeze(names);Object.freeze(allowed);
 const refs=new Map(Object.entries(book.tlds));
 function verify() {
  const after=snapshot(Bend,book,entry);
  if(after.sha256!==initial.sha256||[...refs].some(([k,v])=>book.tlds[k]!==v))throw new Error('checked Book or source Def mapping changed');
  return after;
 }
 return {...initial,allowed,verify};
}
