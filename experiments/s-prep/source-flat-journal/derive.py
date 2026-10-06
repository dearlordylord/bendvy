#!/usr/bin/env python3
import argparse,json,hashlib,re
from pathlib import Path
HERE=Path(__file__).resolve().parent
BASE=Path('/workspace/formal-proofs/bendvy/experiments/s-prep/source-fold-noaux-join/overlay-v1')
p=argparse.ArgumentParser();p.add_argument('--output',type=Path,required=True);a=p.parse_args();a.output.mkdir(exist_ok=False)
sha=lambda p:hashlib.sha256(p.read_bytes()).hexdigest()
pins=json.loads((BASE/'overlay.json').read_text())['sources'];assert len(pins)==29
expectedBaseline='49614f72311af5b03123d536ff301115d28b8886bf516b0d7057a8c52e68ad38'
assert hashlib.sha256(json.dumps(pins,sort_keys=True,separators=(',',':')).encode()).hexdigest()==expectedBaseline
for rel,h in pins.items():
 assert sha(BASE/rel)==h;d=a.output/rel;d.parent.mkdir(parents=True,exist_ok=True);d.write_bytes((BASE/rel).read_bytes())
path=a.output/'experiments/s-integrate';tx=path/'transaction.bend';tx.write_text(tx.read_text()+'\n'+(HERE/'transaction-private.bend').read_text())
hold=(path/'held-adapter.bend').read_text();defs=dict(re.findall(r'(?:^|\n)(def ([\w]+)\(.*?)(?=\ndef |\ntype |\Z)',hold,re.S)) if False else {}
for m in re.finditer(r'^def (\w+)\(.*?(?=\ndef |\ntype |\Z)',hold,re.M|re.S):defs[m.group(1)]=m.group()
rowtype=re.search(r'^type PrototypeRowOwner.*?(?=\ndef )',hold,re.M|re.S).group();rowtype=rowtype.replace('PrototypeRowOwner','PrototypeFlatRowOwner').replace('-H:Data','-Schema:Data').replace('handle:H','handle:S.Handle<Schema>').replace('undo:List<&2,X.Inverse<H>>','undo:X.PrototypeFlatInverse<Schema>').replace('marks:List<&2,H>','marks:X.PrototypeFlatMark<Schema>')
new=[rowtype]
for schema in ['motion','health']:
 cap=schema.capitalize()
 for suffix in ['get','ledger','set_fused_done','set','setledger_fused_done','setledger','invoke']:
  s=defs['prototype_rowsplit_'+schema+'_'+suffix].replace('prototype_rowsplit_','prototype_flatrows_').replace('PrototypeRowOwner','PrototypeFlatRowOwner')
  s=re.sub(r'(PrototypeFlatRowOwner<[^\n]*?),S.Handle<T\.'+cap+r'Schema>>',r'\1,T.'+cap+'Schema>',s)
  s=s.replace('List<&2,X.Inverse<S.Handle<T.'+cap+'Schema>>>','X.PrototypeFlatInverse<T.'+cap+'Schema>').replace('List<&2,S.Handle<T.'+cap+'Schema>>','X.PrototypeFlatMark<T.'+cap+'Schema>')
  if suffix=='set_fused_done':
   s=s.replace('match result:','match handle result:').replace('case (raw,old):','case S.Handle{+space,+id} Tuple{raw,old}:').replace('handle,X.MainInverse{handle,old} <> undo,handle <> marks','S.Handle{space,id},X.PrototypeFlatMain{space,id,old,undo},X.PrototypeFlatMark{space,id,marks}')
  if suffix=='setledger_fused_done':s=s.replace('X.LedgerInverse{old} <> undo','X.PrototypeFlatLedger{old,undo}')
  new.append(s)
