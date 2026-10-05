#!/usr/bin/env python3
"""Copy checked selected-owner overlay; specialize column operations per backend."""
import argparse,hashlib,json,shutil,difflib
from pathlib import Path
import preflight
H=Path(__file__).resolve().parent;sha=lambda p:hashlib.sha256(p.read_bytes()).hexdigest()
p=argparse.ArgumentParser();p.add_argument('--base-overlay',type=Path,required=True);p.add_argument('--output',type=Path,required=True);a=p.parse_args()
base_guard=preflight.base(a.base_overlay)
m=json.load(open(a.base_overlay/'overlay.json'));assert all(sha(a.base_overlay/n)==v for n,v in m['sources'].items())
a.output.mkdir(exist_ok=False);receipt={'scope':'Isolated ordinary finite construction, not accepted candidate','baseManifestSHA256':sha(a.base_overlay/'overlay.json'),'backends':{}}
for backend in ['native','javascript']:
 target=a.output/backend;shutil.copytree(a.base_overlay,target);core=target/'experiments/s-integrate';adapter=core/'held-adapter.bend';old=adapter.read_text();new=old.replace('type MotionContext is Type:',(H/'cached-take.bend.txt').read_text()+'\ntype MotionContext is Type:').replace('import ./held.bend as J','import ./held.bend as J\nimport ./native-columns.bend as NC')
 for main,aux,flag in [('Position','Velocity','Selected'),('Vitals','Armor','Tracked')]:
  anchor=f'S.take_rows(T.{main},T.{aux},T.{flag},rows,id)';assert new.count(anchor)==1;new=new.replace(anchor,f'cached_take_rows(T.{main},T.{aux},T.{flag},rows,id)')
  anchor=f'Array.set(Maybe<T.{main}>,m,U32.sub(id,1),Some{{main}})';assert new.count(anchor)==1;new=new.replace(anchor,f'NC.set(Maybe<T.{main}>,m,capacity,U32.sub(id,1),Some{{main}})')
 new=new.replace('S.Rows{m,a,f,capacity,depth,high},pending,_,mode}', 'S.Rows{m,a,f,+capacity,depth,high},pending,_,mode}')
 adapter.write_text(new);shutil.copyfile(H/('column-'+backend+'.bend'),core/'native-columns.bend');sources={n:sha(target/n) for n in m['sources']};sources[str((core/'native-columns.bend').relative_to(target))]=sha(core/'native-columns.bend')
 changed=[n for n,h in m['sources'].items() if sources[n]!=h];assert changed==['experiments/s-integrate/held-adapter.bend'];(target/'overlay.json').write_text(json.dumps(dict(m,sources=sources),indent=2)+'\n')
 (target/'column-adapter.diff').write_text(''.join(difflib.unified_diff(old.splitlines(True),new.splitlines(True))))
 receipt['backends'][backend]={'sourceClosure':sources,'changedOnlyTemporary':changed,'columnSHA256':sha(core/'native-columns.bend'),'adapterSHA256':sha(adapter),'diffSHA256':sha(target/'column-adapter.diff')}
(a.output/'base-provenance.json').write_text(json.dumps(base_guard,indent=2)+'\n')
(a.output/'receipt.json').write_text(json.dumps(receipt,indent=2)+'\n');print('PREPARED_DISTINCT_BACKEND_CLOSURES')
