#!/usr/bin/env python3
"""Pinned four-scalar benchmark payload overlay; generic ECS and callbacks unchanged."""
import pathlib,json,hashlib,shutil,argparse,re,difflib
p=argparse.ArgumentParser();p.add_argument('--input',type=pathlib.Path,required=True);p.add_argument('--output',type=pathlib.Path,required=True);a=p.parse_args();H=pathlib.Path(__file__).resolve().parent;sha=lambda p:hashlib.sha256(p.read_bytes()).hexdigest();pins=json.loads((H/'input-pins.json').read_text());assert len(pins)==29
for n,s in pins.items():assert sha(a.input/n)==s,n
shutil.copytree(a.input,a.output);core=a.output/'experiments/s-integrate';changes={};spec=[('Position','position','coordinates','frame:U32','frame'),('Velocity','velocity','rates','moving:Bool','moving'),('Vitals','vitals','levels','reserve:U32,class:U32','reserve,class'),('Armor','armor','layers','grade:U32','grade'),('MotionLedger','motion_ledger','totals','epoch:U32','epoch'),('HealthLedger','health_ledger','totals','epoch:U32','epoch')]
t=core/'types.bend';old=t.read_text();new=old
for typ,fn,field,typed,meta in spec:
 anchor=typ+'{'+field+': Array<U32>';assert new.count(anchor)==1;new=new.replace(anchor,typ+'{a:U32,b:U32,c:U32,d:U32')
assert all('type '+x[0]+' is Type:' in new for x in spec);t.write_text(new);changes[t.name]=(old,new)
for module in ('payload.bend','uncached-payload.bend'):
 f=core/module;old=f.read_text();new=old[:old.index('def position_observed(')]
 for typ,fn,field,typed,meta in spec:
  view='T.LedgerView' if 'Ledger' in typ else 'T.'+typ+'View';vals='a,b,c,d,'+meta
  new+=f'def {fn}_get(owner:T.{typ}) -> T.{typ} & {view}:\n  match owner:\n    case T.{typ}{{+a,+b,+c,+d,'+','.join('+'+x for x in meta.split(','))+f'}}: (T.{typ}{{{vals}}},{view}{{T.Four{{a,b,c,d}},{meta}}})\n'
  if typ not in ('Velocity','Armor'):
   new+=f'def {fn}_swap(owner:T.{typ},value:U32) -> T.{typ} & U32:\n  match owner:\n    case T.{typ}{{a,b,c,d,{meta}}}: (T.{typ}{{value,b,c,d,{meta}}},a)\n'
 f.write_text(new);changes[f.name]=(old,new)
for module in ('measurement-bend.bend','systems.bend','host.bend'):
 f=core/module;old=f.read_text();new=old
 for typ,fn,field,typed,meta in spec:
  pattern=r'T\.'+typ+r'\{(?:U\.)?quad\(';matches=list(re.finditer(pattern,new))
  for m in reversed(matches):
   at=m.end();depth=1;i=at
   while depth:
    assert i<len(new)
    if new[i]=='(':depth+=1
    if new[i]==')':depth-=1
    i+=1
   args=new[at:i-1];assert new[i]==',';level=0;commas=0
   for ch in args:
    if ch=='(':level+=1
    elif ch==')':level-=1
    elif ch==',' and level==0:commas+=1
   assert commas==3 and level==0,'Not an exact four-scalar constructor'
   new=new[:m.start()]+f'T.{typ}{{'+args+new[i:]
 f.write_text(new);changes[f.name]=(old,new)
newpins={n:sha(a.output/n) for n in pins};assert {n for n in pins if pins[n]!=newpins[n]}=={'experiments/s-integrate/'+x for x in changes}
for name,(old,new) in changes.items():(H/(name+'.patch')).write_text(''.join(difflib.unified_diff(old.splitlines(True),new.splitlines(True),fromfile=name,tofile=name)))
overlay=json.loads((a.output/'overlay.json').read_text());cache=json.loads((a.output/'cache-specialization.json').read_text());cache['runtimeClosure']=newpins;cache['specializedClosure']=newpins.copy();cache['runtimeClosureSHA256']=hashlib.sha256(json.dumps(newpins,sort_keys=True,separators=(',',':')).encode()).hexdigest();overlay['sources']=newpins;overlay['cacheSpecialization']=cache
for name,value in [('overlay.json',overlay),('cache-specialization.json',cache)]:(a.output/name).write_text(json.dumps(value,indent=2)+'\n')
r={'status':'PINNED_SOURCE_ONLY_OVERLAY','sources':newpins,'base':pins,'changed':list(changes),'scope':'Specific fixed-four benchmark payloads remain nominal Type; generic arbitrary affine ECS unchanged; measured SC callbacks byte-identical; callback algorithms/headers unchanged except concrete constructor representation; raw arities intentionally changed','closure':hashlib.sha256(json.dumps(newpins,sort_keys=True,separators=(',',':')).encode()).hexdigest()};(a.output/'inline-payload.json').write_text(json.dumps(r,indent=2)+'\n');print(r['closure'])
