#!/usr/bin/env python3
"""Whole owner/Data retention, remaining argument/exception order, strict refusals."""
import argparse,hashlib,json,os,sys
from pathlib import Path
ROOT=Path('/workspace/formal-proofs/bendvy');sys.path.insert(0,str(ROOT/'experiments/s-prep/fivehour-connected-gates'));import supervisor
p=argparse.ArgumentParser();p.add_argument('--output',type=Path,required=True);a=p.parse_args();os.sched_setaffinity(0,{9});a.output.mkdir(exist_ok=False);here=Path(__file__).resolve().parent;rows=[]
for source in sorted((here/'controls').glob('*.js')):
 target=a.output/source.name;code,text=supervisor.execute(['node','--expose-internals',str(here/'rewrite.cjs'),str(source),str(target)],5)
 if source.stem=='retained-order':
  assert code==0,text;c1,original=supervisor.execute(['node',str(source)],5);c2,candidate=supervisor.execute(['node',str(target)],5);assert c1==c2==0 and original==candidate
  v=json.loads(candidate);assert v['sameOwner'] and v['sameAux'] and v['sameHandle'];assert v['view']=={'kind':'Data','a':11,'b':12,'c':13,'d':14,'stamp':15};assert v['raw']=={'kind':'Type','a':21,'b':22,'c':23,'d':24,'stamp':25};assert v['owner']['main']==[v['raw']] and v['owner']['view']==v['view'];assert v['owner']['ledger']=={'kind':'Type','a':31,'b':32,'c':33,'d':34,'stamp':35};assert v['aux']=={'kind':'Type','a':41,'b':42,'c':43,'d':44,'stamp':45};assert v['handle']=={'namespace':7,'id':1};assert v['log']==['handle','flag','owner','aux','handle','flag'];(a.output/'retained-order.json').write_text(candidate);rows.append({'label':source.stem,'status':'WHOLE_TYPE_OWNER_DATA_RETAINED_AND_REMAINING_EVALUATION_EXCEPTION_ORDER_PASS','observed':v,'stdoutSHA256':hashlib.sha256(candidate.encode()).hexdigest()})
 else:
  assert code!=0 and not target.exists(),source.stem;rows.append({'label':source.stem,'status':'REFUSED_NO_OUTPUT','diagnostic':text})
(a.output/'evidence.json').write_text(json.dumps({'cpu':9,'runtimeLimitSeconds':5,'controls':rows},indent=2)+'\n');print({'positive':1,'refusals':len(rows)-1,'status':'ALL_EXPECTED'})
