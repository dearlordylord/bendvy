import argparse,sys,json,importlib.util,statistics,hashlib,os
from pathlib import Path
root=Path(__file__).resolve().parents[3];sys.path.insert(0,str(root/'experiments/s-prep/fivehour-connected-gates'));import supervisor
parser=argparse.ArgumentParser();parser.add_argument('--output',type=Path,required=True);args=parser.parse_args();p=args.output;spec=importlib.util.spec_from_file_location('validator',root/'experiments/s-integrate/measurement-bend-run.py');V=importlib.util.module_from_spec(spec);spec.loader.exec_module(V);os.sched_setaffinity(0,{11})
r={'scope':'Motion JS only, diagnostic; full22 and Native/Health comparison incomplete','samples':[],'status':'INCOMPLETE','sourceEvidence':'evidence.json','programSHA256':hashlib.sha256((p/'Motion-JS/batch.js').read_bytes()).hexdigest()}
try:
 for i in range(14):
  out={}
  for b in (['TS','JS'] if i%2==0 else ['JS','TS']):
   path=p/('Motion.mjs' if b=='TS' else 'Motion-JS/batch.js');code,text=supervisor.execute(['node',str(path)],5);assert code==0;textpath=p/f'Motion-diagnostic-{i}-{b}.txt';textpath.write_text(text);out[b]=text
  ts=json.loads(out['TS']);lines=out['JS'].splitlines();clock=[x for x in lines if x.startswith('BATCH-MILLISECONDS:')];records=[x for x in lines if not x.startswith('BATCH-MILLISECONDS:')];assert len(records)==65 and len(clock)==1 and len(ts['samples'])==64
  for line,world in zip(records,[ts['warmup'],*ts['samples']]):
   V.validate(line,'Motion',False,256,world);assert V.normalized(json.loads(line),'Motion')==world['final']
  r['samples'].append({'JS':float(clock[0].split(':')[1]),'TS':ts['batchMilliseconds'],'full65WorldsEqual':True})
  (p/'motion-js-diagnostic.json').write_text(json.dumps(r,indent=2)+'\n')
 js=statistics.median(x['JS'] for x in r['samples']);ts=statistics.median(x['TS'] for x in r['samples']);r.update(status='DIAGNOSTIC_MOTION_JS_PASS',medianJS=js,medianTS=ts,elapsedRatio=js/ts)
except Exception as e:r.update(status='FAILED_PARTIAL_DIAGNOSTIC',error=repr(e))
finally:(p/'motion-js-diagnostic.json').write_text(json.dumps(r,indent=2)+'\n')
print(json.dumps(r))
