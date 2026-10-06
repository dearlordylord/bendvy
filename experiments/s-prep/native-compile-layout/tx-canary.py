#!/usr/bin/env python3
"""Recompile existing actual reached controller C under Os; unchanged full oracle."""
import argparse,pathlib,json,hashlib,os,subprocess,signal,time,importlib.util
p=argparse.ArgumentParser();p.add_argument('--output',type=pathlib.Path,required=True);a=p.parse_args();a.output.mkdir(exist_ok=False);os.sched_setaffinity(0,{10});ROOT=pathlib.Path('/workspace/formal-proofs/bendvy');overlay=pathlib.Path('/tmp/bendvy-joined-flatjournal-ledger-v1');sha=lambda p:hashlib.sha256(pathlib.Path(p).read_bytes()).hexdigest();pins=json.loads((overlay/'overlay.json').read_text())['sources'];assert len(pins)==29 and all(sha(overlay/n)==v for n,v in pins.items());clang=pathlib.Path('/tmp/bendvy-clang19-diagnostic/clang19');Ifile=ROOT/'experiments/s-prep/owned-write-query-integration/controls-run.py';spec=importlib.util.spec_from_file_location('independent',Ifile);I=importlib.util.module_from_spec(spec);spec.loader.exec_module(I)
r={'status':'INCOMPLETE','scope':'Same existing actual controller C under Os; no Bend/proof/checker reruns or source changes','CPU':10,'sourcePins':pins,'clangWrapperSHA256':sha(clang),'independentOracleSHA256':sha(Ifile),'recipeSHA256':sha(pathlib.Path(__file__)),'commands':[],'cases':[],'performanceAcceptance':False}
def save():(a.output/'evidence.json').write_text(json.dumps(r,indent=2)+'\n')
def run(argv,cap):
 argv=list(map(str,argv));env=os.environ.copy();env['BENDVY_CLANG19_ROOT']='/tmp/bendvy-clang19-diagnostic/root';t=time.monotonic();c=subprocess.Popen(argv,stdout=subprocess.PIPE,stderr=subprocess.STDOUT,text=True,start_new_session=True,env=env);timed=False
 try:out=c.communicate(timeout=cap)[0]
 except subprocess.TimeoutExpired:timed=True;os.killpg(c.pid,signal.SIGKILL);out=c.communicate()[0]
 r['commands'].append({'argv':argv,'limitSeconds':cap,'seconds':time.monotonic()-t,'exit':c.returncode,'timeout':timed,'output':out});save();assert c.returncode==0 and not timed,r['commands'][-1];return out
try:
 for kind,base in [('original',pathlib.Path('/tmp/bendvy-joined-flatjournal-ledger-tx-v1/actual')),('lost-mark',pathlib.Path('/tmp/bendvy-joined-flatjournal-ledger-lost-mark-v1/actual')),('inverse-order',pathlib.Path('/tmp/bendvy-joined-flatjournal-ledger-inverse-order-v1/actual'))]:
  receipt=json.loads((base/'evidence.json').read_text());assert receipt['status']==('FINITE_ACTUAL_TX_CACHE_FIELDS_PASS' if kind=='original' else 'DETECTED_COMPILING_RUNTIME_COUNTEREXAMPLE');outputs={}
  for mode in ('cached','raw'):
   outputs[mode]={}
   for lane in ('motion','health'):
    folder=base/mode/lane;name='cache-tx-'+lane+'-controls';source=folder/(name+'.c');oldbin=folder/(name+'-native');original=folder/(name+'-native.jsonl');expected=[json.loads(x) for x in original.read_text().splitlines()];assert len(expected)==72
    binding=[entry for entry in receipt['cases'] if entry['getter']==mode and entry['schema']==lane and entry['backend']=='Native'];assert len(binding)==1 and binding[0]['programSHA256']==sha(oldbin) and binding[0]['rawSHA256']==sha(original),'Original binary/output no longer matches executed receipt'
    case=a.output/(kind+'-'+mode+'-'+lane);case.mkdir();copy=case/'controller.c';copy.write_bytes(source.read_bytes());run([clang,'-std=c11','-Os',copy,'-lpthread','-lm','-o',case/'controller-native'],120);out=run([case/'controller-native','--threads','1','--gpu','off'],5);(case/'observed.jsonl').write_text(out);rows=[json.loads(x) for x in out.splitlines()];assert rows==expected,'Os same-C full fields differ from O3';outputs[mode][lane]=rows
    r['cases'].append({'kind':kind,'mode':mode,'schema':lane,'records':72,'status':'SAME_C_FULL_FIELDS_PASS','inputCPath':str(source),'inputCSHA256':sha(source),'copiedCSHA256':sha(copy),'originalBinarySHA256':sha(oldbin),'originalReceiptSHA256':sha(base/'evidence.json'),'originalFullOutputSHA256':sha(original),'candidateBinarySHA256':sha(case/'controller-native'),'candidateFullOutputSHA256':sha(case/'observed.jsonl')});save()
   combined=[]
   for scenario in range(9):
    for lane in ('motion','health'):combined+=outputs[mode][lane][scenario*8:scenario*8+8]
   assert len(combined)==144
   if kind=='original':assert not I.differences(combined);I.independent(combined)
   else:
    detected=bool(I.differences(combined))
    try:I.independent(combined)
    except AssertionError:detected=True
    assert detected,'Compiled semantic mutant survived Os'
  if kind=='original':assert outputs['cached']==outputs['raw'],'Cache/raw full fields differ under Os'
 r['status']='OS_ACTUAL_TX_ROLLBACK_FOREIGN_ORDER_AND_COMPILING_MUTANTS_FULL_FIELDS_PASS'
except Exception as e:r.update(status='FAIL',error=repr(e));raise
finally:save()
