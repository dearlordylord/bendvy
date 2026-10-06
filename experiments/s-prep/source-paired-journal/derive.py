#!/usr/bin/env python3
import json,re,hashlib,shutil,pathlib,argparse
p=argparse.ArgumentParser();p.add_argument('--output',type=pathlib.Path,required=True);a=p.parse_args();base=pathlib.Path('/tmp/bendvy-joined-flatjournal-ledger-v1');m=json.load(open(base/'overlay.json'));expected=json.load(open(pathlib.Path(__file__).parent/'source-pins.json'))['sources'];assert m['sources']==expected;a.output.mkdir(exist_ok=False)
for f,h in m['sources'].items():
 b=(base/f).read_bytes();assert hashlib.sha256(b).hexdigest()==h;dst=a.output/f;dst.parent.mkdir(parents=True,exist_ok=True);dst.write_bytes(b)
t=a.output/'experiments/s-integrate/transaction.bend';s=t.read_text();s=s.replace('  PrototypeFlatEnd{}','  PrototypeFlatPair{namespace:U32,id:U32,main_old:U32,ledger_old:U32,tail:PrototypeFlatInverse<Schema>}\n  PrototypeFlatEnd{}',1)
s=s.replace('    case PrototypeFlatLedger{old,tail}: LedgerInverse{old} <> prototype_flat_inverse_unpack(~Schema,tail)','    case PrototypeFlatLedger{old,tail}: LedgerInverse{old} <> prototype_flat_inverse_unpack(~Schema,tail)\n    case PrototypeFlatPair{space,id,main_old,ledger_old,tail}: LedgerInverse{ledger_old} <> MainInverse{S.Handle{space,id},main_old} <> prototype_flat_inverse_unpack(~Schema,tail)')
s=s.replace('    case PrototypeFlatLedger{old,tail}: prototype_flat_unwind(~Schema,~W,~restore_main,~restore_ledger,tail,restore_ledger(world,old))','    case PrototypeFlatLedger{old,tail}: prototype_flat_unwind(~Schema,~W,~restore_main,~restore_ledger,tail,restore_ledger(world,old))\n    case PrototypeFlatPair{space,id,main_old,ledger_old,tail}: prototype_flat_unwind(~Schema,~W,~restore_main,~restore_ledger,tail,restore_main(restore_ledger(world,ledger_old),S.Handle{space,id},main_old))');t.write_text(s)
h=a.output/'experiments/s-integrate/held-adapter.bend';s=h.read_text();defs=dict(re.findall(r'^(def (\w+)\([^\n]*\n.*?)(?=^def |^type |\Z)',s,re.M|re.S));defs={k:v for v,k in defs.items()}
helpers='''type PrototypePendingUndo<-Schema:Data> is Type:
  PrototypePendingUndo{pending:Bool,namespace:U32,id:U32,old:U32,tail:X.PrototypeFlatInverse<Schema>}
def prototype_pending_flush(~Schema:Data,state:PrototypePendingUndo<Schema>) -> X.PrototypeFlatInverse<Schema>:
  match state:
    case PrototypePendingUndo{False{},_,_,_,tail}: tail
    case PrototypePendingUndo{True{},space,id,old,tail}: X.PrototypeFlatMain{space,id,old,tail}
def prototype_pending_main(~Schema:Data,space:U32,id:U32,old:U32,state:PrototypePendingUndo<Schema>) -> PrototypePendingUndo<Schema>:
  PrototypePendingUndo{True{},space,id,old,prototype_pending_flush(~Schema,state)}
def prototype_pending_ledger(~Schema:Data,old:U32,state:PrototypePendingUndo<Schema>) -> PrototypePendingUndo<Schema>:
  match state:
    case PrototypePendingUndo{False{},_,_,_,tail}: PrototypePendingUndo{False{},0,0,0,X.PrototypeFlatLedger{old,tail}}
    case PrototypePendingUndo{True{},space,id,main_old,tail}: PrototypePendingUndo{False{},0,0,0,X.PrototypeFlatPair{space,id,main_old,old,tail}}
'''
new=[helpers]
# Clone complete provider families; leave original private/public provider definitions available.
for oldtype,newtype,start,end in [('PrototypeFlatRowOwner','PrototypePairedRowOwner','type PrototypeFlatRowOwner','def prototype_flatfold_motion_converted'),('PrototypeJournalLedgerRowOwner','PrototypePairedLedgerRowOwner','type PrototypeJournalLedgerRowOwner','def prototype_journalledger_health_pack')]:
 block=s[s.index(start):s.index(end)]
 # second block type only; provider definitions are separated by packing functions.
 if oldtype=='PrototypeJournalLedgerRowOwner':
  block+= '\n'+''.join(defs['prototype_journalledger_health_'+k] for k in ['get','ledger','set_fused_done','set','setledger_done','setledger','invoke'])
 block=block.replace(oldtype,newtype).replace('prototype_flatrows_','prototype_pairedrows_').replace('prototype_journalledger_health_','prototype_pairedledger_health_')
 block=block.replace('undo:X.PrototypeFlatInverse<Schema>','undo:PrototypePendingUndo<Schema>')
 for cap in ['Motion','Health']:block=block.replace(f'undo:X.PrototypeFlatInverse<T.{cap}Schema>',f'undo:PrototypePendingUndo<T.{cap}Schema>')
 for cap in ['Motion','Health']:
  block=block.replace('X.PrototypeFlatMain{space,id,old,undo}',f'prototype_pending_main(~T.{cap}Schema,space,id,old,undo)',1)
  block=block.replace('X.PrototypeFlatLedger{old,undo}',f'prototype_pending_ledger(~T.{cap}Schema,old,undo)',1)
 # ledger-only block has only Health.
 if oldtype=='PrototypeJournalLedgerRowOwner':block=block.replace('~T.MotionSchema','~T.HealthSchema')
 new.append(block)
