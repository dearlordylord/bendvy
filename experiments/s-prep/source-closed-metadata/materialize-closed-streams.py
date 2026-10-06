#!/usr/bin/env python3
"""Close only the observed lifecycle append H route on pinned closed-storage29."""
import argparse,hashlib,json,pathlib,re,shutil,difflib
HERE=pathlib.Path(__file__).resolve().parent
p=argparse.ArgumentParser();p.add_argument('--input',type=pathlib.Path,required=True);p.add_argument('--output',type=pathlib.Path,required=True);a=p.parse_args();assert not a.output.exists();assert not a.output.absolute().is_relative_to(a.input.resolve());assert not any(x.is_symlink() for x in a.input.rglob('*'))
sha=lambda p:hashlib.sha256(p.read_bytes()).hexdigest();pins={str(p.relative_to(a.input)):sha(p) for p in a.input.rglob('*.bend')};assert len(pins)==29 and pins==json.loads((HERE/'closed-storage-output-pins.json').read_text());overlay=json.loads((a.input/'overlay.json').read_text());cache=json.loads((a.input/'cache-specialization.json').read_text());assert cache==overlay['cacheSpecialization'];assert cache['runtimeClosure']==cache['specializedClosure']==overlay['sources']==pins;assert cache['runtimeClosureSHA256']==hashlib.sha256(json.dumps(pins,sort_keys=True,separators=(',',':')).encode()).hexdigest()
source=a.input/'experiments/s-integrate';selected={'streams':['count','append_buffer','append_units','append_lifecycle'],'reader-host':['append_change','append_all','append_changes']};aliases={'streams':{},'reader-host':{'S':'streams'}};texts={};defs={};prefix='prototype_closed_stream_'
for mod,names in selected.items():
 s=(source/(mod+'.bend')).read_text();texts[mod]=s
 for name in names:
  m=re.search(r'^def '+name+r'\(',s,re.M);assert m;tail=s[m.start():];n=re.search(r'\n(?:def |type )',tail);defs[(mod,name)]=(tail[:n.start()+1] if n else tail).rstrip()
params={k:re.findall(r'-(\w+):\s*Data',b.split('\n  ')[0]) for k,b in defs.items()};assert all(params.values())
shutil.copytree(a.input,a.output)
for mod in selected:
 clones=[]
 for name in selected[mod]:
  b=defs[(mod,name)]
  for (target,n),args in params.items():
   for spelling in ([n] if mod==target else [alias+'.'+n for alias,m in aliases[mod].items() if m==target]):
    if (mod,name)==('reader-host','append_change') and target=='streams':
     b=b.replace(spelling+'(W.Handle<Schema>,',spelling.replace(n,prefix+n)+'(W.Handle<Schema>,')
    b=b.replace(spelling+'('+','.join(args)+',',spelling.replace(n,prefix+n)+'('+','.join('~'+x for x in args)+',')
  b=b.replace('def '+name+'(','def '+prefix+name+'(',1);b=re.sub(r'-(\w+):\s*Data',r'~\1: Data',b);clones.append(b)
 f=a.output/'experiments/s-integrate'/(mod+'.bend');f.write_text(texts[mod]+'\n# Closed lifecycle append route; public generic functions retained.\n'+'\n\n'.join(clones)+'\n')
host=a.output/'experiments/s-integrate/host.bend';s=host.read_text();m=re.search(r'^def prototype_closed_barrier_applied\(',s,re.M);tail=s[m.start():];n=re.search(r'\n(?:def |type )',tail);old=tail[:n.start()+1] if n else tail;assert old.count('H.append_changes(Schema,P,')==1;new=old.replace('H.append_changes(Schema,P,','H.'+prefix+'append_changes(~Schema,~P,');s=s.replace(old,new,1);host.write_text(s)
newpins={str(p.relative_to(a.output)):sha(p) for p in a.output.rglob('*.bend')};assert [k for k in pins if pins[k]!=newpins[k]]==['experiments/s-integrate/host.bend','experiments/s-integrate/reader-host.bend','experiments/s-integrate/streams.bend'] or set(k for k in pins if pins[k]!=newpins[k])==set('experiments/s-integrate/'+m+'.bend' for m in ['host','reader-host','streams'])
for mod,s in texts.items():assert s in (a.output/'experiments/s-integrate'/(mod+'.bend')).read_text()
cache['runtimeClosure']=newpins;cache['specializedClosure']=newpins.copy();cache['runtimeClosureSHA256']=hashlib.sha256(json.dumps(newpins,sort_keys=True,separators=(',',':')).encode()).hexdigest();overlay['sources']=newpins;overlay['cacheSpecialization']=cache
for name,value in [('overlay.json',overlay),('cache-specialization.json',cache),('closed-streams.json',{'status':'UNVERIFIED_SOURCE_HYPOTHESIS','inputPins':pins,'outputPins':newpins,'clones':selected,'recipeSHA256':sha(pathlib.Path(__file__))})]:(a.output/name).write_text(json.dumps(value,indent=2)+'\n')
print(a.output/'experiments/s-integrate')
