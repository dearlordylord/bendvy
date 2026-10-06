#!/usr/bin/env python3
"""Close only M/A/F at the exact private publish caller."""
import argparse,hashlib,json,pathlib,re,shutil
HERE=pathlib.Path(__file__).resolve().parent
p=argparse.ArgumentParser();p.add_argument('--input',type=pathlib.Path,required=True);p.add_argument('--output',type=pathlib.Path,required=True);a=p.parse_args();assert not a.output.exists();assert not a.output.absolute().is_relative_to(a.input.resolve());assert not any(x.is_symlink() for x in a.input.rglob('*'))
sha=lambda p:hashlib.sha256(p.read_bytes()).hexdigest();pins={str(p.relative_to(a.input)):sha(p) for p in a.input.rglob('*.bend')};assert len(pins)==29 and pins==json.loads((HERE/'closed-ledger-mark-output-pins.json').read_text());overlay=json.loads((a.input/'overlay.json').read_text());cache=json.loads((a.input/'cache-specialization.json').read_text());assert cache==overlay['cacheSpecialization'];assert cache['runtimeClosure']==cache['specializedClosure']==overlay['sources']==pins;assert cache['runtimeClosureSHA256']==hashlib.sha256(json.dumps(pins,sort_keys=True,separators=(',',':')).encode()).hexdigest()
def body(source,name):
 m=re.search(r'^def '+name+r'\(',source,re.M);assert m;tail=source[m.start():];n=re.search(r'\n(?:def |type )',tail);return tail[:n.start()+1]
name='experiments/s-integrate/storage.bend';source=(a.input/name).read_text();old=body(source,'publish');new=old.replace('def publish(-S: Data,-M: Type,-A: Type,-F: Data,-L: Type,-Mode: Data,','def prototype_closed_publish(~M: Type,~A: Type,~F: Data,-S: Data,-L: Type,-Mode: Data,',1);assert new!=old;source=source.replace('def mark_meta(',new+'\ndef mark_meta(',1);assert old in source;changes={name:source}
name='experiments/s-integrate/transaction.bend';source=(a.input/name).read_text();old=body(source,'prototype_closed_storage_commit');assert old.count('S.publish(Schema,M,A,F,L,Mode,')==1;new=old.replace('S.publish(Schema,M,A,F,L,Mode,','S.prototype_closed_publish(~M,~A,~F,Schema,L,Mode,');changes[name]=source.replace(old,new,1)
shutil.copytree(a.input,a.output);
for path,text in changes.items():(a.output/path).write_text(text)
newpins={str(p.relative_to(a.output)):sha(p) for p in a.output.rglob('*.bend')};assert set(k for k in pins if pins[k]!=newpins[k])==set(changes)
cache['runtimeClosure']=newpins;cache['specializedClosure']=newpins.copy();cache['runtimeClosureSHA256']=hashlib.sha256(json.dumps(newpins,sort_keys=True,separators=(',',':')).encode()).hexdigest();overlay['sources']=newpins;overlay['cacheSpecialization']=cache
for name,value in [('overlay.json',overlay),('cache-specialization.json',cache),('closed-observation.json',{'status':'UNVERIFIED_SOURCE_HYPOTHESIS','inputPins':pins,'outputPins':newpins,'recipeSHA256':sha(pathlib.Path(__file__))})]:(a.output/name).write_text(json.dumps(value,indent=2)+'\n')
print(a.output/'experiments/s-integrate')
