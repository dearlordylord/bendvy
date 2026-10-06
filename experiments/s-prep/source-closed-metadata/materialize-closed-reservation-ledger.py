#!/usr/bin/env python3
"""Close only ledger type in the actual reservation identity route."""
import argparse,hashlib,json,pathlib,re,shutil
HERE=pathlib.Path(__file__).resolve().parent
p=argparse.ArgumentParser();p.add_argument('--input',type=pathlib.Path,required=True);p.add_argument('--output',type=pathlib.Path,required=True);a=p.parse_args();assert not a.output.exists();assert not a.output.absolute().is_relative_to(a.input.resolve());assert not any(x.is_symlink() for x in a.input.rglob('*'))
sha=lambda p:hashlib.sha256(p.read_bytes()).hexdigest();pins={str(p.relative_to(a.input)):sha(p) for p in a.input.rglob('*.bend')};assert len(pins)==29 and pins==json.loads((HERE/'fourhour-closed-reservation-v2-output-pins.json').read_text());overlay=json.loads((a.input/'overlay.json').read_text());cache=json.loads((a.input/'cache-specialization.json').read_text());assert cache==overlay['cacheSpecialization'];assert cache['runtimeClosure']==cache['specializedClosure']==overlay['sources']==pins;assert cache['runtimeClosureSHA256']==hashlib.sha256(json.dumps(pins,sort_keys=True,separators=(',',':')).encode()).hexdigest()
def body(source,name):
 m=re.search(r'^def '+name+r'\(',source,re.M);assert m;tail=source[m.start():];n=re.search(r'\n(?:def |type )',tail);return tail[:n.start()+1] if n else tail
name='experiments/s-integrate/identity.bend';source=(a.input/name).read_text();checked=body(source,'reserve_checked');reserveid=body(source,'reserve_id');oldhead='-Schema: Data,-M: Type,-A: Type,-F: Data,-L: Type,-Mode: Data,';newhead='~L: Type,-Schema: Data,-M: Type,-A: Type,-F: Data,-Mode: Data,'
newchecked=checked.replace('def reserve_checked(','def prototype_closed_L_reserve_checked(',1).replace(oldhead,newhead,1)
newid=reserveid.replace('def reserve_id(','def prototype_closed_L_reserve_id(',1).replace(oldhead,newhead,1).replace('reserve_checked(Schema,M,A,F,L,Mode,','prototype_closed_L_reserve_checked(~L,Schema,M,A,F,Mode,')
assert newchecked!=checked and newid!=reserveid;source+='\n'+newchecked+'\n'+newid;assert checked in source and reserveid in source;changes={name:source}
name='experiments/s-integrate/commands.bend';source=(a.input/name).read_text();old=body(source,'prototype_closed_reserve');new=old.replace('~F: Data,-Schema: Data,-L: Type,-Mode: Data,','~F: Data,~L: Type,-Schema: Data,-Mode: Data,',1).replace('I.reserve_id(Schema,M,A,F,L,Mode,','I.prototype_closed_L_reserve_id(~L,Schema,M,A,F,Mode,');assert old!=new;changes[name]=source.replace(old,new,1)
name='experiments/s-integrate/raw-boundaries.bend';source=(a.input/name).read_text()
for schema,main,view,aux,flag,ledger,mode in [('Motion','Position','PositionView','Velocity','Selected','MotionLedger','MotionMode'),('Health','Vitals','VitalsView','Armor','Tracked','HealthLedger','HealthMode')]:
 m='C.Cache<T.'+main+',T.'+view+'>';a0='T.'+aux;f='T.'+flag;l='C.Cache<T.'+ledger+',T.LedgerView>'
 oldcall='Q.prototype_closed_reserve(~'+m+',~'+a0+',~'+f+',T.'+schema+'Schema,'+l+',T.'+mode+',world,';newcall='Q.prototype_closed_reserve(~'+m+',~'+a0+',~'+f+',~'+l+',T.'+schema+'Schema,T.'+mode+',world,'
 assert source.count(oldcall)==1;source=source.replace(oldcall,newcall)
changes[name]=source
shutil.copytree(a.input,a.output);
for path,text in changes.items():(a.output/path).write_text(text)
newpins={str(p.relative_to(a.output)):sha(p) for p in a.output.rglob('*.bend')};assert set(k for k in pins if pins[k]!=newpins[k])==set(changes)
cache['runtimeClosure']=newpins;cache['specializedClosure']=newpins.copy();cache['runtimeClosureSHA256']=hashlib.sha256(json.dumps(newpins,sort_keys=True,separators=(',',':')).encode()).hexdigest();overlay['sources']=newpins;overlay['cacheSpecialization']=cache
for name,value in [('overlay.json',overlay),('cache-specialization.json',cache),('closed-observation.json',{'status':'UNVERIFIED_SOURCE_HYPOTHESIS','inputPins':pins,'outputPins':newpins,'recipeSHA256':sha(pathlib.Path(__file__))})]:(a.output/name).write_text(json.dumps(value,indent=2)+'\n')
print(a.output/'experiments/s-integrate')
