#!/usr/bin/env python3
"""Finite retained Type/Data payload and operation-order witness, strict refusals."""
import argparse,hashlib,json,os,sys
from pathlib import Path
ROOT=Path('/workspace/formal-proofs/bendvy');sys.path.insert(0,str(ROOT/'experiments/s-prep/fivehour-connected-gates'));import supervisor
p=argparse.ArgumentParser();p.add_argument('--output',type=Path,required=True);a=p.parse_args();os.sched_setaffinity(0,{9});a.output.mkdir(exist_ok=False);here=Path(__file__).resolve().parent;rows=[]
for source in sorted((here/'controls').glob('*.js')):
 target=a.output/source.name;argv=['node','--expose-internals',str(here/'rewrite.cjs'),str(source),str(target)];code,text=supervisor.execute(argv,5)
 if source.stem=='retained-order':
  assert code==0,text;originalCode,original=supervisor.execute(['node',str(source)],5);candidateCode,candidate=supervisor.execute(['node',str(target)],5);assert originalCode==candidateCode==0 and original==candidate
  result=json.loads(candidate);assert result['sameArray'] and result['unchangedAfterPriorThrow'];assert result['raw']=={'kind':'Type','a':11,'b':12,'c':13,'d':14,'stamp':15};assert result['snapshot']==dict(result['raw'],kind='Data');assert result['old']=={'kind':'Type','a':41,'b':42,'c':43,'d':44,'stamp':45};assert result['array'][1]=={'kind':'Type','a':91,'b':92,'c':93,'d':94,'stamp':95};assert result['emptyOld'] and result['emptyWritten']==result['array'][1];assert result['log']==['prior','receiver','prior','receiver','throw']
  rows.append({'label':source.stem,'status':'RETAINED_TYPE_DATA_TRUE_OLD_MODULO_EMPTY_AND_ORDER_PASS','observed':result,'stdoutSHA256':hashlib.sha256(candidate.encode()).hexdigest()});(a.output/'retained-order.json').write_text(candidate)
 else:
  assert code!=0 and not target.exists(),source.stem;rows.append({'label':source.stem,'status':'REFUSED_NO_OUTPUT','diagnostic':text})
(a.output/'evidence.json').write_text(json.dumps({'cpu':9,'perCommandLimitSeconds':5,'controls':rows},indent=2)+'\n');print({'positive':1,'refusals':len(rows)-1,'status':'ALL_EXPECTED'})
