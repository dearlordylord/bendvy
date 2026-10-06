#!/usr/bin/env python3
import argparse,hashlib,json,os,pathlib,shutil,signal,subprocess,sys
from fixtures import runtime,oracle,negative
P=pathlib.Path;p=argparse.ArgumentParser();p.add_argument('--source',type=P,required=True);p.add_argument('--output',type=P,required=True);p.add_argument('--cpu',type=int,default=6);a=p.parse_args();a.output.mkdir(parents=True,exist_ok=False);core=a.output/'core';shutil.copytree(a.source/'experiments/s-integrate',core);sha=lambda b:hashlib.sha256(b).hexdigest();pins=json.loads((a.source/'overlay.json').read_text())['sources'];closure=sha(json.dumps(pins,sort_keys=True,separators=(',',':')).encode());assert closure=='a4672d110446195e3ac92911c6f41166b62025811df8816878356d0eafd08a55';assert all(sha((a.source/n).read_bytes())==h for n,h in pins.items());r={'status':'INCOMPLETE','scope':'Generic affine Q handoff/recovery only; exported holes are accepted, not sealed production API. No new HA consumer, Tx, proof or performance gate.','sourceClosureSHA256':closure,'sourceManifest':pins,'recipes':{n:sha((P(__file__).parent/n).read_bytes())for n in ['run.py','fixtures.py']},'commands':[],'subjects':{},'negativeControls':{}};save=lambda:(a.output/'evidence.json').write_text(json.dumps(r,indent=2)+'\n')
def run(argv,cap,label,expected=0):
 entry={'argv':list(map(str,argv)),'limitSeconds':cap,'log':label+'.txt'};r['commands'].append(entry);save();env=os.environ.copy();env['BENDVY_CLANG19_ROOT']='/tmp/bendvy-clang19-diagnostic/root'
 with (a.output/entry['log']).open('w') as f:
  child=subprocess.Popen(['taskset','-c',str(a.cpu),*map(str,argv)],stdout=f,stderr=subprocess.STDOUT,start_new_session=True,env=env)
  try:entry['exit']=child.wait(timeout=cap)
  except subprocess.TimeoutExpired:os.killpg(child.pid,signal.SIGKILL);child.wait();entry['status']='TIMEOUT';save();raise RuntimeError('Deadline '+label)
 text=(a.output/entry['log']).read_text();entry['sha256']=sha(text.encode());save();assert entry['exit']==expected,(entry,text[-2500:]);return text
try:
 run(['bend','version'],5,'version');run(['bend','guide'],5,'guide')
 for schema in ['Motion','Health']:
  for kind in ['owned','array']:
   name=schema.lower()+'-'+kind;f=core/(name+'.bend');f.write_text(runtime(schema,kind));expected=oracle(schema,kind);(a.output/(name+'-oracle.txt')).write_text(expected);v={'fixtureSHA256':sha(f.read_bytes()),'oracleSHA256':sha(expected.encode()),'backends':{}};r['subjects'][name]=v;save();run(['bend',f,'--check-only'],15,name+'-check');js=a.output/(name+'.js');c=a.output/(name+'.c');native=a.output/(name+'-native');run(['bend',f,'-o',js],30,name+'-emitJS');run(['bend',f,'-o',c],30,name+'-emitC');run(['/tmp/bendvy-clang19-diagnostic/clang19','-O3',c,'-o',native,'-lm','-pthread'],120,name+'-clang')
   v['artifacts']={x.name:sha(x.read_bytes())for x in [js,c,native]};save()
   for backend,cmd in [('JS',['node',js]),('Native',[native,'--threads','1','--gpu','off'])]:
    actual=run(cmd,5,name+'-'+backend);assert actual==expected,{'subject':name,'backend':backend,'firstDifference':next(({'line':i,'actual':x,'expected':y} for i,(x,y)in enumerate(zip(actual.splitlines(),expected.splitlines()))if x!=y),{'actualLines':len(actual.splitlines()),'expectedLines':len(expected.splitlines())})};v['backends'][backend]={'status':'FULL_FIELDS_PASS','records':200,'outputSHA256':sha(actual.encode())};save()
 for name in ['clone','cross-schema']:
  f=core/('negative-'+name+'.bend');f.write_text(negative(name));text=run(['bend',f,'--check-only'],15,'negative-'+name,1)
  if name=='clone':assert 'consumed more than once' in text and 'batch' in text
  else:assert 'HealthSchema' in text and 'MotionSchema' in text and 'expected' in text
  r['negativeControls'][name]={'status':'INTENDED_TYPE_REJECTION','fixtureSHA256':sha(f.read_bytes()),'outputSHA256':sha(text.encode())};save()
 assert all(sha((core/P(n).name).read_bytes())==h for n,h in pins.items());r['status']='GENERIC_AFFINE_HANDOFF_FINITE_FIELDS_AND_INTENDED_NEGATIVES_PASS';save()
except BaseException as e:r.update(status='FAIL',error=repr(e));save();raise
