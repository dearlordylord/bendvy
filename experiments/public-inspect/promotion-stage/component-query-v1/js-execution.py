"""Execution-only delta: unconditional owned verification after each subject.
The separately admitted preparation helper/plan remain immutable.
"""
import hashlib,importlib.util,json,pathlib,sys
sys.dont_write_bytecode=True
HERE=pathlib.Path(__file__).resolve().parent
spec=importlib.util.spec_from_file_location('component_js_preparation',HERE/'js-backend.py');B=importlib.util.module_from_spec(spec);spec.loader.exec_module(B)
def freeze(path):
 p=json.loads(path.read_text());B.stage_guard(p)
 assert B.sha(path)==B.sha(path.parent/'plan.json')
 assert p['status']=='PREPARED_UNADMITTED_JS_EXECUTION' and p['prepareProbeCount']==5
 receipt=json.loads((path.parent/'prepare-receipt.json').read_text());assert receipt['status']=='COMPLETE_ORDINARY_OWNED_JS_PREPARATION' and receipt['probeCount']==5
 assert B.sha(path.parent/'prepare-receipt.json')==p['preparationReceiptSHA256']
 p['preparationProducedPlanSHA256']=B.sha(path);p['preparationProducedPlan']=str(path)
 p['executionHelper']=str(pathlib.Path(__file__).resolve());p['executionHelperSHA256']=B.sha(__file__)
 p['inputs'][str(pathlib.Path(__file__).resolve())]=B.sha(__file__);p['inputs'][str(path)]=B.sha(path)
 p['postChildPolicy']='Named unconditional owned tool verification after every child, including raw/generated registration failures; initial5 plus pre/post5 per two subjects gives25 success probes.'
 target=path.parent/'execution-plan.json';B.dump(target,p);print(target);print(B.sha(target))
def run(path):
 p=json.loads(path.read_text());out=path.parent;env=json.loads(pathlib.Path(p['privateEnvironment']).read_text());r={'status':'INCOMPLETE','planSHA256':B.sha(path),'scope':p['scope'],'commands':[]};raw={};generated={}
 def guard():
  assert B.sha(path)==r['planSHA256'],'execution plan byte drift'
  B.stage_guard(p)
  assert B.sha(p['toolSnapshot'])==p['toolSnapshotSHA256'] and B.sha(p['preparationPlan'])==p['preparationPlanSHA256'] and B.sha(out/'prepare-receipt.json')==p['preparationReceiptSHA256']
  assert B.sha(p['executionHelper'])==p['executionHelperSHA256'] and B.sha(p['preparationProducedPlan'])==p['preparationProducedPlanSHA256']
 def raw_guard():
  preserved=json.loads((out/'prepare-receipt.json').read_text())['logs']
  assert {q.name for q in out.glob('*.raw')}==set(raw)|set(preserved),'raw membership drift'
  assert {n:B.sha(out/n) for n in raw}==raw and r.get('logs',{})==raw,'captured raw/receipt hash drift'
 def generated_guard():
  assert {str(q) for q in out.glob('*.js')}==set(generated),'generated membership drift'
  assert {n:B.sha(n) for n in generated}==generated and r.get('generated',{})==generated,'generated/receipt hash drift'
 ledger=B.Ledger(out/'execution-probes',p['executionProbeLabels'],env,[('complete frozen sources/tools/config/environment/stage',guard)])
 checks=[('complete frozen source/tool/environment/config/stage',guard),('captured full raw membership/hash',raw_guard),('generated object membership/hash',generated_guard),('complete execution probe ledger',ledger.guard)]
 snapshot=B.decode(json.loads(pathlib.Path(p['toolSnapshot']).read_text()))
 def verify():
  # Raw/generated errors must not short-circuit the owned postchild verification.
  # All named guards still run at this boundary and preserve the primary error.
  with B.E.GuardBoundary(checks):
   guard();ledger.guard()
   try:B.TOOLS.shared.verify(snapshot,**{**p['frozenToolConfiguration'],'env':env,'execute':ledger.execute,'cpu':5})
   finally:r.update(probeCount=ledger.index,probePins=dict(ledger.pins))
 child_checks=[*checks,('unconditional owned tool verification after child',verify)]
 with B.E.ReceiptBoundary(r,out/'receipt.json',checks):
  guard();raw_guard();generated_guard();ledger.guard();verify()
  for command in p['commands']:
   verify()
   with B.E.GuardBoundary(child_checks):
    result=B.T.execute_result(command['argv'],command['seconds'],env,str(B.ROOT),'split')
    label=command['label'];raw.update({label+'.'+k+'.raw':hashlib.sha256(result[k]).hexdigest() for k in ['stdout','stderr']});r['logs']=dict(raw)
    for k in ['stdout','stderr']:(out/(label+'.'+k+'.raw')).write_bytes(result[k])
    r['commands'].append({'label':label,'exit':result['exit'],'failure':result['failure'],'seconds':command['seconds']})
    # Missing/unreadable output and raw-write exceptions remain inside the
    # unconditional postchild boundary. A failed emitter's partial bytes stay bound.
    if 'generated' in command and pathlib.Path(command['generated']).exists():generated[command['generated']]=B.sha(command['generated']);r['generated']=dict(generated)
    if result['failure'] is None and result['exit']==0 and 'generated' in command:assert command['generated'] in generated,'successful emission missing output'
   assert result['failure'] is None and result['exit']==0,'backend failed/deadline'
   if 'oracle' in command:
    assert result['stderr']==b'','Node emitted unexpected stderr'
    expected=pathlib.Path(command['oracle']).read_bytes();assert result['stdout']==expected,'complete independent public/physical oracle mismatch'
    r['oracle']={'actualSHA256':hashlib.sha256(result['stdout']).hexdigest(),'expectedSHA256':p['oracleSHA256'],'bytes':len(expected),'exactIOPrintLF':True}
   else:assert result['stdout']==b'' and result['stderr'] in [b'',b'bend 2.0.36 is available: run bend update\n'],'unexpected emitter framing'
  assert ledger.index==25
  r['status']='COMPLETE_WHOLE_COMPONENT_STANDALONE_JS_PASS'
 print(json.dumps(r))
if __name__=='__main__':
 if sys.argv[1]=='freeze':freeze(pathlib.Path(sys.argv[2]).resolve())
 else:run(pathlib.Path(sys.argv[2]).resolve())
