#!/usr/bin/env python3
import argparse,collections,hashlib,importlib.util,json,os,pathlib,re,signal,subprocess,sys,time
p=argparse.ArgumentParser();p.add_argument('--output',type=pathlib.Path,required=True);a=p.parse_args();a.output.mkdir(exist_ok=False);os.sched_setaffinity(0,{10});HERE=pathlib.Path(__file__).resolve().parent;ROOT=pathlib.Path('/workspace/formal-proofs/bendvy');catalog=json.loads((HERE/'input-pins.json').read_text());sha=lambda p:hashlib.sha256(pathlib.Path(p).read_bytes()).hexdigest();r={'status':'INCOMPLETE','CPU':10,'runtimeSeconds':5,'commands':[],'cases':[],'witnesses':[],'counts':[]}
def save():(a.output/'evidence.json').write_text(json.dumps(r,indent=2)+'\n')
def run(argv,limit=5):
 start=time.monotonic();child=subprocess.Popen(list(map(str,argv)),stdout=subprocess.PIPE,stderr=subprocess.STDOUT,text=True,start_new_session=True);timed=False
 try:out=child.communicate(timeout=limit)[0]
 except subprocess.TimeoutExpired:timed=True;os.killpg(child.pid,signal.SIGKILL);out=child.communicate()[0]
 r['commands'].append({'argv':list(map(str,argv)),'limitSeconds':limit,'exit':child.returncode,'timeout':timed,'seconds':time.monotonic()-start,'output':out});save();assert child.returncode==0,r['commands'][-1];return out
spec=importlib.util.spec_from_file_location('V',ROOT/'experiments/s-integrate/measurement-bend-run.py');V=importlib.util.module_from_spec(spec);spec.loader.exec_module(V)
sys.path.insert(0,str(ROOT/'experiments/s-prep/fivehour-connected-gates'));mods=[]
for name,path in [('I',ROOT/'experiments/s-prep/owned-write-query-integration/controls-run.py'),('S',ROOT/'experiments/s-prep/fivehour-connected-gates/suppressed-owner.py')]:
 spec=importlib.util.spec_from_file_location(name,path);m=importlib.util.module_from_spec(spec);spec.loader.exec_module(m);mods.append(m)
