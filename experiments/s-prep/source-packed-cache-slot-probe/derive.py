#!/usr/bin/env python3
"""Pinned private persistent Motion-slot source clone; no original definition edits."""
from pathlib import Path
import argparse,hashlib,json,re,shutil
H=Path(__file__).resolve().parent;p=argparse.ArgumentParser();p.add_argument('--output',type=Path,required=True);a=p.parse_args();BASE=Path('/tmp/bendvy-identity-handle-query-v3');m=json.loads((BASE/'overlay.json').read_text());pins=m['sources'];sha=lambda p:hashlib.sha256(p.read_bytes()).hexdigest();frozen=json.loads((H/'input-pins.json').read_text());assert len(pins)==29 and pins==frozen;assert hashlib.sha256(json.dumps(pins,sort_keys=True,separators=(',',':')).encode()).hexdigest()=='0b3339e7fde4dc1af610ec76b1656b2f9c39748a546ba5929766d7445a51fa43';assert not any(p.is_symlink() for p in BASE.rglob('*'))
for n,h in pins.items():assert sha(BASE/n)==h
cache=json.loads((BASE/'cache-specialization.json').read_text());assert cache==m['cacheSpecialization'] and cache['runtimeClosure']==pins and cache['specializedClosure']==pins
assert not a.output.exists();shutil.copytree(BASE,a.output);root=a.output/'experiments/s-integrate'
def blocks(text):return [(x[1],x[0]) for x in re.finditer(r'^(?:def|type) (\w+).*?(?=\n(?:def|type) |\Z)',text,re.M|re.S)]
def replace_names(text,names):
 for old,new in sorted(names.items(),key=lambda x:-len(x[0])):text=re.sub(r'(?<![\w])'+re.escape(old)+r'(?![\w])',new,text)
 return text
maps={}
# Motion-specific clones keep nominal scalar/view types and original opaque callbacks.
for file in ['transaction-dispatch-adapters.bend','raw-boundaries.bend','host.bend','held-adapter.bend','measurement-bend.bend']:
 text=(root/file).read_text();allblocks=blocks(text);selected=[]
 for name,b in allblocks:
  take=False
  if file in ['transaction-dispatch-adapters.bend','raw-boundaries.bend']:take=name.startswith('motion_')
  if file=='host.bend':take=name in ['MotionHost','motion_snapshot','motion_read','motion_foreign','motion_on','motion_presence_ledger','motion_presence','motion_desired','motion_transition']
  if file=='held-adapter.bend':take=name.startswith('prototype_flatfold_motion')
  if file=='measurement-bend.bend':take=(name.startswith('motion_') or name.startswith('prototype_flat_motion') or name in ['MotionRows','MotionBench','PrototypeFlatMotionRows']) and name not in ['MotionRows','motion_rows','motion_rows_next','motion_select','motion_updated','motion_queried','motion_body','motion_body_read','motion_body_ledger']
  if take:selected.append((name,b))
 maps[file]={name:'prototype_packed_'+name for name,_ in selected};(H/(file+'.selection.json')).write_text(json.dumps(list(maps[file]),indent=2)+'\n')
 # Save selected original blocks for later construction after all maps exist.
 maps[file+'_blocks']=selected
(root/'cached-payload.bend').write_text((root/'cached-payload.bend').read_text()+'\n'+(H/'packed-payload.bend').read_text())
for file in ['transaction-dispatch-adapters.bend','raw-boundaries.bend','host.bend','held-adapter.bend','measurement-bend.bend']:
 text=(root/file).read_text();clone='\n'.join(b for _,b in maps[file+'_blocks']);clone=replace_names(clone,maps[file]);aliases={'A':'transaction-dispatch-adapters.bend','RB':'raw-boundaries.bend','H':'host.bend','HA':'held-adapter.bend'}
 for alias,target in aliases.items():clone=replace_names(clone,{alias+'.'+n:alias+'.'+v for n,v in maps[target].items()})
 cp='P' if file in ['raw-boundaries.bend','held-adapter.bend'] else 'CP';clone=clone.replace('CC.Cache<T.Position,T.PositionView>',cp+'.PrototypeMotionMainSlot').replace('C.Cache<T.Position,T.PositionView>',cp+'.PrototypeMotionMainSlot')
 for op in ['new','get','swap']:clone=clone.replace(cp+'.position_'+op,cp+'.prototype_slot_position_'+op)
 if file=='raw-boundaries.bend':
  clone=clone.replace('Some{C.Cache{raw,_}}: Some{raw}',f'Some{{owner}}: Some{{{cp}.prototype_slot_position_raw(owner)}}').replace('T.CommandMissing{world,C.Cache{raw,_}}: T.CommandMissing{world,raw}',f'T.CommandMissing{{world,owner}}: T.CommandMissing{{world,{cp}.prototype_slot_position_raw(owner)}}')
 if file=='held-adapter.bend':
  clone=clone.replace('PrototypeFlatRowOwner<T.Position,T.PositionView,T.MotionLedger,T.LedgerView,T.MotionSchema>','PrototypePackedMotionRowOwner')
  clone=clone.replace('PrototypeFlatRowOwner{main_raw,main_cached,ledger_raw,ledger_cached,S.Handle{+space,+id},undo,marks}','PrototypePackedMotionRowOwner{coordinates,rawframe,a,b,c,d,cachedframe,ledger_raw,ledger_cached,S.Handle{+space,+id},undo,marks}')
  clone=clone.replace('Some{CC.Cache{main_raw,main_cached}}','Some{P.PrototypeMotionMainSlot{coordinates,rawframe,a,b,c,d,cachedframe}}')
  clone=clone.replace('Some{CC.Cache{main_raw,main_cached}}}', 'Some{P.PrototypeMotionMainSlot{coordinates,rawframe,a,b,c,d,cachedframe}}}')
  clone=clone.replace('Some{CC.Cache{main_raw,main_cached}}', 'Some{P.PrototypeMotionMainSlot{coordinates,rawframe,a,b,c,d,cachedframe}}')
  clone=clone.replace('prototype_flatrows_motion_invoke', 'prototype_packed_row_invoke')
  clone=clone.replace('PrototypeFlatRowOwner{main_raw,main_cached,ledger_raw,ledger_cached,selected,undo,marks}', 'PrototypePackedMotionRowOwner{coordinates,rawframe,a,b,c,d,cachedframe,ledger_raw,ledger_cached,selected,undo,marks}')
  clone=(H/'packed-row.bend').read_text()+'\n'+clone
 (root/file).write_text(text+'\n# Private persistent packed Main route; original definitions retained.\n'+clone+'\n')
new={n:sha(a.output/n) for n in pins};cache['runtimeClosure']=new;cache['specializedClosure']=new;cache['runtimeClosureSHA256']=hashlib.sha256(json.dumps(new,sort_keys=True,separators=(',',':')).encode()).hexdigest();m['sources']=new;m['cacheSpecialization']=cache
for name,d in [('overlay.json',m),('cache-specialization.json',cache)]: (a.output/name).write_text(json.dumps(d,indent=2)+'\n')
print(cache['runtimeClosureSHA256'])
