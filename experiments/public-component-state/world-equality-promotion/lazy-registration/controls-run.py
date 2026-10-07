#!/usr/bin/env python3
"""Source-bound actual original/candidate144 comparisons and compiling defects."""
import sys,pathlib,argparse,json,importlib.util,re
HERE=pathlib.Path(__file__).resolve().parent;PROMO=HERE.parent;APP=PROMO.parent
spec=importlib.util.spec_from_file_location('promotion_stage',PROMO/'stage.py');promotion=importlib.util.module_from_spec(spec);spec.loader.exec_module(promotion)
sys.path.insert(0,str(APP/'timing'));import run as timing
timing.stage.sources=promotion.sources
p=argparse.ArgumentParser();p.add_argument('--output',type=pathlib.Path,required=True);p.add_argument('--preflight',action='store_true');a=p.parse_args();a.output=a.output.resolve();a.stage=timing.ROOT/'.artifacts/world-equality-full-stage-v2';a.cpu=5;a.timing=False
h=timing.Harness(a)
try:
 h.refs()
 for file in HERE.iterdir():
  if file.is_file():h.receipt['fixedInputs'][str(file)]=timing.digest(file)
 h.receipt['sourceScope']='Isolated81 actual original/candidate metadata +63 list predicates, duplicatedIDs/nonmatching earlier records; no fullapplication/performance credit';h.save()
 original=(HERE/'candidate.bend').read_text();expected=(HERE/'expected.txt').read_bytes()
 plans=[{'tag':'normal','anchor':None,'replacement':None,'row':None,'pair':None,'witness':'Complete144 actual original/candidate outputs'},
 {'tag':'ignore-id','anchor':'case False{}: False{}\n    case True{}: matching_access','replacement':'case False{}: matching_access(SE.equal(metaName,wantedName),metaAccess,wantedAccess)\n    case True{}: matching_access','row':14,'pair':'true:false','witness':'meta7 runner [read-phase] vs requested8 runner [read-phase]'},
 {'tag':'ignore-name','anchor':'case False{}: False{}\n    case True{}: access_equal','replacement':'case False{}: True{}\n    case True{}: access_equal','row':12,'pair':'true:false','witness':'meta7 runner [read-phase] vs requested7 runner2 [read-phase]'},
 {'tag':'skip-rest','anchor':'registration_list_walk(rest,id,name,access,registration_meta_matches(meta,id,name,access))','replacement':'registration_meta_matches(meta,id,name,access)','row':91,'pair':'false:true','witness':'list[meta0 empty,meta7 runner read-phase] requested7 runner read-phase; matching later entry must survive'}]
 h.receipt['variantPlans']=[]
 # Materialize and bind every complete candidate/control pair BEFORE any checker/backend.
 for plan in plans:
  tag=plan['tag'];text=original
  if plan['anchor']:
   assert text.count(plan['anchor'])==1,(tag,'single-anchor count')
   text=text.replace(plan['anchor'],plan['replacement'],1);assert text!=original
  folder=a.output/tag;folder.mkdir()
  text=text.replace('../../string-equality/equality.bend',str(APP/'string-equality/equality.bend'))
  control=(HERE/'controls.bend').read_text().replace('../../../../src/ecs/world.bend',str(timing.ROOT/'src/ecs/world.bend'))
  for filename,body in [('candidate.bend',text),('controls.bend',control)]:
   path=folder/filename;path.write_text(body);h.pin(path)
  h.receipt['variantPlans'].append({**plan,'replacementCount':1 if plan['anchor'] else 0,'sourceInventory':promotion.inventory(folder)})
 h.guard();h.save()
 for plan in plans:
  tag=plan['tag'];row=plan['row'];folder=a.output/tag
  checked=h.run(tag+'-checker',['bend',folder/'controls.bend','--check-only'],5);assert b'ALL PROOFS CHECK' in checked.stdout+checked.stderr
  if a.preflight:continue
  for suffix in ['js','c']:
   path=folder/('controls.'+suffix);h.run(tag+'-emit-'+suffix,['bend',folder/'controls.bend','-o',path],30);h.pin(path)
  native=folder/'controls.native';h.run(tag+'-build',['/tmp/bendvy-clang19-diagnostic/clang19','-O3',folder/'controls.c','-o',native,'-pthread','-lm'],120);h.pin(native)
  for backend,cmd in [('JS',['node',folder/'controls.js']),('Native',[native,'--threads','1','--gpu','off'])]:
   out=h.run(tag+'-'+backend,cmd,5).stdout
   if tag=='normal':assert out==expected
   else:
    assert len(out.splitlines())==144 and out!=expected
    wanted=plan['pair'].encode();assert out.splitlines()[row]==wanted,(tag,row,out.splitlines()[row])
 h.receipt['status']='PASS_LAZY_REGISTRATION_PREFLIGHT_NO_NATIVE' if a.preflight else 'PASS_FINITE_LAZY_REGISTRATION_AND_REACHED_MUTANTS_BOTH_BACKENDS';h.guard();h.save();print(a.output)
except Exception as e:
 h.receipt['status']='FAILED';h.receipt['failure']=repr(e);h.save();raise
