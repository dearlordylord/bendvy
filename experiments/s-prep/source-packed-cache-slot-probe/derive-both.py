#!/usr/bin/env python3
from pathlib import Path
import argparse,hashlib,json,re,shutil
H=Path(__file__).resolve().parent;p=argparse.ArgumentParser();p.add_argument('--output',type=Path,required=True);p.add_argument('--input',type=Path,default=Path('/tmp/bendvy-packed-main-slot-motion-v4-receipt-v2'));a=p.parse_args();BASE=a.input;m=json.loads((BASE/'overlay.json').read_text());pins=m['sources'];sha=lambda p:hashlib.sha256(p.read_bytes()).hexdigest();assert len(pins)==29 and hashlib.sha256(json.dumps(pins,sort_keys=True,separators=(',',':')).encode()).hexdigest()=='52b505c4d7c3a0b304659b48b0a892e6d0db973a3637bc033e03282792d52c6e';assert not any(p.is_symlink() for p in BASE.rglob('*'))
for n,h in pins.items():assert sha(BASE/n)==h
cache=json.loads((BASE/'cache-specialization.json').read_text());assert cache==m['cacheSpecialization'] and cache['runtimeClosure']==pins and cache['specializedClosure']==pins and cache['specializedClosureSHA256']==cache['runtimeClosureSHA256']
assert not a.output.exists();shutil.copytree(BASE,a.output);root=a.output/'experiments/s-integrate'
def replace(text,names):
 for x,y in sorted(names.items(),key=lambda x:-len(x[0])):text=re.sub(r'(?<![\w])'+re.escape(x)+r'(?![\w])',y,text)
 return text
maps={};blocks={}
files=['transaction-dispatch-adapters.bend','raw-boundaries.bend','host.bend','held-adapter.bend','measurement-bend.bend']
for file in files:
 selected=[]
 for x in re.finditer(r'^(?:def|type) (\w+).*?(?=\n(?:def|type) |\Z)',(root/file).read_text(),re.M|re.S):
  n=x[1];take=False
  if file in files[:2]:take=n.startswith('health_')
  if file=='host.bend':take=n in ['HealthHost','health_snapshot','health_read','health_foreign','health_on','health_presence_ledger','health_presence','health_desired','health_transition']
  if file=='held-adapter.bend':take=n.startswith('prototype_journalledger_health') or n in ['prototype_flatfold_health','prototype_flatfold_health_converted']
  if file=='measurement-bend.bend':take=(n.startswith('health_') or n.startswith('prototype_flat_health') or n in ['HealthBench','PrototypeFlatHealthRows']) and n not in ['health_rows','health_rows_next','health_select','health_updated','health_queried','health_body','health_body_read','health_body_ledger']
  if take:selected.append((n,x[0]))
 maps[file]={n:'prototype_packed_'+n for n,_ in selected};blocks[file]=selected;(H/(file+'.health-selection.json')).write_text(json.dumps(list(maps[file]),indent=2)+'\n')
(root/'cached-payload.bend').write_text((root/'cached-payload.bend').read_text()+'\n'+(H/'packed-health-payload.bend').read_text())
for file in files:
 text=(root/file).read_text();clone=replace('\n'.join(b for _,b in blocks[file]),maps[file])
 for alias,target in [('A',files[0]),('RB',files[1]),('H','host.bend'),('HA','held-adapter.bend')]:clone=replace(clone,{alias+'.'+n:alias+'.'+v for n,v in maps[target].items()})
 cp='P' if file in ['raw-boundaries.bend','held-adapter.bend'] else 'CP';clone=clone.replace('CC.Cache<T.Vitals,T.VitalsView>',cp+'.PrototypeHealthMainSlot').replace('C.Cache<T.Vitals,T.VitalsView>',cp+'.PrototypeHealthMainSlot')
 for op in ['new','get','swap']:clone=clone.replace(cp+'.vitals_'+op,cp+'.prototype_slot_vitals_'+op)
 if file=='raw-boundaries.bend':clone=clone.replace('Some{C.Cache{raw,_}}: Some{raw}',f'Some{{owner}}: Some{{{cp}.prototype_slot_vitals_raw(owner)}}').replace('T.CommandMissing{world,C.Cache{raw,_}}: T.CommandMissing{world,raw}',f'T.CommandMissing{{world,owner}}: T.CommandMissing{{world,{cp}.prototype_slot_vitals_raw(owner)}}')
 if file=='held-adapter.bend':
  clone=clone.replace('PrototypeJournalLedgerRowOwner<T.Vitals,T.VitalsView,T.LedgerView,T.HealthSchema>','PrototypePackedHealthRowOwner')
  clone=clone.replace('PrototypeJournalLedgerRowOwner{main_raw,main_cached,','PrototypePackedHealthRowOwner{levels,rawreserve,rawclass,a,b,c,d,cachedreserve,cachedclass,')
  clone=clone.replace('Some{CC.Cache{main_raw,main_cached}}','Some{P.PrototypeHealthMainSlot{levels,rawreserve,rawclass,a,b,c,d,cachedreserve,cachedclass}}')
  # Original specialized row provider bodies are replaced by separately audited scalar helpers.
  names=['get','ledger','set_fused_done','set','setledger_done','setledger','invoke']
  for n in names:
   pattern=r'^def prototype_packed_prototype_journalledger_health_'+n+r'\(.*?(?=\n(?:def|type) |\Z)';clone,count=re.subn(pattern,'',clone,flags=re.M|re.S);assert count==1
  clone=(H/'packed-health-row.bend').read_text()+'\n'+clone
 (root/file).write_text(text+'\n# Private persistent packed Health Main route.\n'+clone+'\n')
new={n:sha(a.output/n) for n in pins};cache['runtimeClosure']=new;cache['specializedClosure']=new;cache['runtimeClosureSHA256']=hashlib.sha256(json.dumps(new,sort_keys=True,separators=(',',':')).encode()).hexdigest();cache['specializedClosureSHA256']=cache['runtimeClosureSHA256'];m['sources']=new;m['cacheSpecialization']=cache
for name,d in [('overlay.json',m),('cache-specialization.json',cache)]: (a.output/name).write_text(json.dumps(d,indent=2)+'\n')
print(cache['runtimeClosureSHA256'])
