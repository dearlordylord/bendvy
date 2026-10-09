#!/usr/bin/env python3
"""Cheap transport/binding controls; synthetic DTOs are not a runtime oracle."""
import copy,hashlib,importlib.util,json,tempfile
from pathlib import Path
ROOT=Path(__file__).resolve().parents[4]
HOME=ROOT/'experiments/public-decode/adoption-v1/qualification-v1/spine-report-v1'
def load(name,path):
 spec=importlib.util.spec_from_file_location(name,path);module=importlib.util.module_from_spec(spec);spec.loader.exec_module(module);return module
transport=load('assembly_transport_controls',HOME/'transport.py')
runner=load('assembly_binding_controls',HOME/'development-run.py')
assert runner.assembly_binding(None,None) is None
assert runner.ORACLE_FILES['normal']['sha256']=='26e965901c73e89804b69c1d3d13d10e512478955cb0541f6ccbe8e49693766d'
assert runner.ORACLE_COMMIT=='220251bc'
old=Path('/workspace/formal-proofs/bendvy-worktrees/parity-58-snapshot-research/experiments/public-decode/adoption-v1/qualification-v1/oracle-v1/spine-report-v1/expected.json')
expected=json.loads(old.read_text());raw=transport.render(expected,HOME/'main.bend')
assert transport.parse(raw,HOME/'main.bend')==expected
old_whole=old.parent.parent/'normal-expected.json'
assert hashlib.sha256(old_whole.read_bytes()).hexdigest()=='ca88bdec56290ba3b5460463f59c4ddda389d2dcc7ecfa58d6d633c35016e075'
assert transport.whole(expected)==json.loads(old_whole.read_text())
entry=Path(__file__).resolve().parent/'spine.bend'
refused={'$':'RegistrationRefused'}
case_names=('array3','array128','array256','lateInvalid','struct64','nullableNull','nestedValid','nestedMissing')
cases={'$':'Cases',**{k:copy.deepcopy(refused) for k in case_names}}
instance={'$':'InstanceView','namespace':1,'id':1,'name':'decode-owned','access':['Declared'],'operation':{'$':'Resource'},'codec':{'$':'Nullable','inner':{'$':'Struct','fields':[{'$':'NamedCodec','name':'items','codec':{'$':'ArrayValue','inner':{'$':'Integer'}}}]}},'completion':{'$':'Failure','error':{'$':'Unit'}},'recovery':[{'$':'RecoveryView','output':{'$':'RefusedView','owner':{'$':'Some','value':{'$':'PayloadView','raw':{'$':'Boolean','value':False},'sentinel':[111,222]}},'error':{'$':'Validation','error':{'$':'Invalid','path':'$','expected':'integer','actual':{'$':'Boolean','value':False}}}},'packets':[{'$':'PacketView','owner':{'$':'None'},'original':{'$':'Number','value':7},'canonical':{'$':'Number','value':7}}]}]}
cases['array3']={'$':'RegisteredObserved','instance':instance,'result':{'$':'SetupRefused','error':{'$':'MissingEntity'}}}
ext_names=('plain','transient','resultRejectsDecodeAccepts','resultAccepts','decodeOverrides','decodeFallsBack','literalAccepts','literalRejects','handleAccepts','handleForeign','handleZero','handleWrongType')
decoded={'$':'Observation','originalRaw':{'$':'Boolean','value':False},'sentinel':[111,222],'checked':{'$':'Accepted','value':{'$':'Boolean','value':False}}}
extension={'$':'Extension',**{k:copy.deepcopy(decoded if k in ('decodeOverrides','decodeFallsBack') else refused) for k in ext_names}}
value={'$':'Candidate',**{k:{'$':'Some','value':copy.deepcopy(cases)} for k in ('insert','spawn','resource','otherSchema')},'foreign':{'$':'ForeignSetupRefused'},'extension':{'$':'Some','value':extension}}
assert transport.parse(transport.render(value,entry,True),entry,True)==value
bad=copy.deepcopy(value);del bad['insert']['value']['array3']['instance']['recovery']
try:transport.render(bad,entry,True)
except AssertionError:pass
else:raise AssertionError('missing recovery field accepted')
# Independent full models authored before runtime, now integrated on master.
model_home=Path('/workspace/formal-proofs/bendvy/experiments/public-decode/public-seam-v1/oracle-v1/full-assembly-v1')
correct=json.loads((model_home/'expected.json').read_text())
failure=json.loads((model_home/'failure-expected.json').read_text())
assert transport.parse(transport.render(correct,entry,True),entry,True)==correct
failure_entry=entry.parent/'failure-controls.bend'
assert transport.parse(transport.render(failure,failure_entry,True,'local-failure'),failure_entry,True,'local-failure')==failure
assert transport.whole(failure,'local-failure')==failure
for role in ('skip-validation','partial-write'):
 assert not runner.mutant_witness(role,correct,correct)
 mutant=copy.deepcopy(correct)
 actual=mutant['insert']['value']['lateInvalid']['result']['trace']
 if role=='skip-validation':actual['outcome']={'$':'Replaced'}
 else:actual['after']['resource']['value']['raw']={'$':'Text','value':'partial-before-validation'}
 assert runner.mutant_witness(role,mutant,correct)
 unrelated=copy.deepcopy(correct);unrelated['insert']['value']['array3']['instance']['name']='unrelated mismatch'
 assert not runner.mutant_witness(role,unrelated,correct)
with tempfile.TemporaryDirectory() as directory:
 home=Path(directory).resolve()
 def pin(name,body):
  path=home/name;path.write_text(body);return {'path':str(path),'sha256':hashlib.sha256(path.read_bytes()).hexdigest()}
 source=pin('spine.bend','import Base\n');oracle={'commit':'1'*40,'expected':pin('expected.json','{}'),'whole':pin('whole.json','{}'),'basis':pin('basis.json','{"sources":{}}'),'authoring':[pin('REVIEW.md','synthetic binding control')]}
 binding={'mode':'registered-decode-assembly-v1','entry':source,'sourcePins':{source['path']:source['sha256']},'oracle':oracle}
 path=home/'binding.json';path.write_text(json.dumps(binding));digest=hashlib.sha256(path.read_bytes()).hexdigest()
 assert runner.assembly_binding(path,digest)==binding
 runner.assert_source_pins(binding,{Path(source["path"])})
 try:runner.assert_source_pins(binding,set())
 except AssertionError:pass
 else:raise AssertionError("missing source closure accepted")
 for action in ('binding','source','oracle'):
  target=path if action=='binding' else Path(source['path'] if action=='source' else oracle['whole']['path']);previous=target.read_bytes();target.write_bytes(previous+b' ')
  try:runner.assembly_binding(path,digest)
  except AssertionError:pass
  else:raise AssertionError(action+' drift accepted')
  target.write_bytes(previous)
print(json.dumps({'status':'PASS','oldDefaultRoundtrip':True,'assemblyCompleteSyntheticRoundtrip':True,'missingRecoveryRejected':True,'bindingSourceOracleDriftRejected':True,'independentFullCandidateAndFailureRoundtrip':True,'targetedMutantWitnessControls':True,'backendChildren':0}))
