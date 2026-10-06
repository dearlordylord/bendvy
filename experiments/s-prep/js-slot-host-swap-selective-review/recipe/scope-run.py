#!/usr/bin/env python3
from pathlib import Path
import json,hashlib,sys,os,shutil
R=Path('/workspace/formal-proofs/bendvy');H=Path(__file__).resolve().parent;sys.path.insert(0,str(R/'experiments/s-prep/fivehour-connected-gates'));from supervisor import execute
out=Path(sys.argv[1]);out.mkdir(exist_ok=False);os.sched_setaffinity(0,{9});cases=out/'recipe';cases.mkdir();shutil.copyfile(H/'rewrite.cjs',cases/'rewrite.cjs');cat=json.loads((H/'scope-controls/input-pins.json').read_text());records=[]
def run(argv):return execute(list(map(str,argv)),5)
runtime='''function array_rmw(a, i, f) {
  const at = i % a.length;
  const old = a[at];
  a[at] = f(old);
  return {$: "Tuple", fst: a, snd: old};
}
'''
positive=runtime+'''const log=[];
function before(a){log.push('before');a[0]={kind:'Type',a:41,b:42,c:43,d:44,stamp:45};return 7;}
function receive(prefix,pair,tail,scalar,flag){const array=pair.fst;const old=pair.snd;log.push('receiver');return {prefix,array,old,tail,scalar,flag};}
function firstReceive(pair,tail,scalar,flag){const array=pair.fst;const old=pair.snd;log.push('first');return {array,old,tail,scalar,flag};}
function swap(a,i,tail){const value={kind:'Type',a:91,b:92,c:93,d:94,stamp:95};const scalar=17;return receive(before(a),array_rmw(a,i,()=>value),tail,scalar,true);}
function firstSwap(a,i,tail){const value={kind:'Type',a:61,b:62,c:63,d:64,stamp:65};const scalar=18;return firstReceive(array_rmw(a,i,()=>value),tail,scalar,false);}
function stop(){log.push('throw');throw Error('expected');}
function stopped(a,i,tail){const value={kind:'Type',a:1,b:2,c:3,d:4,stamp:5};const scalar=19;return receive(stop(),array_rmw(a,i,()=>value),tail,scalar,true);}
const raw={kind:'Type',a:11,b:12,c:13,d:14,stamp:15};const snapshot=Object.freeze({...raw,kind:'Data'});const a=[raw,raw,raw];const one=swap(a,3,a),two=firstSwap(a,4,a);const empty=[];const three=firstSwap(empty,3,empty);const untouched=[raw];try{stopped(untouched,0,untouched)}catch(e){if(e.message!=='expected')throw e;}
console.log(JSON.stringify({one,two,emptyOld:three.old===undefined,emptyWritten:empty.NaN,sameTail:one.tail===a&&two.tail===a,untouched:untouched[0]===raw,raw,snapshot,log}));
'''
subjects=[('position-retained-order',positive,True)]
# Isolated first-arg fixture; one candidate edge only, so failure cannot hide behind a supported legacy edge.
base=runtime+'''function receive(pair,tail){const a=pair.fst;const old=pair.snd;return {a,old,tail};}
function swap(a,i,tail){const value=9;return receive(array_rmw(a,i,()=>value),tail);}
console.log(JSON.stringify(swap([1,2],0,7)));
'''
negatives={
'later-call':base.replace('()=>value),tail)','()=>value),effect())'),
'later-read':base.replace('()=>value),tail)','()=>value),tail.value)'),
'later-assignment':base.replace('()=>value),tail)','()=>value),(tail=8))'),
'later-update':base.replace('()=>value),tail)','()=>value),tail++)'),
'later-TDZ':base.replace('a,i,tail){const value=9;','a,i){const value=9;').replace('()=>value),tail);','()=>value),tail);const tail=7;'),
'later-self-reference':base.replace('a,i,tail){const value=9;','a,i){const value=9;const tail=tail;'),
'later-branch-binding':base.replace('a,i,tail){const value=9;','a,i){const value=9;if(i){const tail=7;}'),
'later-param-reassigned':base.replace('const value=9;','const value=9;tail=8;'),
'later-local-let':base.replace('a,i,tail){const value=9;','a,i){const value=9;let tail=7;'),
'later-capture':base.replace('const value=9;','const value=9;const capture=()=>tail;'),
'later-catch-binding':base.replace('const value=9;','const value=9;try{}catch(tail){}'),
'later-destructure-binding':base.replace('const value=9;','const value=9;{const {tail}=source;}'),
'later-destructure-write':base.replace('const value=9;','const value=9;[tail]=[8];'),
'later-spread':base.replace('()=>value),tail)','()=>value),...tail)'),
'later-exception':base.replace('()=>value),tail)','()=>value),(()=>{throw Error("after");})())'),
}
subjects.extend((k,v,False)for k,v in negatives.items())
for name,s,positiveCase in subjects:
 p=out/(name+'.js');p.write_text(s);cat[hashlib.sha256(s.encode()).hexdigest()]={'schema':'literal-control','label':name,'literalControl':True}
(cases/'input-pins.json').write_text(json.dumps(cat,indent=2)+'\n')
for p in [*sorted((H/'scope-controls').glob('*.js')),*[out/(n+'.js') for n,_,_ in subjects]]:
 target=out/(p.stem+'-derived.js');code,text=run(['node','--expose-internals',cases/'rewrite.cjs',p,target]);isPositive=p.stem in ['retained-order','position-retained-order'];(out/(p.stem+'-derive.txt')).write_text(text)
 if isPositive:
  assert code==0,text;beforeCode,before=run(['node',p]);afterCode,after=run(['node',target]);assert beforeCode==afterCode==0 and before==after;(out/(p.stem+'-observed.txt')).write_text(after);records.append({'label':p.stem,'status':'RETAINED_TRUEOLD_MODULO_EMPTY_PRIOR_ORDER_PASS','recipe':json.loads(Path(str(target)+'.recipe.json').read_text())})
 else:assert code!=0 and not target.exists(),p.stem;records.append({'label':p.stem,'status':'REFUSED_NO_OUTPUT','diagnosticSHA':hashlib.sha256(text.encode()).hexdigest()})
(out/'evidence.json').write_text(json.dumps({'status':'TWO_RETAINED_ORDER_WITNESSES_AND_TWENTYNINE_REFUSALS_PASS','cpu':9,'cap':5,'records':records},indent=2)+'\n');print({'positive':sum(x['status'].startswith('RETAINED')for x in records),'refusals':sum(x['status']=='REFUSED_NO_OUTPUT'for x in records)})
