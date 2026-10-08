"""Freeze copied compiling controls before runtime; no implicit execution."""
from pathlib import Path
import argparse,contextlib,io,json,shutil,types
HERE=Path(__file__).resolve().parent
S=types.ModuleType('static_mutants');S.__file__=str(HERE/'binding-static-driver-check.py')
exec((HERE/'binding-static-driver-check.py').read_text().rsplit('p=argparse.ArgumentParser();',1)[0],S.__dict__)
B=S.B
PROPOSAL=HERE/'BINDING-STATIC-BACKEND-MUTANT-PROPOSAL.json'
def prepare(native):
 js=B.ROOT/'.artifacts/inspect54-static-backend-1791421630978868568/receipt.json';jp=js.parent/'plan.json';jr=json.loads(js.read_text());assert jr['planSHA256']==B.sha(jp) and jr['status']=='FULL8_STATIC_DESCRIPTOR_EMITTED_PASS';assert all(c['exit']==0 and c['failure'] is None for c in jr['commands'])
 for name,digest in jr['logs'].items():assert B.sha(Path(jr['logDirectory'])/name)==digest
 model=json.loads(PROPOSAL.read_text());capture=io.StringIO()
 with contextlib.redirect_stdout(capture):S.prepare(native)
 path=Path(capture.getvalue().splitlines()[0]);p=json.loads(path.read_text());out=path.parent;files=set(map(Path,p['files']));files.update([PROPOSAL,Path(__file__).resolve(),js,jp,*[Path(jr['logDirectory'])/name for name in jr['logs']]]);commands=[];stages=[];mutations=[];sources=set();B.closure(HERE/'binding-static-driver-main.bend',sources);sources.add(HERE/'binding-static-driver-io.bend')
 jsmeta=json.loads(jp.read_text());jsInventory=Path(jsmeta['sourceInventory']);qualified={r['path']:r for r in json.loads(jsInventory.read_text())['files']};files.add(jsInventory);files.update(sources)
 for source in sources:
  record=qualified[str(source.relative_to(B.ROOT))];assert B.sha(source)==record['sourceSHA256']==record['stageSHA256'];assert record['origin'] in ['tracked','selected-owned']
  prior=Path(jsmeta['stage'])/source.relative_to(B.ROOT);assert B.sha(prior)==record['stageSHA256'];files.add(prior)
 for mutant in model['mutants']:
  stage=out/mutant['name'];stage.mkdir();stages.append(stage);records=[]
  for source in sorted(sources):
   relative=source.relative_to(B.ROOT);target=stage/relative;target.parent.mkdir(parents=True,exist_ok=True);data=source.read_bytes();target.write_bytes(data);records.append({'path':str(relative),'originalSHA256':B.sha(source),'stageSHA256':B.sha(target)})
  for name,digest in mutant['patchFiles'].items():
   source=HERE/name;assert B.sha(source)==digest;target=stage/source.relative_to(B.ROOT);text=target.read_text();assert text.count(mutant['replace']['old'])==1;target.write_text(text.replace(mutant['replace']['old'],mutant['replace']['new']));next(r for r in records if r['path']==str(source.relative_to(B.ROOT)))['stageSHA256']=B.sha(target)
  inventory=out/(mutant['name']+'-inventory.json');inventory.write_text(json.dumps(records,indent=2)+'\n');files.add(inventory);entry=stage/HERE.relative_to(B.ROOT)/'binding-static-driver-main.bend';commands.append({'label':mutant['name']+'-pure-source','argv':['/usr/bin/taskset','-c','5','/home/node/.bend/bin/bend',str(entry),'--check-only'],'seconds':5});mutations.append({'name':mutant['name'],'stage':str(stage),'inventory':str(inventory),'inventorySHA256':B.sha(inventory),'oracleIOString':mutant['independentFullIOString'],'differentSemanticRows':mutant['expectedDifferentSemanticRows']})
 p.update(status='PREPARED_UNADMITTED_STATIC_MUTANT_SOURCE_ONLY',kind='metadata',commands=commands,mutations=mutations,baselineJS={'receipt':str(js),'receiptSHA256':B.sha(js),'planSHA256':B.sha(jp)},scope='Two copied closed-descriptor pure source checks only: compile feasibility for actual grant routing and metadata order defects. Complete independent full8 defect oracles frozen, no runtime/reachedkill/proof/full54. Original full owners preserved; no manualFrame/runtimePlan/capture.')
 p['files']=sorted(map(str,files));p['directories']=[*p['directories'],*map(str,stages)];p['inputs']=B.task_runner.Inputs(files=files,directories=map(Path,p['directories'])).expected;path.write_text(json.dumps(p,indent=2)+'\n');print(path);print(B.sha(path))
p=argparse.ArgumentParser();p.add_argument('--prepare',action='store_true');p.add_argument('--native');p.add_argument('--run');a=p.parse_args()
if a.prepare:prepare(a.native)
else:B.run(a.run)
