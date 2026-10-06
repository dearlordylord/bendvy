#!/usr/bin/env python3
"""Fresh route counters confined to the new handoff entry, with exact literal outputs."""
import pathlib,json,hashlib,sys,os,argparse
H=pathlib.Path(__file__).resolve().parent;ROOT=pathlib.Path('/workspace/formal-proofs/bendvy');sys.path.insert(0,str(ROOT/'experiments/s-prep/fivehour-connected-gates'));from supervisor import execute
p=argparse.ArgumentParser();p.add_argument('--pipeline',type=pathlib.Path,required=True);p.add_argument('--output',type=pathlib.Path,required=True);a=p.parse_args();a.output.mkdir(exist_ok=False);os.sched_setaffinity(0,{7});sha=lambda p:hashlib.sha256(p.read_bytes()).hexdigest();r={'status':'INCOMPLETE','CPU':7,'scope':'Fresh actual candidate-entry counters and all32 independent literal records; no old supplied-cursor denominator or timing','commands':[],'cases':[]}
def save():(a.output/'evidence.json').write_text(json.dumps(r,indent=2)+'\n')
def run(argv,label):
 code,out=execute(list(map(str,argv)),5);f=a.output/(label+'.txt');f.write_text(out);r['commands'].append({'argv':list(map(str,argv)),'capSeconds':5,'exit':code,'outputSHA256':sha(f)});save();assert code==0,out[-1000:];return out
try:
 catalog=json.loads((H/'row-input-pins.json').read_text());programs=json.loads((a.pipeline/'evidence.json').read_text());assert programs['status']=='FROZEN_FOUR_EXACT_DIRECT_MOTION_FIXTURE_PROGRAMS_PASS'
 for rec in programs['programs']:
  pin=catalog[rec['sourceSHA256']];label=rec['label'];source=pathlib.Path(rec['finalPath']);assert sha(source)==rec['finalSHA256'];out=a.output/(label+'.js');run(['node','--expose-internals',H/'route.cjs',source,out,pin['schema']],label+'-derive');text=run(['node',out],label+'-run');lines=text.splitlines();markers=[x for x in lines if x.startswith('BENDVY_HANDOFF_ROUTE ')];assert len(markers)==1;counts=json.loads(markers[0].split(' ',1)[1]);observed='\n'.join(x for x in lines if not x.startswith('BENDVY_HANDOFF_ROUTE '))+'\n';assert observed==pathlib.Path(pin['storedOutput']).read_text();assert len(observed.splitlines())==8
  assert counts['flatfold']==2 and all(counts[k]>0 for k in counts if k!='flatfold'),counts
  r['cases'].append({'label':label,'sourceSHA256':sha(source),'diagnosticSHA256':sha(out),'records':8,'newEntryScopedCounts':counts,'entryAndRetainedGetterSetterReached':True});save()
 r.update(status='FRESH_NEW_HANDOFF_SCOPED_ROUTE_AND_32_LITERALS_PASS',records=32,recipeSHA256=sha(H/'route.cjs'),runnerSHA256=sha(pathlib.Path(__file__)))
except Exception as e:r.update(status='FAILED',error=repr(e))
save();print(json.dumps({'status':r['status'],'cases':len(r['cases']),'error':r.get('error')}));sys.exit(0 if r['status']=='FRESH_NEW_HANDOFF_SCOPED_ROUTE_AND_32_LITERALS_PASS' else 1)
