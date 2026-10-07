#!/usr/bin/env python3
"""Actual full-application diagnostic counters; do not interpret elapsed time."""
import sys,pathlib,argparse,json,importlib.util
HERE=pathlib.Path(__file__).resolve().parent;PROMO=HERE.parent;APP=PROMO.parent
spec=importlib.util.spec_from_file_location('promotion_stage',PROMO/'stage.py');promotion=importlib.util.module_from_spec(spec);spec.loader.exec_module(promotion)
sys.path.insert(0,str(APP/'timing'));import run as timing
timing.stage.sources=promotion.sources
p=argparse.ArgumentParser();p.add_argument('--output',type=pathlib.Path,required=True);a=p.parse_args();a.output=a.output.resolve();a.stage=timing.ROOT/'.artifacts/world-equality-full-stage-v2';a.cpu=11;a.timing=False
h=timing.Harness(a)
try:
 h.refs();semantic=timing.ROOT/'.artifacts/world-equality-timing-semantics-v2';receipt=json.loads((semantic/'receipt.json').read_text());assert receipt['status']=='PASS_COMPLETE_APPLICATION_EQUIVALENCE'
 h.receipt['fixedInputs'][str(semantic/'receipt.json')]=timing.digest(semantic/'receipt.json')
 h.receipt['fixedInputs'][str(pathlib.Path(__file__).resolve())]=timing.digest(pathlib.Path(__file__).resolve())
 h.receipt['sourceScope']='Instrumented unchanged full62-row actual application scales1/4; counts only, no timing ratios or authority modifications'
 h.save();counts=[]
 for n in [1,4]:
  original=semantic/f'state-{n}.js';assert timing.digest(original)==receipt['artifactHashes'][original.name]
  h.receipt['fixedInputs'][str(original)]=timing.digest(original)
  source=original.read_text()
  meta='function $$$$047$$$047$$$047src$047ecs$047world$058registration_meta_matches$(_meta_0, _id_0, _name_0, _access_0) {'
  eq='function $$$$047$$$047$$$047src$047ecs$047string$045equality$058equal$(_a_0, _b_0) {'
  listline='    const _x_1 = ($$$$047$$$047$$$047src$047ecs$047world$058registration_list_matches$(_rest_0, _id_0, _name_0, _access_0));'
  ret='  return $Bool$and$((_mid_0 === _id_0), ($Bool$and$(($$$$047$$$047$$$047src$047ecs$047string$045equality$058equal$(_mname_0, _name_0)), ($$$$047$$$047$$$047src$047ecs$047world$058access_equal$(_maccess_0, _access_0)))));'
  assert all(source.count(anchor)==1 for anchor in [meta,eq,listline,ret])
  source='const regCount={meta:0,idMismatch:0,nameOnIdMismatch:0,accessStringOnIdMismatch:0,matchedWithNonemptyRest:0};let regContext=null;\n'+source
  source=source.replace(meta,meta+'\n  regCount.meta++;const priorContext=regContext;regContext={mismatch:_meta_0.id!==_id_0,nameSeen:false};if(regContext.mismatch)regCount.idMismatch++;')
  source=source.replace(eq,eq+'\n  if(regContext){if(regContext.mismatch){if(regContext.nameSeen)regCount.accessStringOnIdMismatch++;else regCount.nameOnIdMismatch++;}regContext.nameSeen=true;}')
  source=source.replace(ret,ret.replace('return ','const observed = ',1)+'\n  regContext=priorContext;return observed;')
  source=source.replace(listline,'    if(_x_0 && _rest_0.$!=="Nil")regCount.matchedWithNonemptyRest++;\n'+listline)
  source=source.replace('let regContext=null;\n','let regContext=null;\nprocess.on("exit",()=>process.stderr.write("REG_COUNTER "+JSON.stringify(regCount)+"\\n"));\n',1)
  path=a.output/f'count-{n}.js';path.write_text(source);h.pin(path)
  result=h.run(f'full-{n}-JS-counters',['node',path],5)
  expected=(h.tree/'experiments/public-component-state/application-expected.txt').read_bytes()*n;assert result.stdout==expected
  lines=result.stderr.decode().splitlines();assert len(lines)==2 and lines[1].startswith('REG_COUNTER ')
  capture=json.loads(lines[0]);assert capture['bytes']==len(expected) and capture['digest']==timing.fnv(expected)
  count=json.loads(lines[1][12:]);assert count['meta']>0 and count['idMismatch']>0 and count['nameOnIdMismatch']==count['idMismatch'] and count['accessStringOnIdMismatch']>0 and count['matchedWithNonemptyRest']>0
  counts.append({'lifecycles':n,'fullRows':62*n,**count})
 h.receipt['counts']=counts;h.receipt['status']='PASS_COMPLETE_OUTPUT_COUNTS_CONFIRM_EAGER_WASTED_VALIDATION';h.guard();h.save();print(json.dumps(counts,indent=2))
except Exception as e:
 h.receipt['status']='FAILED';h.receipt['failure']=repr(e);h.save();raise
