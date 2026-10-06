#!/usr/bin/env python3
"""Close only command element M/A/F at concrete storage commit registrations."""
import argparse,hashlib,json,pathlib,re,shutil
HERE=pathlib.Path(__file__).resolve().parent
p=argparse.ArgumentParser();p.add_argument('--input',type=pathlib.Path,required=True);p.add_argument('--output',type=pathlib.Path,required=True);a=p.parse_args();assert not a.output.exists();assert not a.output.absolute().is_relative_to(a.input.resolve());assert not any(x.is_symlink() for x in a.input.rglob('*'))
sha=lambda p:hashlib.sha256(p.read_bytes()).hexdigest();pins={str(p.relative_to(a.input)):sha(p) for p in a.input.rglob('*.bend')};assert len(pins)==29 and pins==json.loads((HERE/'closed-tx-element-output-pins.json').read_text());overlay=json.loads((a.input/'overlay.json').read_text());cache=json.loads((a.input/'cache-specialization.json').read_text());assert cache==overlay['cacheSpecialization'];assert cache['runtimeClosure']==cache['specializedClosure']==overlay['sources']==pins;assert cache['runtimeClosureSHA256']==hashlib.sha256(json.dumps(pins,sort_keys=True,separators=(',',':')).encode()).hexdigest()
name='experiments/s-integrate/transaction.bend';source=(a.input/name).read_text();m=re.search(r'^def storage_commit\(',source,re.M);assert m
tail=source[m.start():];n=re.search(r'\n(?:def |type )',tail);old=tail[:n.start()+1];new=old.replace('def storage_commit(-Schema: Data,-M: Type,-A: Type,-F: Data,-L: Type,-Mode: Data,','def prototype_closed_storage_commit(~M: Type,~A: Type,~F: Data,-Schema: Data,-L: Type,-Mode: Data,',1);assert new!=old;source=source.replace('def reserve_finish(',new+'\ndef reserve_finish(',1);assert old in source
changes={name:source}
for filename in ['measurement-bend.bend','transaction-dispatch-adapters.bend']:
 path='experiments/s-integrate/'+filename;text=(a.input/path).read_text();assert text.count('X.storage_commit(')==(2 if filename=='measurement-bend.bend' else 4)
 # All six actual arguments are schema-specific closed constants, not variables.
 for schema,main,aux,flag,ledger,mode in [('Motion','Position','Velocity','Selected','MotionLedger','MotionMode'),('Health','Vitals','Armor','Tracked','HealthLedger','HealthMode')]:
  m='CC.Cache<T.'+main+',T.'+('PositionView' if schema=='Motion' else 'VitalsView')+'>';a0='T.'+aux;f='T.'+flag;l='CC.Cache<T.'+ledger+',T.LedgerView>'
  oldcall='X.storage_commit(T.'+schema+'Schema,'+m+','+a0+','+f+','+l+',T.'+mode+','
  newcall='X.prototype_closed_storage_commit(~'+m+',~'+a0+',~'+f+',T.'+schema+'Schema,'+l+',T.'+mode+','
  assert text.count(oldcall)==(1 if filename=='measurement-bend.bend' else 2);text=text.replace(oldcall,newcall)
 changes[path]=text
shutil.copytree(a.input,a.output);
for path,text in changes.items():(a.output/path).write_text(text)
newpins={str(p.relative_to(a.output)):sha(p) for p in a.output.rglob('*.bend')};assert set(k for k in pins if pins[k]!=newpins[k])==set(changes)
cache['runtimeClosure']=newpins;cache['specializedClosure']=newpins.copy();cache['runtimeClosureSHA256']=hashlib.sha256(json.dumps(newpins,sort_keys=True,separators=(',',':')).encode()).hexdigest();overlay['sources']=newpins;overlay['cacheSpecialization']=cache
for name,value in [('overlay.json',overlay),('cache-specialization.json',cache),('closed-observation.json',{'status':'UNVERIFIED_SOURCE_HYPOTHESIS','inputPins':pins,'outputPins':newpins,'recipeSHA256':sha(pathlib.Path(__file__))})]:(a.output/name).write_text(json.dumps(value,indent=2)+'\n')
print(a.output/'experiments/s-integrate')
