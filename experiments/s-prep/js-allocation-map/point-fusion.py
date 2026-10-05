#!/usr/bin/env python3
"""Source-level private point-dispatch fusion; preserves fallback and callback API."""
import argparse,hashlib,json,shutil,re
from pathlib import Path
p=argparse.ArgumentParser();p.add_argument('--input',type=Path,required=True);p.add_argument('--output',type=Path,required=True);a=p.parse_args();
originalPins=json.loads((a.input/'overlay.json').read_text())['sources'];assert all(hashlib.sha256((a.input/n).read_bytes()).hexdigest()==v for n,v in originalPins.items());
shutil.copytree(a.input,a.output);core=a.output/'experiments/s-integrate';source=core/'held-adapter.bend';text=source.read_text();before=hashlib.sha256(text.encode()).hexdigest()
for lane,sc,main,view,aux,flag,ledger,mode in [('motion','Motion','Position','PositionView','Velocity','Selected','MotionLedger','MotionMode'),('health','Health','Vitals','VitalsView','Armor','Tracked','HealthLedger','HealthMode')]:
 rowStart=text.index('def '+lane+'_row(');rowEnd=text.find('\ndef ',rowStart+1);rowEnd=len(text) if rowEnd<0 else rowEnd
 row=text[rowStart:rowEnd];checked=next(x for x in text.splitlines() if x.startswith('def '+lane+'_checked('));prefix=checked.split(',valid:Bool,owner:',1)[0].replace('def '+lane+'_checked(','def '+lane+'_fields_checked(');result=checked.split(' -> X.Tx<',1)[1]
 M=f'CC.Cache<T.{main},T.{view}>';L=f'CC.Cache<T.{ledger},T.LedgerView>';rows=f'S.Rows<{M},T.{aux},T.{flag}>';handle=f'S.Handle<T.{sc}Schema>';command=f'S.Command<{M},T.{aux},T.{flag}>';tx=f'X.Tx<S.World<T.{sc}Schema,{M},T.{aux},T.{flag},{L},T.{mode}>,{handle},{command}>'
 header=prefix+f',valid:Bool,ns:U32,next:U32,rows:{rows},pending:List<{command}>,ledger:Maybe<{L}>,mode:T.{mode},space:U32,+id:U32,undo:List<&2,X.Inverse<{handle}>>,commands:List<{command}>,pings:List<&2,U32>,marks:List<&2,{handle}>) -> X.Tx<'+result
 body=f'''\n  match valid ledger:
    case True{{}} Some{{ledger}}: {lane}_taken(~client,ns,next,pending,ledger,mode,S.Handle{{space,id}},undo,commands,pings,marks,S.take_rows({M},T.{aux},T.{flag},rows,id))
    case _ ledger: client({tx},A.{lane}_read_main,A.{lane}_set_main0,A.{lane}_read_ledger,A.{lane}_set_ledger0,X.Tx{{S.World{{ns,next,rows,pending,ledger,mode}},S.Handle{{space,id}},undo,commands,pings,marks}})
'''
 old=f'{lane}_checked(~client,U32.is_eq(ns,space),X.Tx{{S.World{{ns,next,rows,pending,ledger,mode}},S.Handle{{space,id}},undo,commands,pings,marks}})';new=f'{lane}_fields_checked(~client,U32.is_eq(ns,space),ns,next,rows,pending,ledger,mode,space,id,undo,commands,pings,marks)';assert row.count(old)==1
 text=text[:rowStart]+header+body+row.replace(old,new)+text[rowEnd:]
source.write_text(text)
sha=lambda p:hashlib.sha256(p.read_bytes()).hexdigest();manifest=json.loads((a.output/'overlay.json').read_text());manifest['sources']['experiments/s-integrate/held-adapter.bend']=sha(source);manifest['pointFrameFusion']={'recipeSHA256':sha(Path(__file__)),'originalHeldAdapterSHA256':before,'scope':'Private namespace/ledger check takes fields directly; no pre-check World/Handle/Tx reconstruction; actual callback algorithms unchanged'};(a.output/'overlay.json').write_text(json.dumps(manifest,indent=2)+'\n')
cache=json.loads((a.output/'cache-specialization.json').read_text());cache['runtimeClosure']['experiments/s-integrate/held-adapter.bend']=sha(source);cache['specializedClosure']['experiments/s-integrate/held-adapter.bend']=sha(source);cache['runtimeClosureSHA256']=hashlib.sha256(json.dumps(dict(sorted(cache['runtimeClosure'].items())),separators=(',',':')).encode()).hexdigest();(a.output/'cache-specialization.json').write_text(json.dumps(cache,indent=2)+'\n');manifest['cacheSpecialization']=cache;(a.output/'overlay.json').write_text(json.dumps(manifest,indent=2)+'\n')
print(json.dumps(manifest['pointFrameFusion']))
