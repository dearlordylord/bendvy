#!/usr/bin/env python3
"""Two-command development seam, not delivery/tool/performance qualification."""
import argparse,gzip,hashlib,json,os,pathlib,traceback,sys
HERE=pathlib.Path(__file__).resolve().parent;sys.path.insert(0,str(HERE.parent));import importlib.util
def load(n,p):
 s=importlib.util.spec_from_file_location(n,p);m=importlib.util.module_from_spec(s);s.loader.exec_module(m);return m
ROOT=HERE.parents[3];gate=load('cheap_gate',HERE.parent/'run-semantic.py');runner=load('cheap_runner',ROOT/'scripts/task_runner.py');model=load('cheap_model',HERE.parent/'overflow-model.py');sha=gate.sha;tree=gate.tree
STAGE=ROOT/'.artifacts/machines-stream-opt-integration-development-v3/stage'
def main():
 ap=argparse.ArgumentParser();ap.add_argument('--output',type=pathlib.Path,required=True);ap.add_argument('--freeze-only',action='store_true');a=ap.parse_args();out=a.output.resolve()
 env=dict(os.environ,BEND_NO_TELEMETRY='1');bend='/home/node/.bend/bin/bend';node='/home/node/.local/share/mise/installs/node/24.20.0/bin/node';taskset='/usr/bin/taskset'
 def sources():
  paths=[p for p in STAGE.rglob('*') if p.is_file()]+[p for p in HERE.iterdir() if p.is_file()]+[ROOT/'scripts/task_runner.py',HERE.parent/'run-semantic.py',HERE.parent/'overflow-model.py',HERE.parent.parent/'full-model.py',HERE.parent/'evidence/primary-ts-v1/expected.json.gz',pathlib.Path(bend),pathlib.Path(node),pathlib.Path(taskset)]
  return {str(p):sha(p) for p in sorted(set(paths))}
 if a.freeze_only:
  assert not out.exists();out.mkdir();pins=sources();expected=json.dumps(model.expected(),sort_keys=True).encode();config=gate.configurations([out,STAGE]);commands=[{'label':'emit-js','argv':[taskset,'-c','7',bend,str(STAGE/'experiments/public-machines/followup/overflow.bend'),'-o',str(out/'application.js')],'cap':30,'new':'application.js'},{'label':'run-js','argv':[taskset,'-c','7',node,str(out/'application.js'),'65537'],'cap':5,'new':None}]
  plan={'scope':'DEVELOPMENT_COMPLETE_MODEL_SEAM_ONLY_NOT_DELIVERY_OR_PERFORMANCE','sources':pins,'stageInventory':tree(STAGE),'configuration':config,'environmentSHA256':hashlib.sha256(json.dumps(env,sort_keys=True,separators=(',',':')).encode()).hexdigest(),'expectedSHA256':hashlib.sha256(expected).hexdigest(),'commands':commands,'allOutputsInitiallyAbsent':True,'installedResolverDiscoveryNotYetQualified':True}
  (out/'plan.json').write_text(json.dumps(plan,indent=2)+'\n');(out/'expected.json.gz').write_bytes(gzip.compress(expected));print(json.dumps({'status':'FROZEN_NOT_EXECUTED','planSHA256':sha(out/'plan.json')}));return
 plan=json.loads((out/'plan.json').read_text());planhash=sha(out/'plan.json');assert set(tree(out))=={'plan.json','expected.json.gz'};known=tree(out);records=[];receipt={'status':'INCOMPLETE_DEVELOPMENT','scope':plan['scope'],'planSHA256':planhash,'commands':records}
 def guard():
  assert sources()==plan['sources'];assert tree(STAGE)==plan['stageInventory'];assert gate.configurations([out,STAGE])==plan['configuration'];assert tree(out)==known
  assert hashlib.sha256(json.dumps(env,sort_keys=True,separators=(',',':')).encode()).hexdigest()==plan['environmentSHA256']
  assert hashlib.sha256(gzip.decompress((out/'expected.json.gz').read_bytes())).hexdigest()==plan['expectedSHA256']
 try:
  guard()
  for job in plan['commands']:
   guard();before=dict(known);label=job['label'];assert not any((out/(label+s)).exists() for s in ['.stdout.gz','.stderr']);assert job['new'] is None or not (out/job['new']).exists()
   result=runner.execute_result(job['argv'],job['cap'],env=env,cwd=str(ROOT),capture='split');stdout=result.pop('stdout');stderr=result.pop('stderr')
   with gzip.open(out/(label+'.stdout.gz'),'wb') as f:f.write(stdout)
   (out/(label+'.stderr')).write_bytes(stderr);records.append({'label':label,'argv':job['argv'],'cap':job['cap'],**result,'stdoutSHA256':hashlib.sha256(stdout).hexdigest(),'stderrSHA256':hashlib.sha256(stderr).hexdigest()})
   after=tree(out);allowed={label+'.stdout.gz',label+'.stderr'}|({job['new']} if job['new'] else set());assert set(after)-set(before)<=allowed;assert all(after.get(n)==h for n,h in before.items());known=after;guard()
   assert result['exit']==0 and result['failure'] is None
   if job['label']=='emit-js':assert (out/'application.js').is_file();receipt['generatedSHA256']=sha(out/'application.js')
   else:model.validate(stdout);receipt['completeRowsPerSchema']=7;receipt['requestedCount']=65537;receipt['capacity']=65536
  receipt['status']='DEVELOPMENT_FULL65537_TWO_SCHEMA_COMPLETE_MODEL_PASS'
 except BaseException as e:receipt['error']=repr(e);receipt['traceback']=traceback.format_exc()
 finally:receipt['artifacts']=tree(out);(out/'receipt.json').write_text(json.dumps(receipt,indent=2)+'\n')
 print(json.dumps({'status':receipt['status'],'receiptSHA256':sha(out/'receipt.json')}))
if __name__=='__main__':main()