fold=hold[hold.index('type PrototypeWriteFold'):hold.index('\ndef motion_get(')]
fold=fold.replace('PrototypeWriteFold','PrototypeFlatFold').replace('prototype_writefold_','prototype_flatfold_').replace('PrototypeRowOwner','PrototypeFlatRowOwner').replace('prototype_rowsplit_','prototype_flatrows_')
fold=fold.replace('undo:List<&2,X.Inverse<S.Handle<Schema>>>','undo:X.PrototypeFlatInverse<Schema>').replace('marks:List<&2,S.Handle<Schema>>','marks:X.PrototypeFlatMark<Schema>')
worlds={};commands={};oldtx={};newtx={}
for schema,cap,main,view,aux,flag,ledger,mode in [('motion','Motion','Position','PositionView','Velocity','Selected','MotionLedger','MotionMode'),('health','Health','Vitals','VitalsView','Armor','Tracked','HealthLedger','HealthMode')]:
 w=f'S.World<T.{cap}Schema,CC.Cache<T.{main},T.{view}>,T.{aux},T.{flag},CC.Cache<T.{ledger},T.LedgerView>,T.{mode}>';c=f'S.Command<CC.Cache<T.{main},T.{view}>,T.{aux},T.{flag}>';o=f'X.Tx<{w},S.Handle<T.{cap}Schema>,{c}>';n=f'X.PrototypeFlatTx<T.{cap}Schema,{w},{c}>';worlds[schema]=w;commands[schema]=c;oldtx[schema]=o;newtx[schema]=n
 fold=fold.replace(o,n).replace('List<&2,X.Inverse<S.Handle<T.'+cap+'Schema>>>','X.PrototypeFlatInverse<T.'+cap+'Schema>').replace('marks:List<&2,S.Handle<T.'+cap+'Schema>>','marks:X.PrototypeFlatMark<T.'+cap+'Schema>')
 fold=re.sub(r'(PrototypeFlatRowOwner<[^\n]*?),S.Handle<T\.'+cap+r'Schema>>',r'\1,T.'+cap+'Schema>',fold)
fold=fold.replace('X.Tx{','X.PrototypeFlatTx{')
# Fallback clients remain original generic Tx consumers, roundtripping all journals.
lines=fold.splitlines();schema=None
for i,line in enumerate(lines):
 if line.startswith('def prototype_flatfold_'):schema='motion' if '_motion' in line else 'health'
 if schema and 'client(X.PrototypeFlatTx<' in line:
  line=line.replace('client('+newtx[schema],'client('+oldtx[schema])
  marker='X.PrototypeFlatTx{';start=line.index(marker);depth=0;end=None
  for j in range(start+len('X.PrototypeFlatTx'),len(line)):
   if line[j]=='{':depth+=1
   elif line[j]=='}':
    depth-=1
    if depth==0:end=j+1;break
  cap=schema.capitalize();owner=line[start:end];line=line[:start]+f'X.prototype_flat_unpack(~T.{cap}Schema,~{worlds[schema]},~{commands[schema]},'+owner+')'+line[end:]
  # Fallback helper currently accepts FlatTx; wrap returned legacy pair before unpack.
  # Separate conversion helper makes the computed pair a legal scrutinee.
  call=f'prototype_flatfold_{schema}_unpack(client('
  line=line.replace(call,f'prototype_flatfold_{schema}_fallback(client(')
  lines[i]=line
fold='\n'.join(lines)+'\n'
# Add concrete pair conversion before copied helper family (no forward refs).
for schema in ['motion','health']:
 cap=schema.capitalize();old=oldtx[schema];n=newtx[schema]
 new.append(f'def prototype_flatfold_{schema}_converted(result:{old} & U32) -> {n} & U32:\n  match result:\n    case (owner,value): (X.prototype_flat_pack(~T.{cap}Schema,~{worlds[schema]},~{commands[schema]},owner),value)\n')
# Fallback defs must follow unpack; inject immediately after unpack definitions.
for schema in ['motion','health']:
 name='prototype_flatfold_'+schema+'_unpack';m=re.search(r'^def '+name+r'\(.*?(?=\ndef )',fold,re.M|re.S);rtype=re.search(r' -> ([^\n]+):',m.group()).group(1)
 helper=f'\ndef prototype_flatfold_{schema}_fallback(result:{oldtx[schema]} & U32,total:U32) -> {rtype}:\n  {name}(prototype_flatfold_{schema}_converted(result),total)\n'
 fold=fold[:m.end()]+helper+fold[m.end():]