# Insert new provider definitions before existing returned/taken callers.
s=s[:s.index('def prototype_flatfold_motion_converted')]+ '\n'.join(new)+'\n'+s[s.index('def prototype_flatfold_motion_converted'):]
for prefix,cap,owner,invoke in [('prototype_flatfold_motion','Motion','PrototypePairedRowOwner','prototype_pairedrows_motion'),('prototype_journalledger_health','Health','PrototypePairedLedgerRowOwner','prototype_pairedledger_health')]:
 # Only change two private adapter boundaries; original opaque callback text untouched.
 for suffix in ['returned','taken']:
  old=defs[prefix+'_'+suffix];b=old.replace('PrototypeFlatRowOwner',owner).replace('PrototypeJournalLedgerRowOwner',owner)
  if suffix=='returned':b=b.replace(',undo,commands,pings,marks,U32.add',f',prototype_pending_flush(~T.{cap}Schema,undo),commands,pings,marks,U32.add')
  else:
   b=b.replace('prototype_flatrows_motion_invoke',invoke+'_invoke').replace('prototype_journalledger_health_invoke',invoke+'_invoke')
   b=b.replace(',selected,undo,marks}',',selected,PrototypePendingUndo{False{},0,0,0,undo},marks}')
  assert old in s;s=s.replace(old,b,1)
h.write_text(s)
# Reconcile standalone and embedded source maps without changing unrelated metadata.
for f in m['sources']:m['sources'][f]=hashlib.sha256((a.output/f).read_bytes()).hexdigest()
(a.output/'overlay.json').write_text(json.dumps(m,indent=2)+'\n');cache=json.load(open(base/'cache-specialization.json'));cache['runtimeSources']=m['sources'];(a.output/'cache-specialization.json').write_text(json.dumps(cache,indent=2)+'\n')
print(a.output)
