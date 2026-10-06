#!/usr/bin/env python3
"""Fresh original authored Host subject; complete independent comparison, bounded commands."""
from pathlib import Path
import argparse,json,hashlib,gzip,subprocess,signal,os,importlib.util
H=Path(__file__).resolve().parent;ROOT=Path('/workspace/formal-proofs/bendvy');sha=lambda p:hashlib.sha256(p.read_bytes()).hexdigest();p=argparse.ArgumentParser();p.add_argument('--source',type=Path,required=True);p.add_argument('--output',type=Path,required=True);p.add_argument('--host-prefix',required=True);p.add_argument('--schema',choices=['motion','health'],required=True);a=p.parse_args();a.output.mkdir(exist_ok=False);os.sched_setaffinity(0,{9});os.environ['BENDVY_CLANG19_ROOT']='/tmp/bendvy-clang19-diagnostic/root';r={'status':'INCOMPLETE','scope':'Actual original Host candidate, both capture styles of one schema; not full22','commands':[]}
def save():(a.output/'evidence.json').write_text(json.dumps(r,indent=2)+'\n')
def run(cmd,limit,label):
 cmd=list(map(str,cmd));proc=subprocess.Popen(cmd,stdout=subprocess.PIPE,stderr=subprocess.STDOUT,text=True,start_new_session=True);entry={'command':cmd,'limitSeconds':limit};r['commands'].append(entry)
 try:o,_=proc.communicate(timeout=limit)
 except subprocess.TimeoutExpired:
  os.killpg(proc.pid,signal.SIGKILL);o,_=proc.communicate();entry.update(status='TIMEOUT',exit=proc.returncode);(a.output/(label+'.txt')).write_text(o);save();raise RuntimeError(label+' timeout')
 (a.output/(label+'.txt')).write_text(o);entry.update(exit=proc.returncode,outputSHA256=hashlib.sha256(o.encode()).hexdigest());save();assert proc.returncode==0,o;return o
try:
 run(['python3',H/'adapter.py','--source',a.source,'--output',a.output/'adapted','--host-prefix',a.host_prefix,'--schema',a.schema],30,'adapt')
 adapter=json.loads((a.output/'adapted/adaptation.json').read_text());r.update(sourceClosureSHA256=adapter['sourceClosureSHA256'],sourcePins=adapter['sourcePins'],adaptationReceiptSHA256=sha(a.output/'adapted/adaptation.json'),fixturePins=adapter['fixturePins']);entry=Path(adapter['entry'])
 checked=run(['bend',entry,'--check-only'],15,'check');assert 'ALL PROOFS CHECK' in checked
 run(['bend',entry,'-o',a.output/'subject.js'],30,'js-emit');run(['bend',entry,'-o',a.output/'subject.c'],30,'c-emit');run(['/tmp/bendvy-clang19-diagnostic/clang19','-O3',a.output/'subject.c','-pthread','-lm','-o',a.output/'subject.native'],120,'clang')
 def load(name):
  spec=importlib.util.spec_from_file_location(name,ROOT/'experiments/s-integrate'/(name+'.py'));m=importlib.util.module_from_spec(spec);spec.loader.exec_module(m);return m
 D=load('trace-decode');C=load('trace-compare');ref=json.loads(gzip.decompress((H/'original-reference.json.gz').read_bytes()));expected={x['lane']:x for x in ref['results'] if x['schema'].lower()==a.schema};assert set(expected)=={a.schema.capitalize()+'/'+s for s in ['returned-owner','regenerated-closure']};observations=[]
 for backend,cmd in [('js',['node',a.output/'subject.js']),('native',[a.output/'subject.native','--threads','1','--gpu','off'])]:
  raw=run(cmd,5,backend+'-run');decoded=D.decode(raw);(a.output/(backend+'-decoded.json')).write_text(json.dumps(decoded,indent=2)+'\n');actual={x['lane']:x for x in decoded['results']};assert len(actual)==2 and actual.keys()==expected.keys();diff=[]
  for lane in sorted(expected):
   for channel in C.CHANNELS:C.difference(expected[lane][channel],actual[lane][channel],lane+'.'+channel,diff)
  (a.output/(backend+'-differences.json')).write_text(json.dumps(diff,indent=2)+'\n');assert not diff,(backend,diff[:3]);observations.append({'backend':backend,'fullSelectedChannelsEqual':True,'lanes':sorted(actual),'channels':list(C.CHANNELS),'decodedSHA256':sha(a.output/(backend+'-decoded.json'))})
 r.update(status='FRESH_ORIGINAL_SLOT_HOST_SCHEMA_BOTH_CAPTURES_BOTH_BACKENDS_PASS',observations=observations,generatedPins={n:sha(a.output/n) for n in ['subject.js','subject.c','subject.native']},decoderSHA256=sha(ROOT/'experiments/s-integrate/trace-decode.py'),comparatorSHA256=sha(ROOT/'experiments/s-integrate/trace-compare.py'),independentReferenceSHA256=hashlib.sha256(gzip.decompress((H/'original-reference.json.gz').read_bytes())).hexdigest())
except Exception as error:r.update(status='FAIL_OR_LIMIT',error=repr(error));raise
finally:save()
