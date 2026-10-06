#!/usr/bin/env python3
"""Close only Mode in the already private mark-loop route."""
import argparse,hashlib,json,pathlib,re,shutil
HERE=pathlib.Path(__file__).resolve().parent
p=argparse.ArgumentParser();p.add_argument('--input',type=pathlib.Path,required=True);p.add_argument('--output',type=pathlib.Path,required=True);a=p.parse_args();assert not a.output.exists();assert not a.output.absolute().is_relative_to(a.input.resolve());assert not any(x.is_symlink() for x in a.input.rglob('*'))
sha=lambda p:hashlib.sha256(p.read_bytes()).hexdigest();pins={str(p.relative_to(a.input)):sha(p) for p in a.input.rglob('*.bend')};assert len(pins)==29 and pins==json.loads((HERE/'fourhour-reservation-ledger-output-pins.json').read_text());overlay=json.loads((a.input/'overlay.json').read_text());cache=json.loads((a.input/'cache-specialization.json').read_text());assert cache==overlay['cacheSpecialization'];assert cache['runtimeClosure']==cache['specializedClosure']==overlay['sources']==pins;assert cache['runtimeClosureSHA256']==hashlib.sha256(json.dumps(pins,sort_keys=True,separators=(',',':')).encode()).hexdigest()
def body(source,name):
 m=re.search(r'^def '+name+r'\(',source,re.M);assert m;tail=source[m.start():];n=re.search(r'\n(?:def |type )',tail);return tail[:n.start()+1] if n else tail
name='experiments/s-integrate/transaction.bend';source=(a.input/name).read_text();changes={}
for helper in ['prototype_closed_L_mark_loop','prototype_closed_L_mark_all']:
 old=body(source,helper);new=old.replace('~L: Type,-Schema: Data,-M: Type,-A: Type,-F: Data,-Mode: Data,','~L: Type,~Mode: Data,-Schema: Data,-M: Type,-A: Type,-F: Data,',1).replace('prototype_closed_L_mark_loop(~L,Schema,M,A,F,Mode,','prototype_closed_L_mark_loop(~L,~Mode,Schema,M,A,F,');assert new!=old;source=source.replace(old,new,1)
old=body(source,'prototype_closed_storage_commit');new=old.replace('~L: Type,-Schema: Data,-Mode: Data,','~L: Type,~Mode: Data,-Schema: Data,',1).replace('prototype_closed_L_mark_all(~L,Schema,M,A,F,Mode,','prototype_closed_L_mark_all(~L,~Mode,Schema,M,A,F,');assert old!=new;source=source.replace(old,new,1);changes[name]=source
for name in ['experiments/s-integrate/measurement-bend.bend','experiments/s-integrate/transaction-dispatch-adapters.bend']:
 source=(a.input/name).read_text();count=0
 for schema,ledger in [('Motion','MotionLedger'),('Health','HealthLedger')]:
  oldcall='~CC.Cache<T.'+ledger+',T.LedgerView>,T.'+schema+'Schema,T.'+schema+'Mode,';newcall='~CC.Cache<T.'+ledger+',T.LedgerView>,~T.'+schema+'Mode,T.'+schema+'Schema,'
  assert source.count(oldcall)==(1 if name.endswith('measurement-bend.bend') else 2);count+=source.count(oldcall);source=source.replace(oldcall,newcall)
 assert count==(2 if name.endswith('measurement-bend.bend') else 4);changes[name]=source
shutil.copytree(a.input,a.output);
for path,text in changes.items():(a.output/path).write_text(text)
newpins={str(p.relative_to(a.output)):sha(p) for p in a.output.rglob('*.bend')};assert set(k for k in pins if pins[k]!=newpins[k])==set(changes)
cache['runtimeClosure']=newpins;cache['specializedClosure']=newpins.copy();cache['runtimeClosureSHA256']=hashlib.sha256(json.dumps(newpins,sort_keys=True,separators=(',',':')).encode()).hexdigest();overlay['sources']=newpins;overlay['cacheSpecialization']=cache
for name,value in [('overlay.json',overlay),('cache-specialization.json',cache),('closed-observation.json',{'status':'UNVERIFIED_SOURCE_HYPOTHESIS','inputPins':pins,'outputPins':newpins,'recipeSHA256':sha(pathlib.Path(__file__))})]:(a.output/name).write_text(json.dumps(value,indent=2)+'\n')
print(a.output/'experiments/s-integrate')
