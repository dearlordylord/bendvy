const fs=require('fs'),vm=require('vm'),assert=require('assert'),crypto=require('crypto');
const prefix='/workspace/formal-proofs/bendvy-worktrees/observable-query-boundaries/experiments/public-inspect/promotion-stage/missing-resource-v1/direct-inspector-v1/component-query-v1/matched-timing-v1/dispatch-equivalent-v2/';
function load(file){let s=fs.readFileSync(file,'utf8'); const hash=crypto.createHash('sha256').update(s).digest('hex');s=s.replace(/^#!.*\n/,'').replace(/^import \* as (\w+) from "([^"]+)";$/gm,(_,n,m)=>`var ${n}=require(${JSON.stringify(m)});`).replaceAll('import.meta.url',JSON.stringify('file://'+file)).replaceAll('import.meta.require','require');const end=s.lastIndexOf('\nif (true) {');assert(end>0);s=s.slice(0,end);const c=vm.createContext({require,process,console,Buffer,URL,setTimeout,clearTimeout});vm.runInContext(s,c,{timeout:2000});return{c,hash};}

const file=prefix+'operation-interval-v1/timed-v1/layout-name-interner-v1/compiler/candidate.mjs';
const {c,hash}=load(file);
const result=vm.runInContext(`(()=>{
 LAY_NAMES.clear();LAYS.clear();
 const names=['','A','#0','#1','#z','0','Sigma','inspector.Frame','check.Frame','世界','a\\u0000b'];
 const terms=[];
 for(const k of names){terms.push(ADT(k,[]),Ref(k),Ctr(k,[]),ADT(k,[Ref(k),Ctr(k,[])]));}
 terms.push(ADT(0,[]),ADT(1,[]),Ref(0),Ctr(0,[]),Lit('#0',0),Var('#0',0),Hol('#0'),
 All({$:'Many'},'#0',0,ADT('A',[]),x=>ADT('Sigma',[x])),
 Lam('#0',0,x=>Ctr('C',[x])),
 ADT('A',[],{file:'one'}),ADT('A',[],{file:'two'}));
 const pairs=terms.map(t=>{const lower=term_lower(t);return [term_key(lower),lay_key(lower)]});
 let comparisons=0;
 for(let i=0;i<pairs.length;i++)for(let j=0;j<pairs.length;j++){
  if((pairs[i][0]===pairs[j][0])!==(pairs[i][1]===pairs[j][1]))throw Error('collision:'+i+':'+j);
  comparisons++;
 }
 const target=ADT('A',[Ref('B')]);const original=lay_key(term_lower(target));target.x[0].k='C';
 const changed=lay_key(term_lower(target));if(original===changed)throw Error('mutation hidden');target.x[0].k='B';if(lay_key(term_lower(target))!==original)throw Error('restored mutation');
 const cell=Var('x',0,undefined,ADT('A',[]));const before=lay_key(term_lower(cell));cell.v=ADT('B',[]);if(before===lay_key(term_lower(cell)))throw Error('Var mutation hidden');
 const ids=[...LAY_NAMES.entries()];if(new Set(ids.map(x=>x[1])).size!==ids.length)throw Error('noninjective names');
 LAYS.set(original,BOX);LAY_NAMES.clear();LAYS.clear();if(LAYS.size!==0||LAY_NAMES.size!==0)throw Error('epoch');
 const second=terms.slice().reverse().map(t=>{const lower=term_lower(t);return [term_key(lower),lay_key(lower)]});
 for(let i=0;i<second.length;i++)for(let j=0;j<second.length;j++)if((second[i][0]===second[j][0])!==(second[i][1]===second[j][1]))throw Error('epoch collision');
 const oldChars=pairs.reduce((n,p)=>n+p[0].length,0),newChars=pairs.reduce((n,p)=>n+p[1].length,0);LAY_NAMES.set('sentinel','#zz');LAYS.set('sentinel',BOX);file_book(book_nil(),[],false);if(LAY_NAMES.size||LAYS.size)throw Error('actual file_book reset');return {actualFileBookReset:true,oldChars,newChars,terms:terms.length,comparisons,mutation:true,VarMutation:true,epoch:true,internedNames:ids.length};
})()`,c,{timeout:2000});
const oldFile=prefix+'operation-interval-v1/timed-v1/inline-layout-15-word-spine-v2/compiler/candidate.mjs';
const layouts=[];
for(const compiler of [oldFile,file]){const a=load(compiler);a.c.baseSource=fs.readFileSync(prefix+'operation-interval-v1/timed-v1/inline-layout-15-word-spine-v2/compiler/Base.bend','utf8');layouts.push(vm.runInContext(`(()=>{const book=book_nil();parse_book(book,'',baseSource,'',Object.create(null));TELES.clear();LAYS.clear();const inner={T:All({$:'Many'},'x',0,ADT('Bool',[]),()=>ADT('Nested',[])),n:1,k:'Nested.make'};book.tlds.Nested={$:'ADT',c:[inner]};book.ctrs[inner.k]=inner;const recursive={T:All({$:'Many'},'tail',0,ADT('Recursive',[]),()=>ADT('Recursive',[])),n:1,k:'Recursive.make'};book.tlds.Recursive={$:'ADT',c:[recursive]};book.ctrs[recursive.k]=recursive;const outer={T:All({$:'Many'},'x',0,ADT('Nested',[]),()=>ADT('Outer',[])),n:1,k:'Outer.make'};book.tlds.Outer={$:'ADT',c:[outer]};book.ctrs[outer.k]=outer;const cases=[ADT('Nested',[]),ADT('Outer',[]),ADT('Recursive',[]),ADT('U32',[]),ADT('F32',[]),ADT('Nat',[]),ADT('Bool',[]),ADT('Word',[Lit('Nat',15)]),ADT('Word',[Lit('Nat',16)])];return cases.map(t=>JSON.stringify(lay_of(book,t)));})()`,a.c,{timeout:2000}));}
assert.deepEqual(layouts[0],layouts[1]);
console.log(JSON.stringify({status:'PASS',compilerSHA256:hash,scope:'Actual term_lower/term_key/lay_key equality relation and actual parsed Base physical layouts; not full consumer acceptance',result,layouts:layouts[1]},null,2));
