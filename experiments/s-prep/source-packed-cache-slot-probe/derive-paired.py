#!/usr/bin/env python3
from pathlib import Path
import json,hashlib,re,shutil,argparse
H=Path(__file__).resolve().parent;p=argparse.ArgumentParser();p.add_argument('--output',type=Path,required=True);p.add_argument('--packed-input',type=Path,default=Path('/tmp/bendvy-packed-main-slot-both-v3'));p.add_argument('--paired-input',type=Path,default=Path('/tmp/bendvy-paired-journal-v2'));a=p.parse_args();base=a.packed_input;pair=a.paired_input;sha=lambda p:hashlib.sha256(p.read_bytes()).hexdigest()
def verify(root,digest,legacy=False):
 m=json.loads((root/'overlay.json').read_text());c=json.loads((root/'cache-specialization.json').read_text());s=m['sources'];assert len(s)==29 and hashlib.sha256(json.dumps(s,sort_keys=True,separators=(',',':')).encode()).hexdigest()==digest and c==m['cacheSpecialization'] and c['runtimeClosure']==s and c['specializedClosure']==s and c['runtimeClosureSHA256']==digest and ((legacy and 'specializedClosureSHA256' not in c) or (not legacy and c['specializedClosureSHA256']==digest))
 for n,h in s.items():assert sha(root/n)==h
 return m,c
m,c=verify(base,'3cbe3d7b076743d074e693d959572a47c485c3a17078a5d1f20a691f47618bef');pm,pc=verify(pair,'a72494c68499f96732c88c9e65a14a00443c972fd82c7de593aa632bb95fcc82',legacy=True);assert not a.output.exists();shutil.copytree(base,a.output);r=a.output/'experiments/s-integrate';(r/'transaction.bend').write_bytes((pair/'experiments/s-integrate/transaction.bend').read_bytes());s=(r/'held-adapter.bend').read_text();ps=(pair/'experiments/s-integrate/held-adapter.bend').read_text();helpers=ps[ps.index('type PrototypePendingUndo'):ps.index('type PrototypePairedRowOwner')];assert helpers.count('def prototype_pending_')==3;anchor=s.index('type PrototypePackedMotionRowOwner');s=s[:anchor]+helpers+'\n'+s[anchor:]
# Change only appended packed row definitions and their exact returned/taken boundaries.
for owner,cap,prefix in [('PrototypePackedMotionRowOwner','Motion','prototype_packed_prototype_flatfold_motion'),('PrototypePackedHealthRowOwner','Health','prototype_packed_prototype_journalledger_health')]:
 pattern=r'^type '+owner+r'.*?(?=\n(?:def|type) |\Z)';b=re.search(pattern,s,re.M|re.S)[0];new=b.replace('undo:X.PrototypeFlatInverse<T.'+cap+'Schema>','undo:PrototypePendingUndo<T.'+cap+'Schema>');assert b!=new;s=s.replace(b,new,1)
 rowprefix='prototype_packed_row_' if cap=='Motion' else 'prototype_packed_prototype_journalledger_health_'
 for match in list(re.finditer(r'^def '+rowprefix+r'(?:get|ledger|set_done|set|set_fused_done|setledger_done|setledger|invoke)\(.*?(?=\n(?:def|type) |\Z)',s,re.M|re.S)):
  b=match[0];new=b.replace('undo:X.PrototypeFlatInverse<T.'+cap+'Schema>','undo:PrototypePendingUndo<T.'+cap+'Schema>').replace('X.PrototypeFlatMain{space,id,old,undo}','prototype_pending_main(~T.'+cap+'Schema,space,id,old,undo)').replace('X.PrototypeFlatLedger{old,undo}','prototype_pending_ledger(~T.'+cap+'Schema,old,undo)');s=s.replace(b,new,1)
 for suffix in ['taken','returned']:
  b=re.search(r'^def '+prefix+'_'+suffix+r'\(.*?(?=\n(?:def|type) |\Z)',s,re.M|re.S)[0]
  if suffix=='taken':new=b.replace(',selected,undo,marks}',',selected,PrototypePendingUndo{False{},0,0,0,undo},marks}')
  else:new=b.replace(',undo,commands,pings,marks,U32.add',',prototype_pending_flush(~T.'+cap+'Schema,undo),commands,pings,marks,U32.add')
  assert new!=b;s=s.replace(b,new,1)
(r/'held-adapter.bend').write_text(s);new={n:sha(a.output/n) for n in m['sources']};digest=hashlib.sha256(json.dumps(new,sort_keys=True,separators=(',',':')).encode()).hexdigest();c.update(runtimeClosure=new,specializedClosure=new,runtimeClosureSHA256=digest,specializedClosureSHA256=digest);m.update(sources=new,cacheSpecialization=c)
for n,d in [('overlay.json',m),('cache-specialization.json',c)]:(a.output/n).write_text(json.dumps(d,indent=2)+'\n')
print(digest)
