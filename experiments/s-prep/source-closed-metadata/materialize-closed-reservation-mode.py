#!/usr/bin/env python3
"""Close only Mode in the private reservation identity route."""
import argparse,hashlib,json,pathlib,re,shutil
HERE=pathlib.Path(__file__).resolve().parent
p=argparse.ArgumentParser();p.add_argument('--input',type=pathlib.Path,required=True);p.add_argument('--output',type=pathlib.Path,required=True);a=p.parse_args();assert not a.output.exists();assert not a.output.absolute().is_relative_to(a.input.resolve());assert not any(x.is_symlink() for x in a.input.rglob('*'))
sha=lambda p:hashlib.sha256(p.read_bytes()).hexdigest();pins={str(p.relative_to(a.input)):sha(p) for p in a.input.rglob('*.bend')};assert len(pins)==29 and pins==json.loads((HERE/'fourhour-mark-mode-output-pins.json').read_text());overlay=json.loads((a.input/'overlay.json').read_text());cache=json.loads((a.input/'cache-specialization.json').read_text());assert cache==overlay['cacheSpecialization'];assert cache['runtimeClosure']==cache['specializedClosure']==overlay['sources']==pins;assert cache['runtimeClosureSHA256']==hashlib.sha256(json.dumps(pins,sort_keys=True,separators=(',',':')).encode()).hexdigest()
def body(source,name):
 m=re.search(r'^def '+name+r'\(',source,re.M);assert m;tail=source[m.start():];n=re.search(r'\n(?:def |type )',tail);return tail[:n.start()+1] if n else tail
changes={};name='experiments/s-integrate/identity.bend';source=(a.input/name).read_text()
for helper in ['prototype_closed_L_reserve_checked','prototype_closed_L_reserve_id']:
 old=body(source,helper);new=old.replace('~L: Type,-Schema: Data,-M: Type,-A: Type,-F: Data,-Mode: Data,','~L: Type,~Mode: Data,-Schema: Data,-M: Type,-A: Type,-F: Data,',1).replace('prototype_closed_L_reserve_checked(~L,Schema,M,A,F,Mode,','prototype_closed_L_reserve_checked(~L,~Mode,Schema,M,A,F,');assert old!=new;source=source.replace(old,new,1)
changes[name]=source
name='experiments/s-integrate/commands.bend';source=(a.input/name).read_text();old=body(source,'prototype_closed_reserve');new=old.replace('~L: Type,-Schema: Data,-Mode: Data,','~L: Type,~Mode: Data,-Schema: Data,',1).replace('I.prototype_closed_L_reserve_id(~L,Schema,M,A,F,Mode,','I.prototype_closed_L_reserve_id(~L,~Mode,Schema,M,A,F,');assert new!=old;changes[name]=source.replace(old,new,1)
name='experiments/s-integrate/raw-boundaries.bend';source=(a.input/name).read_text()
for schema,ledger in [('Motion','MotionLedger'),('Health','HealthLedger')]:
 oldcall='~C.Cache<T.'+ledger+',T.LedgerView>,T.'+schema+'Schema,T.'+schema+'Mode,';newcall='~C.Cache<T.'+ledger+',T.LedgerView>,~T.'+schema+'Mode,T.'+schema+'Schema,';assert source.count(oldcall)==1;source=source.replace(oldcall,newcall)
changes[name]=source
shutil.copytree(a.input,a.output);
for path,text in changes.items():(a.output/path).write_text(text)
newpins={str(p.relative_to(a.output)):sha(p) for p in a.output.rglob('*.bend')};assert set(k for k in pins if pins[k]!=newpins[k])==set(changes)
cache['runtimeClosure']=newpins;cache['specializedClosure']=newpins.copy();cache['runtimeClosureSHA256']=hashlib.sha256(json.dumps(newpins,sort_keys=True,separators=(',',':')).encode()).hexdigest();overlay['sources']=newpins;overlay['cacheSpecialization']=cache
for name,value in [('overlay.json',overlay),('cache-specialization.json',cache),('closed-observation.json',{'status':'UNVERIFIED_SOURCE_HYPOTHESIS','inputPins':pins,'outputPins':newpins,'recipeSHA256':sha(pathlib.Path(__file__))})]:(a.output/name).write_text(json.dumps(value,indent=2)+'\n')
print(a.output/'experiments/s-integrate')
