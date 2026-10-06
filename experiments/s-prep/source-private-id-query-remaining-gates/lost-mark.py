#!/usr/bin/env python3
from pathlib import Path
import json,hashlib,shutil,re,subprocess,os,signal,importlib.util,argparse
H=Path(__file__).resolve().parent;ROOT=Path('/workspace/formal-proofs/bendvy');p=argparse.ArgumentParser();p.add_argument('--output',type=Path,required=True);a=p.parse_args();a.output.mkdir(exist_ok=False);os.sched_setaffinity(0,{9});os.environ['BENDVY_CLANG19_ROOT']='/tmp/bendvy-clang19-diagnostic/root';sha=lambda p:hashlib.sha256(p.read_bytes()).hexdigest();base=Path('/tmp/bendvy-private-id-query-tx-controls-v1');receipt=json.loads((base/'evidence.json').read_text());assert receipt['status']=='FRESH_ACTUAL_TYPED_CURSOR_TX_AND_SUPPRESSED_576_PER_BACKEND_PASS';rec=next(x for x in receipt['programs'] if x['label']=='cached-motion');source=Path(rec['sourceRoot'])
for n,h in rec['source29Pins'].items():assert sha(source/Path(n).name)==h
for n,h in rec['extraPins'].items():assert sha(source/n)==h
core=a.output/'core';shutil.copytree(source,core);f=core/'held-adapter.bend';s=f.read_text();b=re.search(r'^def prototype_packed_row_set_done\(.*?(?=\ndef |\Z)',s,re.M|re.S)[0];needle='X.PrototypeFlatMark{space,id,marks}';assert b.count(needle)==1;f.write_text(s.replace(b,b.replace(needle,'marks'),1));fixture=core/'cache-tx-motion-controls.bend';assert 'HA.prototype_cursor_flatfold_motion(~client,Q.PrototypeIdCursor{namespace,[id]}' in fixture.read_text();r={'status':'INCOMPLETE','scope':'One fresh source-bound Motion cached cursor subject; reached Main mark omission only','parentReceiptSHA256':sha(base/'evidence.json'),'source29Pins':{n:sha(core/Path(n).name) for n in rec['source29Pins']},'extraPins':{n:sha(core/n) for n in rec['extraPins']},'originalSetterSHA256':hashlib.sha256(b.encode()).hexdigest(),'mutation':'prototype_packed_row_set_done: X.PrototypeFlatMark{space,id,marks} -> marks','commands':[]}
def run(cmd,limit,label):
 cmd=list(map(str,cmd));pr=subprocess.Popen(cmd,stdout=subprocess.PIPE,stderr=subprocess.STDOUT,text=True,start_new_session=True)
 try:o,_=pr.communicate(timeout=limit)
 except subprocess.TimeoutExpired:os.killpg(pr.pid,signal.SIGKILL);o,_=pr.communicate();(a.output/(label+'.stdout')).write_text(o);raise
 (a.output/(label+'.stdout')).write_text(o);r['commands'].append({'command':cmd,'limitSeconds':limit,'exit':pr.returncode,'outputSHA256':hashlib.sha256(o.encode()).hexdigest()});assert pr.returncode==0,o;return o
try:
 run(['bend',fixture,'--check-only'],15,'check');run(['bend',fixture,'-o',a.output/'subject.js'],30,'js-emit');run(['bend',fixture,'-o',a.output/'subject.c'],30,'c-emit');run(['/tmp/bendvy-clang19-diagnostic/clang19','-O3',a.output/'subject.c','-pthread','-lm','-o',a.output/'subject.native'],120,'clang')
 sp=importlib.util.spec_from_file_location('I',ROOT/'experiments/s-prep/owned-write-query-integration/controls-run.py');I=importlib.util.module_from_spec(sp);sp.loader.exec_module(I)
 health=[json.loads(x) for x in (base/'cached-health-js-run.stdout').read_text().splitlines()];cases=[]
 for backend,cmd in [('js',['node',a.output/'subject.js']),('native',[a.output/'subject.native','--threads','1','--gpu','off'])]:
  lines=[json.loads(x) for x in run(cmd,5,backend+'-run').splitlines()];assert len(lines)==72;joined=[]
  for scenario in range(9):joined+=lines[scenario*8:scenario*8+8]+health[scenario*8:scenario*8+8]
  errors=None
  try:I.independent(joined)
  except Exception as e:errors=repr(e)
  diffs=I.differences(joined);assert errors or diffs,'Protected oracle failed to detect reached mark omission';cases.append({'backend':backend,'records':72,'protectedIndependentFailure':errors,'protectedDifferenceCount':len(diffs)})
 r.update(status='DETECTED_COMPILING_RUNTIME_COUNTEREXAMPLE',cases=cases,generatedPins={n:sha(a.output/n) for n in ['subject.c','subject.js','subject.native']},oracleSHA256=sha(ROOT/'experiments/s-prep/owned-write-query-integration/controls-run.py'))
finally:(a.output/'evidence.json').write_text(json.dumps(r,indent=2)+'\n')
