"""Reached full-query JS mutations; separate frozen admission required."""
import pathlib,importlib.util,json,hashlib,sys
sys.dont_write_bytecode=True
HERE=pathlib.Path(__file__).resolve().parent
s=importlib.util.spec_from_file_location('native_reuse',HERE/'native-schema-corrected.py');N=importlib.util.module_from_spec(s);s.loader.exec_module(N)
B=N.B
def mutation_guard(p):
 q=p['mutationQualification'];source=pathlib.Path(q['plan']);r=json.loads(pathlib.Path(q['receipt']).read_text());sp=json.loads(source.read_text())
 assert B.sha(source)==q['planSHA256'] and B.sha(q['receipt'])==q['receiptSHA256']
 assert r['planSHA256']==q['planSHA256'] and r['status']=='SOURCE_MUTANT_FEASIBILITY_PASS' and r['exit']==0 and r['failure'] is None and r.get('guardFailures',[])==[]
 for n,d in r['logs'].items():assert B.sha(source.parent/n)==d
 for n,d in sp['sourceArchive'].items():assert B.sha(source.parent/'source'/n)==d
 for n,d in q['pins'].items():assert B.sha(n)==d
 assert p['commands'][1]['oracle']==q['oracle'] and B.sha(q['oracle'])==q['oracleSHA256']
 assert pathlib.Path(q['oracle']).read_bytes()!=pathlib.Path(p['oracle']).read_bytes()
def run(path):
 p=json.loads(path.read_text());out=path.parent;env=json.loads(pathlib.Path(p['privateEnvironment']).read_text());r={'status':'INCOMPLETE','planSHA256':B.sha(path),'scope':p['scope'],'commands':[]};raw={};generated={}
 def guard():
  assert B.sha(path)==r['planSHA256'] and B.sha(__file__)==p['executionHelperSHA256']
  B.stage_guard(p);N.qualification_guard(p);N.schema_source_guard(p);N.native_config_guard(p);mutation_guard(p)
  assert B.sha(p['nativePreparationQualification'])==p['nativePreparationQualificationSHA256']
  qualifier=json.loads(pathlib.Path(p['nativePreparationQualification']).read_text())
  assert qualifier['status']=='COMPLETE_NATIVE_ORDINARY_PREPARATION_QUALIFICATION' and qualifier['preparationPlanSHA256']==p['preparationPlanSHA256'] and qualifier.get('guardFailures',[])==[]
  assert B.sha(p['toolSnapshot'])==p['toolSnapshotSHA256'] and B.sha(p['preparationPlan'])==p['preparationPlanSHA256'] and B.sha(out/'prepare-receipt.json')==p['preparationReceiptSHA256']
 def raw_guard():
  preserved=json.loads((out/'prepare-receipt.json').read_text())['logs']
  assert {q.name for q in out.glob('*.raw')}==set(raw)|set(preserved)
  assert {n:B.sha(out/n) for n in raw}==raw and r.get('logs',{})==raw
 def generated_guard():
  actual={str(q) for suffix in ['*.js'] for q in out.glob(suffix)}
  assert actual==set(generated) and {n:B.sha(n) for n in generated}==generated and r.get('generated',{})==generated
 ledger=B.Ledger(out/'execution-probes',p['executionProbeLabels'],env,[('complete frozen source/tool/config/environment/qualification',guard)])
 checks=[('complete plan/source/tool/env/config/qualification',guard),('exact captured raw membership/hash',raw_guard),('exact generated objects membership/hash',generated_guard),('exact resolver ledger membership/hash',ledger.guard)]
 snapshot=B.decode(json.loads(pathlib.Path(p['toolSnapshot']).read_text()))
 def verify():
  with B.E.GuardBoundary(checks):
   guard();ledger.guard()
   try:B.TOOLS.shared.verify(snapshot,**{**p['frozenToolConfiguration'],'env':env,'execute':ledger.execute,'cpu':5})
   finally:r.update(probeCount=ledger.index,probePins=dict(ledger.pins))
 with B.E.ReceiptBoundary(r,out/'receipt.json',checks):
  guard();raw_guard();generated_guard();ledger.guard();verify()
  for command in p['commands']:
   if command['label'].endswith('-emit-js'):
    target=pathlib.Path(command['argv'][4]);assert target.is_file() and B.sha(target)==p['stageInventory'][str(target.relative_to(p['stage']))]
   verify()
   with B.E.GuardBoundary([*checks,('unconditional owned verification after subject',verify)]):
    result=B.T.execute_result(command['argv'],command['seconds'],env,str(B.ROOT),'split');label=command['label']
    raw.update({label+'.'+k+'.raw':hashlib.sha256(result[k]).hexdigest() for k in ['stdout','stderr']});r['logs']=dict(raw)
    for k in ['stdout','stderr']:(out/(label+'.'+k+'.raw')).write_bytes(result[k])
    r['commands'].append({'label':label,'exit':result['exit'],'failure':result['failure'],'seconds':command['seconds']})
    if 'generated' in command and pathlib.Path(command['generated']).exists():generated[command['generated']]=B.sha(command['generated']);r['generated']=dict(generated)
    if result['failure'] is None and result['exit']==0 and 'generated' in command:assert command['generated'] in generated,'successful child missing generated artifact'
   assert result['failure'] is None and result['exit']==0,'JS mutant failure/deadline'
   if 'oracle' in command:
    assert result['stderr']==b'' and result['stdout']==pathlib.Path(command['oracle']).read_bytes(),'whole independent mutant oracle mismatch'
    r.setdefault('schemaOracles',{})[command['label']]={'actualSHA256':hashlib.sha256(result['stdout']).hexdigest(),'expectedSHA256':B.sha(command['oracle']),'bytes':len(result['stdout']),'exactIOPrintLF':True}
   else:assert result['stdout']==b'' and result['stderr'] in ([b'',b'bend 2.0.36 is available: run bend update\n'] if label.endswith('-emit-js') else [b'']),'unexpected Native child framing'
  assert ledger.index==25;r['status']='COMPLETE_REACHED_FULL_COMPONENT_JS_MUTANT'
 print(json.dumps(r))
if __name__=='__main__':run(pathlib.Path(sys.argv[1]).resolve())
