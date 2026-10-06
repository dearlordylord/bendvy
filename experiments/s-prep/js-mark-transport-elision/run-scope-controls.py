#!/usr/bin/env python3
"""Retained full Type/Data fields, invalid/dead/foreign/repeated marks and refusals."""
import argparse,hashlib,json,os,sys
from pathlib import Path
ROOT=Path('/workspace/formal-proofs/bendvy');sys.path.insert(0,str(ROOT/'experiments/s-prep/fivehour-connected-gates'));import supervisor
p=argparse.ArgumentParser();p.add_argument('--output',type=Path,required=True);a=p.parse_args();os.sched_setaffinity(0,{9});a.output.mkdir(exist_ok=False);here=Path(__file__).resolve().parent;rows=[]
for source in sorted((here/'controls').glob('*.js')):
 target=a.output/source.name;code,text=supervisor.execute(['node','--expose-internals',str(here/'rewrite.cjs'),str(source),str(target)],5)
 if source.stem=='retained-invalid':
  assert code==0,text;c1,original=supervisor.execute(['node',str(source)],5);c2,candidate=supervisor.execute(['node',str(target)],5);assert c1==c2==0 and original==candidate
  v=json.loads(candidate);assert v['invalidSnapshot']==[101,102,103,104] and v['exception']=='TypeError' and v['frozenChanged']==[201,202,203,204];assert v['changed']==[2,102,2,104];assert v['oldSnapshot']=={'kind':'Data','a':101,'b':102,'c':103,'d':104};assert v['missing']==[7,8,9,10] and v['emptyChangedNaN']==44
  assert v['main']==[{'kind':'Type','a':11,'b':12,'c':13,'d':14,'stamp':15}];assert v['aux']==[{'kind':'Type','a':21,'b':22,'c':23,'d':24,'stamp':25}];assert v['ledger']=={'value':{'kind':'Type','a':31,'b':32,'c':33,'d':34,'stamp':35}};assert v['pending']==[{'payload':v['main'][0]}] and v['mode']=={'name':'On'};assert v['flags']==[{'flag':4},None,{'flag':8},None] and v['added']==[1,2,3,4] and v['live']==[True,False,True,True];assert [v[k]for k in ['namespace','next','capacity','depth','high']]==[7,99,4,2,3];assert all(v[k]for k in ['sameMain','sameAux','sameLedger','samePending','sameMode','sameLive','sameChanged']);(a.output/'retained-invalid.json').write_text(candidate);rows.append({'label':source.stem,'status':'RETAINED_TYPE_DATA_INVALID_DEAD_FOREIGN_REPEATED_NONMONOTONIC_TICK_EMPTY_LIST_AND_ARRAY_PASS','observed':v,'stdoutSHA256':hashlib.sha256(candidate.encode()).hexdigest()})
 else:
  assert code!=0 and not target.exists(),source.stem;rows.append({'label':source.stem,'status':'REFUSED_NO_OUTPUT','diagnostic':text})
(a.output/'evidence.json').write_text(json.dumps({'cpu':9,'runtimeLimitSeconds':5,'controls':rows},indent=2)+'\n');print({'positive':1,'refusals':len(rows)-1,'status':'ALL_EXPECTED'})