I,S=mods
try:
 groups={};direct=json.load(open('/tmp/bendvy-direct-payload-tx-original-v2/probe-evidence.json'))['programs'];r['validatorPins']={str(p):sha(p) for p in [ROOT/'experiments/s-prep/owned-write-query-integration/controls-run.py',ROOT/'experiments/s-prep/fivehour-connected-gates/suppressed-owner.py',ROOT/'experiments/s-integrate/measurement-bend-run.py']}
 for digest,pin in catalog.items():
  source=pathlib.Path(pin['inputPath']);assert sha(source)==digest;target=a.output/(pin['label']+'.js');run(['node','--expose-internals',HERE/'rewrite.cjs',source,target]);r['cases'].append({'label':pin['label'],'inputSHA256':digest,'outputSHA256':sha(target),'recipeSHA256':sha(str(target)+'.recipe.json')});save()
  if pin['label'].startswith('direct-'):
   before=run(['node',source]);after=run(['node',target]);assert before==after;lines=[json.loads(x) for x in after.splitlines()];assert len(lines)==72;(a.output/(pin['label']+'.jsonl')).write_text(after);i=int(pin['label'].split('-')[1]);item=direct[i];groups['suppressed' if 'suppressed' in item['source'] else 'normal','raw' if '/raw/' in item['source'] else 'cached',pin['schema']]=lines
   counted=a.output/(pin['label']+'-reached.js');run(['node','--expose-internals',HERE.parent/'direct-payload-tx-controls/counter.cjs',target,counted]);observed=run(['node',counted]);marker=next(x for x in observed.splitlines() if x.startswith('DIRECT-RAW-CALLS:'));calls=json.loads(marker.split(':',1)[1]);assert all(n>0 for n in calls.values());r['cases'][-1].update(records=72,actualReachedDerivedCalls=calls);save();continue
  schema='Motion' if pin['schema']=='motion' else 'Health';profile=a.output/(pin['label']+'-nine');profile.mkdir();text=target.read_text();old='return $'+pin['schema']+'_batch$(256, 64);';assert text.count(old)==1;text=text.replace(old,'return $'+pin['schema']+'_batch$(256, 8);',1);(profile/'candidate.js').write_text(text)
  run(['python3',ROOT/'experiments/s-prep/fivehour-measurement/prepare-ts.py','--source',ROOT/'experiments/s-integrate/measurement-samples-reference.mjs','--output',profile/'reference.mjs','--schema',schema,'--batch','8']);tsraw=run(['node',profile/'reference.mjs']);jsraw=run(['node',profile/'candidate.js']);(profile/'TS.txt').write_text(tsraw);(profile/'JS.txt').write_text(jsraw);ts=json.loads(tsraw);records=[x for x in jsraw.splitlines() if x.startswith('{')];assert len(records)==9
  for line,world in zip(records,[ts['warmup'],*ts['samples']]):V.validate(line,schema,False,256,world);assert V.normalized(json.loads(line),schema)==world['final']
  r['cases'][-1]['nineFullFieldsFreshTSPass']=True
  # Trusted direct helper witnesses; repair only the shared emitter's dollar replacement interpolation.
  witness=a.output/(pin['label']+'-retained.js');run(['node','--expose-internals',ROOT/'experiments/s-prep/js-owner-store-elision/witnesses/held-cache.cjs',target,witness,pin['schema']]);t=witness.read_text()
  for name in re.findall(r'^function ([$\w]+)\(',target.read_text(),re.M):
   bad=name.replace('$$','$')
   if bad!=name:t=re.sub(r'(?<![$\w])'+re.escape(bad)+r'(?![$\w])',lambda _:name,t)
  needle='console.log(JSON.stringify({schema,status:';checks='assert.equal(writtenLedger.main.raw.$,tags.raw);assert.equal(writtenLedger.ledger.raw.$,tags.ledgerRaw);assert.equal(writtenLedger.ledger.raw.epoch,4);if(schema==="motion"){assert.equal(writtenLedger.main.raw.frame,7)}else{assert.equal(writtenLedger.main.raw.reserve,9);assert.equal(writtenLedger.main.raw.class,2)};\n';assert t.count(needle)==1;t=t.replace(needle,checks+needle);witness.write_text(t);observed=run(['node',witness]);r['witnesses'].append({'schema':schema,'observed':json.loads(observed),'programSHA256':sha(witness)});save()
 def combine(a,b):return [v for scenario in range(9) for rows in (a,b) for v in rows[scenario*8:scenario*8+8]]
 normals={};suppressed={}
 for getter in ('cached','raw'):
  normal=combine(groups['normal',getter,'motion'],groups['normal',getter,'health']);no_op=combine(groups['suppressed',getter,'motion'],groups['suppressed',getter,'health']);I.independent(normal);assert not I.differences(normal);assert no_op==S.expected_noop(normal) and no_op!=normal
  for block in range(36):assert normal[block*4]['value']==(46 if block//4==0 else 3606 if block//4==8 else 4294967295)
  normals[getter]=normal;suppressed[getter]=no_op
 assert normals['cached']==normals['raw'] and suppressed['cached']==suppressed['raw'];r['actualDirectFullRecordsIndependentSuppressionPass']=576
 # Count the exact same constructor kinds before/after in the normal timed phase.
 for role,source in [('before',pathlib.Path('/tmp/bendvy-js-final-profile-chain/baseline.js')),('after',a.output/'baseline.js')]:
  profile=a.output/(role+'-profile');run(['python3',ROOT/'experiments/s-prep/js-profile/run.py','--generated-js',source,'--output',profile,'--cpu','10','--no-gc'],25);assert json.load(open(profile/'evidence.json'))['status']=='PROFILE_AND_NINE_FULL_WORLDS_PASS';instrumented=a.output/(role+'-counted.js');run(['node','--expose-internals',ROOT/'experiments/s-prep/js-allocation-map/instrument.cjs',profile/'bend.js',instrumented]);raw=run(['node',instrumented]);(a.output/(role+'-counted.txt')).write_text(raw);counts=json.loads(next(x for x in raw.splitlines() if x.startswith('ALLOCATION-COUNTS:')).split(':',1)[1]);sites=json.load(open(str(instrumented)+'.sites.json'))['sites'];kinds=collections.Counter()
  for site,n in zip(sites,counts):kinds[site['kind'].split('s-integrate/')[-1]]+=n
  ts=json.load(open(profile/'TS.observed.txt'));records=[x for x in raw.splitlines() if x.startswith('{')];assert len(records)==9
  for line,world in zip(records,[ts['warmup'],*ts['samples']]):V.validate(line,'Motion',False,256,world);assert V.normalized(json.loads(line),'Motion')==world['final']
  r['counts'].append({'role':role,'includingMarker':sum(counts),'ordinaryPhase':sum(counts)-1,'kinds':dict(kinds),'countedNineFullFieldsPass':True});save()
 assert r['counts'][0]['kinds']==r['counts'][1]['kinds'];assert r['counts'][0]['ordinaryPhase']==r['counts'][1]['ordinaryPhase']==5498944;r.update(status='TEN_RAW_STORE_ELISIONS_BOTH_NINE_WORLDS_DIRECT576_RETAINED_DATA_UNCHANGED_COUNTS_PASS');save()
except Exception as error:r.update(status='FAILED',error=repr(error));save();raise
print(r['status'])
