#!/usr/bin/env python3
"""Fresh original E11 full input matrix on persistent Slot Host; original comparator."""
from pathlib import Path
import argparse,json,hashlib,subprocess,signal,os,importlib.util
H=Path(__file__).resolve().parent;ROOT=Path('/workspace/formal-proofs/bendvy');sha=lambda p:hashlib.sha256(p.read_bytes()).hexdigest();p=argparse.ArgumentParser();p.add_argument('--adapted',type=Path,required=True);p.add_argument('--output',type=Path,required=True);a=p.parse_args();a.output.mkdir(exist_ok=False);os.sched_setaffinity(0,{9});os.environ['BENDVY_CLANG19_ROOT']='/tmp/bendvy-clang19-diagnostic/root';ad=json.loads((a.adapted/'adaptation.json').read_text());core=a.adapted/'core';assert all(sha(core/Path(n).name)==h for n,h in ad['sourcePins'].items()) and all(sha(core/n)==h for n,h in ad['fixturePins'].items());r={'status':'INCOMPLETE','scope':'Fresh original E11 actual Slot Host matrix; semantic mutants separate; no full22','sourcePins':ad['sourcePins'],'sourceClosureSHA256':ad['sourceClosureSHA256'],'adaptationReceiptSHA256':sha(a.adapted/'adaptation.json'),'commands':[],'publicReference':[],'actual':[],'failures':[]}
def save():(a.output/'evidence.json').write_text(json.dumps(r,indent=2)+'\n')
def run(cmd,limit,label):
 cmd=list(map(str,cmd));proc=subprocess.Popen(cmd,stdout=subprocess.PIPE,stderr=subprocess.STDOUT,text=True,start_new_session=True);entry={'command':cmd,'limitSeconds':limit};r['commands'].append(entry)
 try:o,_=proc.communicate(timeout=limit)
 except subprocess.TimeoutExpired:os.killpg(proc.pid,signal.SIGKILL);o,_=proc.communicate();entry.update(status='TIMEOUT',exit=proc.returncode);(a.output/(label+'.txt')).write_text(o);save();raise RuntimeError(label+' timeout')
 (a.output/(label+'.txt')).write_text(o);entry.update(exit=proc.returncode,outputSHA256=hashlib.sha256(o.encode()).hexdigest());save();assert proc.returncode==0,o;return o
try:
 entry=core/'host-retention-controls.bend';out=run(['bend',entry,'--check-only'],15,'check');assert 'ALL PROOFS CHECK' in out;run(['bend',entry,'-o',a.output/'subject.js'],30,'js-emit');run(['bend',entry,'-o',a.output/'subject.c'],30,'c-emit');run(['/tmp/bendvy-clang19-diagnostic/clang19','-O3',a.output/'subject.c','-pthread','-lm','-o',a.output/'subject.native'],120,'clang')
 spec=importlib.util.spec_from_file_location('R',ROOT/'experiments/s-integrate/host-retention-run.py');R=importlib.util.module_from_spec(spec);spec.loader.exec_module(R);reference=ROOT/'experiments/s-integrate-trace/reference-retention.mjs';r.update(comparisonFingerprint=R.comparison_fingerprint(),comparisonRunnerSHA256=sha(ROOT/'experiments/s-integrate/host-retention-run.py'),referenceRunnerSHA256=sha(reference),compactDecoderControls=R.compact_controls())
 for si,schema in enumerate(R.SCHEMAS):
  for li,lane in enumerate(R.LANES):
   label=schema.lower()+'-'+lane
   try:
    ref=json.loads(run(['node',reference,schema,lane],5,label+'-ts'));assert ref['status']=='PASS';r['publicReference'].append(ref);save()
   except Exception as error:r['failures'].append({'schema':schema,'lane':lane,'backend':'TS','error':repr(error)});save();continue
   raw=[]
   for backend,cmd in [('JS',['node',a.output/'subject.js',si,li]),('Native',[a.output/'subject.native',si,li,'--threads','1','--gpu','off'])]:
    try:
     text=run(cmd,5,label+'-'+backend.lower());obs=R.compare_joined(text,ref);obs.update(backend=backend);r['actual'].append(obs);raw.append(text)
    except Exception as error:r['failures'].append({'schema':schema,'lane':lane,'backend':backend,'error':repr(error)})
    save()
   if len(raw)==2:assert raw[0]==raw[1],'Native/JS emitted outputs differ'
 if len(r['publicReference'])==10:R.project(r['publicReference']);r['oraclePerturbations']=R.perturbations(r['publicReference'])
 assert all(sha(core/Path(n).name)==h for n,h in ad['sourcePins'].items()) and all(sha(core/n)==h for n,h in ad['fixturePins'].items());r.update(status='FRESH_ORIGINAL_SLOT_E11_20_CASES_MUTANTS_PENDING' if len(r['actual'])==20 and not r['failures'] else 'PARTIAL_OR_FAILED',generatedPins={n:sha(a.output/n) for n in ['subject.js','subject.c','subject.native']})
except Exception as error:r.update(status='FAIL_OR_LIMIT',error=repr(error));raise
finally:save()
