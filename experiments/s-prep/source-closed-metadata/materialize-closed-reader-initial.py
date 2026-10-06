#!/usr/bin/env python3
"""Close reader initialization Data types on concrete registrations."""
import argparse,hashlib,json,pathlib,re,shutil
HERE=pathlib.Path(__file__).resolve().parent
p=argparse.ArgumentParser();p.add_argument('--input',type=pathlib.Path,required=True);p.add_argument('--output',type=pathlib.Path,required=True);a=p.parse_args();assert not a.output.exists();assert not a.output.absolute().is_relative_to(a.input.resolve());assert not any(x.is_symlink() for x in a.input.rglob('*'))
sha=lambda p:hashlib.sha256(p.read_bytes()).hexdigest();pins={str(p.relative_to(a.input)):sha(p) for p in a.input.rglob('*.bend')};assert len(pins)==29 and pins==json.loads((HERE/'fourhour-reservation-mode-output-pins.json').read_text());overlay=json.loads((a.input/'overlay.json').read_text());cache=json.loads((a.input/'cache-specialization.json').read_text());assert cache==overlay['cacheSpecialization'];assert cache['runtimeClosure']==cache['specializedClosure']==overlay['sources']==pins;assert cache['runtimeClosureSHA256']==hashlib.sha256(json.dumps(pins,sort_keys=True,separators=(',',':')).encode()).hexdigest()
def body(source,name):
 m=re.search(r'^def '+name+r'\(',source,re.M);assert m;tail=source[m.start():];n=re.search(r'\n(?:def |type )',tail);return tail[:n.start()+1] if n else tail
changes={};name='experiments/s-integrate/reader-host.bend';source=(a.input/name).read_text();old=body(source,'initial');new=old.replace('def initial(-Schema: Data,-P: Data,','def prototype_closed_initial(~Schema: Data,~P: Data,',1);assert old!=new;changes[name]=source+'\n'+new
name='experiments/s-integrate/host.bend';source=(a.input/name).read_text();old=body(source,'initial');new=old.replace('def initial(-Schema:Data,-M:Type,-A:Type,-F:Data,-L:Type,-Mode:Data,-P:Data,-V:Data,-AV:Data,-LV:Data,','def prototype_closed_initial(~Schema:Data,~P:Data,-M:Type,-A:Type,-F:Data,-L:Type,-Mode:Data,-V:Data,-AV:Data,-LV:Data,',1).replace('H.initial(Schema,P,capacity)','H.prototype_closed_initial(~Schema,~P,capacity)');assert old!=new;changes[name]=source+'\n'+new
name='experiments/s-integrate/measurement-bend.bend';source=(a.input/name).read_text()
for schema,main,view,aux,flag,ledger,mode,ping in [('Motion','Position','PositionView','Velocity','Selected','MotionLedger','MotionMode','MotionPing'),('Health','Vitals','VitalsView','Armor','Tracked','HealthLedger','HealthMode','HealthPing')]:
 oldcall='H.initial(T.'+schema+'Schema,CC.Cache<T.'+main+',T.'+view+'>,T.'+aux+',T.'+flag+',CC.Cache<T.'+ledger+',T.LedgerView>,T.'+mode+',T.'+ping+',';newcall='H.prototype_closed_initial(~T.'+schema+'Schema,~T.'+ping+',CC.Cache<T.'+main+',T.'+view+'>,T.'+aux+',T.'+flag+',CC.Cache<T.'+ledger+',T.LedgerView>,T.'+mode+',';assert source.count(oldcall)==1;source=source.replace(oldcall,newcall)
changes[name]=source
shutil.copytree(a.input,a.output);
for path,text in changes.items():(a.output/path).write_text(text)
newpins={str(p.relative_to(a.output)):sha(p) for p in a.output.rglob('*.bend')};assert set(k for k in pins if pins[k]!=newpins[k])==set(changes)
cache['runtimeClosure']=newpins;cache['specializedClosure']=newpins.copy();cache['runtimeClosureSHA256']=hashlib.sha256(json.dumps(newpins,sort_keys=True,separators=(',',':')).encode()).hexdigest();overlay['sources']=newpins;overlay['cacheSpecialization']=cache
for name,value in [('overlay.json',overlay),('cache-specialization.json',cache),('closed-observation.json',{'status':'UNVERIFIED_SOURCE_HYPOTHESIS','inputPins':pins,'outputPins':newpins,'recipeSHA256':sha(pathlib.Path(__file__))})]:(a.output/name).write_text(json.dumps(value,indent=2)+'\n')
print(a.output/'experiments/s-integrate')
