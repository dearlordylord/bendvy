#!/usr/bin/env python3
"""Selected-owner column specialization finite construction, not a benchmark."""
import argparse,hashlib,importlib.util,json,os,shutil
from pathlib import Path
H=Path(__file__).resolve().parent;project=Path('/workspace/formal-proofs/bendvy');ROOT=project;sha=lambda p:hashlib.sha256(p.read_bytes()).hexdigest()
p=argparse.ArgumentParser();p.add_argument('--prepared',type=Path,required=True);p.add_argument('--base-overlay',type=Path,required=True);p.add_argument('--output',type=Path,required=True);p.add_argument('--previous-evidence',type=Path);a=p.parse_args();os.sched_setaffinity(0,{11});a.output.mkdir(exist_ok=False)
import preflight
preflight_result={'controlSources':preflight.control_sources(),'evaluatorRoot':preflight.evaluator_root(ROOT),'base':preflight.base(a.base_overlay),'derived':preflight.prepared(a.prepared)}
sp=importlib.util.spec_from_file_location('M',ROOT/'experiments/s-perf/measure-run.py');M=importlib.util.module_from_spec(sp);sp.loader.exec_module(M)
cp=project/'experiments/s-prep/owned-write-query-integration/controls-run.py';sp=importlib.util.spec_from_file_location('C',cp);C=importlib.util.module_from_spec(sp);sp.loader.exec_module(C)
r={'scope':'Finite source-distinct Native/JS selected-owner construction and boundary controls; no clock metric selected','limitsSeconds':{'checker':5,'runtime':5,'codegen':30,'clang':120},'preparedReceiptSHA256':sha(a.prepared/'receipt.json'),'preflight':preflight_result,'cases':[],'controls':[],'mutants':[],'compiler':M.D.B.command(['bend','version']).strip()}
def build(source,folder,backend):
 folder.mkdir(exist_ok=False);check=M.D.B.command([M.D.B.CHECK,source,'--check-only']);assert 'ALL PROOFS CHECK' in check
 out=folder/('program.c' if backend=='native' else 'program.js');M.D.B.command(['bend',source,'-o',out],timeout=30)
 if backend=='native':
  program=folder/'program-native';M.D.B.command(['clang','-std=c11','-O3',out,'-lpthread','-lm','-o',program],timeout=120)
 else:program=out
 return program
try:
 if a.previous_evidence:
  original=json.load(open(a.previous_evidence));assert len(original['cases'])==4 and len(original['controls'])==2
  assert original['preparedReceiptSHA256']==r['preparedReceiptSHA256']
  r=original;r['preflight']=preflight_result;r.pop('error',None);r['status']='INCOMPLETE';r['previousEvidencePath']=str(a.previous_evidence);r['previousEvidenceSHA256']=sha(a.previous_evidence)
  r['previousSurvivingControl']='Capacity doubling with unchanged initial branch threshold survives depth-one controls; no kill claimed'
 else:
  refs={}
  for schema in ['Motion','Health']:
   text=M.D.B.command(['node',ROOT/'experiments/s-integrate/measurement-reference.mjs',schema,'dense','64']);refs[schema]=json.loads(text);(a.output/(schema+'-reference.json')).write_text(text)
  controloutputs=[]
  for backend in ['native','javascript']:
   overlay=a.prepared/backend;manifest=json.load(open(overlay/'overlay.json'));assert all(sha(overlay/n)==h for n,h in manifest['sources'].items())
   program=build(overlay/'experiments/s-integrate/measurement-samples-bend.bend',a.output/backend,backend)
   for sn,schema in enumerate(['Motion','Health']):
    text=M.D.B.execute(program,[str(sn),'0','64','1']);(a.output/(backend+'-'+schema+'.txt')).write_text(text+'\n');checked=M.D.checked('Native' if backend=='native' else 'JS',text,schema,False,64,1,refs[schema]);r['cases'].append({'backend':backend,'schema':schema,'status':'FULL_FIELD_PASS','artifactSHA256':sha(program),'outputSHA256':hashlib.sha256(text.encode()).hexdigest(),'fields':{k:v for k,v in checked.items() if 'milliseconds' not in k.lower()}})
   core=a.output/(backend+'-controls')/'core';shutil.copytree(overlay/'experiments/s-integrate',core);source=core/'controls.bend';preflight.control_sources();source.write_bytes((cp.parent/'controls.bend').read_bytes());bin=build(source,a.output/(backend+'-control-build'),backend);text=M.D.B.execute(bin);(a.output/(backend+'-controls.jsonl')).write_text(text+'\n');lines=[json.loads(x) for x in text.splitlines()];assert len(lines)==144 and not C.differences(lines);C.independent(lines);controloutputs.append(lines);r['controls'].append({'backend':backend,'status':'144_FULL_RECORD_BOUNDARY_CONTROLS_PASS','artifactSHA256':sha(bin),'controlSourceSHA256':sha(source),'outputSHA256':hashlib.sha256(text.encode()).hexdigest()})
   assert all(sha(overlay/n)==h for n,h in manifest['sources'].items())
  assert controloutputs[0]==controloutputs[1]
 # Cached capacity mutation is Native-only. Preserve current source/manifest.
 mutant=a.output/'wrong-capacity-core';shutil.copytree(a.prepared/'native/experiments/s-integrate',mutant);source=mutant/'controls.bend';preflight.control_sources();source.write_bytes((cp.parent/'controls.bend').read_bytes());file=mutant/'native-columns.bend';text=file.read_text();old='swap_go(P,array,capacity,index,value,U32.is_lt(index,U32.shr(capacity)))';assert text.count(old)==1;file.write_text(text.replace(old,'swap_go(P,array,U32.add(capacity,capacity),index,value,U32.is_lt(index,capacity))'))
 bin=build(source,a.output/'wrong-capacity-build','native');text=M.D.B.execute(bin);(a.output/'wrong-capacity-controls.jsonl').write_text(text+'\n');lines=[json.loads(x) for x in text.splitlines()];diff=C.differences(lines);assert diff;r['mutants'].append({'name':'wrong-capacity','applicableBackend':'native','status':'COMPILING_FULL_RECORD_MUTANT_DETECTED','sourceSHA256':sha(file),'artifactSHA256':sha(bin),'firstDifference':diff[0],'javascript':'INAPPLICABLE: actual intrinsic column path has no cached-capacity descent'})
 r['status']='FINITE_NATIVE_CAPACITY_INTEGRATION_PASS'
except Exception as e:r.update(status='FAIL',error=repr(e))
r['finalControlSources']=preflight.control_sources();r['runnerSHA256']=sha(Path(__file__));r['controlValidatorSHA256']=sha(cp);(a.output/'evidence.json').write_text(json.dumps(r,indent=2)+'\n');print(r['status']);raise SystemExit(r['status']=='FAIL')