wrappers=[]
for schema in ['motion','health']:
 cap=schema.capitalize();header=defs[schema+'_row'].splitlines()[0].replace('def '+schema+'_row(','def prototype_flatjournal_'+schema+'_row(')
 body='  match owner:\n    case X.Tx{world,+selected,undo,commands,pings,marks}: X.prototype_flat_pair_unpack(~T.'+cap+'Schema,~'+worlds[schema]+',~'+commands[schema]+',prototype_flatfold_'+schema+'(~client,selected <> [],X.prototype_flat_pack(~T.'+cap+'Schema,~'+worlds[schema]+',~'+commands[schema]+',X.Tx{world,selected,undo,commands,pings,marks}),0))\n'
 wrappers.append(header+'\n'+body)
(path/'held-adapter.bend').write_text(hold+'\n'+'\n'.join(new)+'\n'+fold+'\n'+'\n'.join(wrappers))
# Clone the exact measurement transport definitions; original callbacks and headers remain.
m=(path/'measurement-bend.bend').read_text();md={x.group(1):x.group() for x in re.finditer(r'^def (\w+)\(.*?(?=\ndef |\ntype |\Z)',m,re.M|re.S)}
append=[]
for schema in ['motion','health']:
 cap=schema.capitalize();o=oldtx[schema];n=newtx[schema]
 typ=re.search(r'^type '+cap+r'Rows.*?(?=\ndef )',m,re.M|re.S).group().replace(cap+'Rows','PrototypeFlat'+cap+'Rows').replace(o,n);append.append(typ)
 for suffix in ['rows_next','rows','updated','queried']:
  s=md[schema+'_'+suffix].replace(cap+'Rows','PrototypeFlat'+cap+'Rows').replace(o,n)
  for sn in ['rows_next','rows','updated','queried']:s=re.sub(r'\b'+schema+'_'+sn+r'\b','prototype_flat_'+schema+'_'+sn,s)
  s=s.replace('HA.prototype_writefold_','HA.prototype_flatfold_')
  if suffix=='updated':
   original=f'X.tx_finish_success({worlds[schema]},S.Handle<T.{cap}Schema>,{commands[schema]},owner)';s=s.replace(original,f'X.prototype_flat_finish_success(~T.{cap}Schema,~{worlds[schema]},~{commands[schema]},owner)').replace('X.storage_commit(','X.prototype_flat_storage_commit(')
   for arg in ['T.'+cap+'Schema', 'CC.Cache<T.'+('Position,T.PositionView' if schema=='motion' else 'Vitals,T.VitalsView')+'>', 'T.'+('Velocity' if schema=='motion' else 'Armor'),'T.'+('Selected' if schema=='motion' else 'Tracked'),'CC.Cache<T.'+cap+'Ledger,T.LedgerView>','T.'+cap+'Mode']:
    # Add template sigil only in storage commit prefix, not entire expression.
    before=s.index('X.prototype_flat_storage_commit(');after=s.index(',X.prototype_flat_finish_success',before);pre=s[before:after];pre=pre.replace(arg,'~'+arg,1);s=s[:before]+pre+s[after:]
  if suffix=='queried':
   begin=f'X.tx_begin({worlds[schema]},S.Handle<T.{cap}Schema>,{commands[schema]},world,S.Handle{{0,0}})';s=s.replace(begin,f'X.prototype_flat_pack(~T.{cap}Schema,~{worlds[schema]},~{commands[schema]},'+begin+')')
  append.append(s)
 # Insert private family before original invoke, hook only that concrete consumer.
 at=m.index('\ndef '+schema+'_invoke(');m=m[:at]+'\n'+'\n'.join(append)+'\n'+m[at:];append=[]
 m=m.replace('      '+schema+'_queried(sparse,total,count,','      prototype_flat_'+schema+'_queried(sparse,total,count,',1)
(path/'measurement-bend.bend').write_text(m)
manifest={rel:sha(a.output/rel) for rel in pins};cache=json.loads((BASE/'cache-specialization.json').read_text());cache['runtimeClosure']=manifest;cache['specializedClosure']=manifest;cache['runtimeClosureSHA256']=hashlib.sha256(json.dumps(manifest,sort_keys=True,separators=(',',':')).encode()).hexdigest();(a.output/'cache-specialization.json').write_text(json.dumps(cache,indent=2)+'\n');(a.output/'overlay.json').write_text(json.dumps({'sources':manifest,'baselineSources':pins,'cacheSpecialization':cache,'scope':'Private recursive journals, unchanged generic APIs and original callbacks'},indent=2)+'\n')
print(a.output)
