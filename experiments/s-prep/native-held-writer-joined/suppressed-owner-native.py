import copy,hashlib,importlib.util,json,os,pathlib,shutil
H=pathlib.Path('/tmp/bendvy-threehour-js-writer-method');OUT=pathlib.Path('/tmp/bendvy-threehour-native-writer-joined-suppressed-owner');root=pathlib.Path('/workspace/formal-proofs/bendvy');os.sched_setaffinity(0,{8});sha=lambda p:hashlib.sha256(p.read_bytes()).hexdigest()
def load(name,path):
 s=importlib.util.spec_from_file_location(name,path);m=importlib.util.module_from_spec(s);s.loader.exec_module(m);return m
FA=load('fused',H/'fused-adaptation.py');B=load('build',root/'experiments/t05/run.py');base=pathlib.Path('/tmp/bendvy-threehour-native-writer-joined-tx');baseline=[json.loads(x) for x in (base/'cached/cache-tx-controls-native.jsonl').read_text().splitlines()];assert len(baseline)==144;expected=copy.deepcopy(baseline)
# Finite authored fastpath scenarios0 and8 only. Point/fallback branches stay byte-identical.
for scenario in [0,8]:
 for offset in [2,3,6,10,11,14]:
  record=expected[scenario*16+offset];target=1 if scenario==0 else 2;row=next(r for r in record['world']['rows'] if r['id']==target);main=row['main'];head=main['coordinates'] if 'coordinates' in main else main['levels'];head['a']-=1
out=OUT;out.mkdir(exist_ok=False);e={'status':'INCOMPLETE','scope':'LIVE fused suppression; original CP.uncached returns affine Raw owner plus original fullview; preserve cached fullview, trueRawold0 inverse and eachMainmark','cpu':8,'limits':{'checker':5,'runtime':5,'codegen':30,'clang':120},'cases':[],'expectedChanges':'Only held fastpath Mainhead, scenarios0/8: pre and successful commit; original point/fallback/failure restored fields/effects unchanged','rawObserverPins':{},'records':144};observed=[]
try:
 for mode in ['cached','raw']:
  folder=out/mode;folder.mkdir();core=folder/'core';shutil.copytree(base/mode/'core',core);p=core/'held-adapter.bend';source=p.read_text();mutated,sites=FA.mutation(source,'suppressed-setter');assert len(sites)==2;p.write_text(mutated)
  assert sha(core/'uncached-payload.bend')=='03c861d32a6a4194a27e7d9acf89eac369f6dafef46fc56d423cc80985872db6'
  if mode=='raw':assert 'ORIGINAL.position_get' in (core/'cached-payload.bend').read_text(),'Independent protected original raw observer missing';e['rawObserverPins'][mode]={'CP':sha(core/'cached-payload.bend'),'protectedRaw':sha(core/'uncached-payload.bend'),'HA':sha(p),'callbacks':sha(core/'control-callbacks.bend')}
  for program in B.build(core/'cache-tx-controls.bend',folder):
   raw=B.execute(program);lines=[json.loads(l) for l in raw.splitlines()];assert lines==expected,'Suppression changed additional fields/journal/marks, failed trueold/no-op, or live site was not reached';assert lines!=baseline;observed.append(lines);backend='JS' if program.suffix=='.js' else 'Native';path=folder/(backend+'.jsonl');path.write_text(raw+'\n');e['cases'].append({'getter':mode,'backend':backend,'compiling':True,'exactNoopFullfieldsEffects':True,'records':144,'outputSHA256':sha(path),'programSHA256':sha(program),'trueOldJournalExample':lines[2]['undo'],'marksExample':lines[2]['marks']})
 assert all(x==observed[0] for x in observed);e['status']='PASS_LIVE_NOOP_TRUEOLD_JOURNAL_MARK_FULLFIELDS_BOTH'
except Exception as error:e['status']='FAIL';e['error']=repr(error);raise
finally:(out/'evidence.json').write_text(json.dumps(e,indent=2)+'\n')
