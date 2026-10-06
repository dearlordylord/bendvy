#!/usr/bin/env python3
"""Freeze only the independently observed Batch<V> reverse frame frontier."""
import argparse,hashlib,json,pathlib,re,shutil
HERE=pathlib.Path(__file__).resolve().parent
p=argparse.ArgumentParser();p.add_argument('--input',type=pathlib.Path,required=True);p.add_argument('--output',type=pathlib.Path,required=True);a=p.parse_args();assert not a.output.exists();assert not a.output.absolute().is_relative_to(a.input.resolve());assert not any(x.is_symlink() for x in a.input.rglob('*'))
sha=lambda p:hashlib.sha256(p.read_bytes()).hexdigest();pins={str(p.relative_to(a.input)):sha(p) for p in a.input.rglob('*.bend')};assert len(pins)==29 and pins==json.loads((HERE/'closed-streams-output-pins.json').read_text());overlay=json.loads((a.input/'overlay.json').read_text());cache=json.loads((a.input/'cache-specialization.json').read_text());assert cache==overlay['cacheSpecialization'];assert cache['runtimeClosure']==cache['specializedClosure']==overlay['sources']==pins;assert cache['runtimeClosureSHA256']==hashlib.sha256(json.dumps(pins,sort_keys=True,separators=(',',':')).encode()).hexdigest()
source=a.input/'experiments/s-integrate';selected={'streams':['trim_decision','trim_front','finish_cut','trim_second','trim_buffer','trim','trim_lifecycle'],'reader-host':['life_trim','frame_despawned','frame_removed','frame_ping','frame'],'host':['frame_return','frame']};aliases={'streams':{},'reader-host':{'S':'streams'},'host':{'H':'reader-host'}};texts={};defs={};prefix='prototype_closed_frame_'
for mod,names in selected.items():
 s=(source/(mod+'.bend')).read_text();texts[mod]=s
 for name in names:
  m=re.search(r'^def '+name+r'\(',s,re.M);assert m;tail=s[m.start():];n=re.search(r'\n(?:def |type )',tail);defs[(mod,name)]=(tail[:n.start()+1] if n else tail).rstrip()
params={k:re.findall(r'-(\w+):\s*(?:Data|Type)',b.split('\n  ')[0]) for k,b in defs.items()};assert all(params.values())
shutil.copytree(a.input,a.output)
for mod in selected:
 clones=[]
 for name in selected[mod]:
  b=defs[(mod,name)]
  for (target,n),args in params.items():
   for spelling in ([n] if mod==target else [alias+'.'+n for alias,m in aliases[mod].items() if m==target]):
    if (mod,name)==('reader-host','life_trim') and target=='streams':b=b.replace(spelling+'(W.Handle<Schema>,',spelling.replace(n,prefix+n)+'(W.Handle<Schema>,')
    b=re.sub(r'(?<![\w.])'+re.escape(spelling+'('+','.join(args))+r'(?=[,)])',lambda m:spelling.replace(n,prefix+n)+'('+','.join('~'+x for x in args),b)
  if (mod,name) in [('streams','trim'),('streams','trim_lifecycle')]:
   actual='P' if name=='trim' else 'H';assert b.count('trim_buffer('+actual+',')==1;b=b.replace('trim_buffer('+actual+',',prefix+'trim_buffer(~'+actual+',')
  b=b.replace('def '+name+'(','def '+prefix+name+'(',1);b=re.sub(r'-(\w+):\s*(Data|Type)',r'~\1: \2',b);clones.append(b)
 insertion='\n# Closed frame trim frontier; all public generic bodies retained.\n'+'\n\n'.join(clones)+'\n';s=texts[mod].replace('def motion_frame(',insertion+'\ndef motion_frame(',1) if mod=='host' else texts[mod]+insertion;(a.output/'experiments/s-integrate'/(mod+'.bend')).write_text(s)
for mod in ['host','measurement-bend']:
 f=a.output/'experiments/s-integrate'/(mod+'.bend');s=f.read_text()
 for name in ['motion_frame','health_frame']:
  m=re.search(r'^def '+name+r'\(',s,re.M);tail=s[m.start():];n=re.search(r'\n(?:def |type )',tail);old=tail[:n.start()+1] if n else tail
  pat=r'(?<![\w.])(?:H\.)?frame\((T\.\w+Schema),(CC\.Cache<T\.\w+,T\.\w+View>),(T\.\w+),(T\.\w+),(CC\.Cache<T\.\w+Ledger,T\.LedgerView>),(T\.\w+Mode),(T\.\w+Ping),(T\.\w+View),(T\.\w+View),(T\.LedgerView),'
  new=re.sub(pat,lambda m:('H.' if mod=='measurement-bend' else '')+prefix+'frame('+','.join('~'+x for x in m.groups())+',',old);assert new!=old,(mod,name);s=s.replace(old,new,1)
 f.write_text(s)
newpins={str(p.relative_to(a.output)):sha(p) for p in a.output.rglob('*.bend')};assert set(k for k in pins if pins[k]!=newpins[k])==set('experiments/s-integrate/'+m+'.bend' for m in ['host','measurement-bend','reader-host','streams'])
for mod,s in texts.items():
 new=(a.output/'experiments/s-integrate'/(mod+'.bend')).read_text();assert all(line in new.splitlines() for line in s.splitlines() if line.startswith(('def ','type ')))
 if mod!='host':assert s in new
cache['runtimeClosure']=newpins;cache['specializedClosure']=newpins.copy();cache['runtimeClosureSHA256']=hashlib.sha256(json.dumps(newpins,sort_keys=True,separators=(',',':')).encode()).hexdigest();overlay['sources']=newpins;overlay['cacheSpecialization']=cache
for name,value in [('overlay.json',overlay),('cache-specialization.json',cache),('closed-frame.json',{'status':'UNVERIFIED_SOURCE_HYPOTHESIS','inputPins':pins,'outputPins':newpins,'clones':selected,'recipeSHA256':sha(pathlib.Path(__file__))})]:(a.output/name).write_text(json.dumps(value,indent=2)+'\n')
print(a.output/'experiments/s-integrate')
