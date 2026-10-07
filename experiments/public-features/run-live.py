"""Bounded source-current feature checks. No production/law/performance approval."""
from pathlib import Path
import argparse,importlib.util,json,time,hashlib
HERE=Path(__file__).resolve().parent
spec=importlib.util.spec_from_file_location('guarded',HERE/'guarded-logs.py');module=importlib.util.module_from_spec(spec);spec.loader.exec_module(module)
p=argparse.ArgumentParser();p.add_argument('--output',type=Path,default=module.ROOT/'.artifacts'/('features40-'+str(time.time_ns())));p.add_argument('--preflight-only',action='store_true');p.add_argument('--plan-only',action='store_true');args=p.parse_args()
diag=json.loads((HERE/'diagnostics.json').read_text());expected=json.loads((HERE/'expected.json').read_text())
original_undeclared=diag['undeclared'][0];assert original_undeclared.count('feature.Pack')==3
diag['undeclared'][0]=original_undeclared.replace('feature.Pack','../../src/ecs/feature.Pack')
fixtures=[HERE/n for n in ['runtime-main.bend','recipe-main.bend','scope-main.bend','falsify.bend','LAWS.bend']]+[HERE/('negative-'+n+'.bend') for n in diag]
ts=module.ROOT/'.references/bevy-ts';extra=[Path(__file__),HERE/'promotion/manifest.json',HERE/'promotion/feature.bend',HERE/'promotion/feature-provision.bend',HERE/'guarded-logs.py',HERE/'diagnostics.json',HERE/'expected.json',HERE/'reference.mjs',HERE/'dependency-reference.mjs',ts/'package.json',ts/'packages/core/package.json']+list((ts/'packages/core/src').rglob('*.ts'))
fixtures.extend([module.ROOT/'src/ecs/feature.bend',module.ROOT/'src/ecs/feature-provision.bend'])
h=module.Harness(args.output,fixtures,extra)
h.r['diagnostic_import_rebase']={'subject':'undeclared expected type only','original':original_undeclared,'expected_after':diag['undeclared'][0],'exact_anchor_count':3,'all_other_needles':'unchanged'}
manifest=json.loads((HERE/'promotion/manifest.json').read_text())
h.guard();planned={};changes={}
for name,item in manifest['files'].items():
 assert h.pins[item['source']]==item['source_sha256'];assert h.pins[item['candidate']]==item['candidate_sha256']
 assert h.pins[item['destination']]==item['candidate_sha256'],('actual public module differs from reviewed imports-only candidate',item['destination'])
for relative in h.staged:
 if relative.startswith('experiments/public-features/') and relative.endswith('.bend') and '/promotion/' not in relative:
  before=(h.stage/relative).read_bytes();text=before.decode()
  substitutions={'import feature.bend as ':'import ../../src/ecs/feature.bend as ','import provider.bend as ':'import ../../src/ecs/feature-provision.bend as '}
  counts={old:text.count(old) for old in substitutions}
  for old,new in substitutions.items():text=text.replace(old,new)
  if text.encode()!=before:
   planned[relative]=text.encode();changes[relative]={'kind':'consumer imports only','before_sha256':h.staged[relative],'sha256':hashlib.sha256(text.encode()).hexdigest(),'anchor_counts':counts}
prospective=dict(h.staged)
for relative,content in planned.items():prospective[relative]=hashlib.sha256(content).hexdigest()
h.r['live_public_consumer_rebase']={'reviewed_manifest':manifest,'actual_public_pins':{item['destination']:h.pins[item['destination']] for item in manifest['files'].values()},'intentional_changes':changes,'prospective_full_inventory':prospective,'scope':'Actual live core modules copied unchanged; only consumer import paths and exact diagnostic type paths rebased'}
h.guard()
for relative,content in planned.items():
 dest=h.stage/relative;dest.parent.mkdir(parents=True,exist_ok=True);dest.write_bytes(content)
h.staged=dict(prospective);h.guard()
target=h.stage/'src/ecs/feature.bend';original=target.read_text();key=str(target.relative_to(h.stage));original_hash=hashlib.sha256(original.encode()).hexdigest();assert module.sha(target)==h.staged[key]
variants=[('omitted-dependency','case Feature{_,_,deps}: required(names(~S,deps),selected)','case Feature{_,_,deps}: Valid{}','runtime','runtime-main.bend'),('reordered-output','P.Sequence{hb,tb},P.Sequence{hu,tu}','P.Sequence{tb,hb},P.Sequence{tu,hu}','runtime','runtime-main.bend'),('reordered-names','names(~S,left),names(~S,right)','names(~S,right),names(~S,left)','falsify','falsify.bend'),('omitted-visibility','List.append(&2,SF.Entry<S>,own,visibility(~S,dependencies))','own','falsify','falsify.bend')]
plans=[]
for name,old,new,label,file in variants:
 assert original.count(old)==1,(name,'anchor count')
 mutated=original.replace(old,new);prospective=dict(h.staged);prospective[key]=hashlib.sha256(mutated.encode()).hexdigest();assert {k for k in prospective if prospective[k]!=h.staged[k]}=={key}
 plans.append((name,mutated,prospective,label,file))
 h.r.setdefault('mutation_plans',{})[name]={'changed':key,'original_sha256':original_hash,'source_sha256':prospective[key],'original_anchor':old,'replacement':new,'anchor_count':1,'intentional_changed_inventory':[key],'prospective_full_inventory':prospective}
labels=['preflight-'+name+'-check' for name in ['runtime','recipe','scope','falsify']]+['law-draft-check']+[name+'-negative' for name in diag]+['TS-reference','TS-repeated-dependency']
for label in ['runtime','recipe','scope','falsify']+[plan[0] for plan in plans]:
 labels.extend([label+suffix for suffix in ['-check','-emit-JS','-run-JS','-emit-Native','-clang','-run-Native']])
assert len(labels)==len(set(labels)),('prospective command label collision',labels)
h.r['prospective_command_labels']=labels
h.guard()
if args.plan_only:
 h.r['status']='PLAN_VALIDATED';h.r['scope']='Source/tool/config freeze and full label/mutant-plan validation only; no checker/backend execution';h.save();print(args.output);raise SystemExit(0)
def witness(name,backend):
 path=h.out/(name+'-run-'+backend+'.stdout');record=next(c for c in h.r['commands'] if c['label']==name+'-run-'+backend)
 assert module.sha(path)==record['stdout_sha256'];text=path.read_text();assert module.sha(path)==record['stdout_sha256'];lines=text.strip().splitlines();found=[]
 if name=='omitted-dependency':
  for schema in ['A','B']:
   prefix=schema+'-missing=executed|trace=[build:Combat, build:Core, bootstrap:Combat, bootstrap:Core, update:Combat, update:Core]|calls=[2, 2]|'
   matched=[line for line in lines if line.startswith(prefix)];assert len(matched)==1,(name,backend,lines);found+=matched
 elif name=='reordered-output':
  for schema in ['A','B']:
   prefix=schema+'-selected=executed|trace=[build:Combat, build:Core, bootstrap:Core, bootstrap:Combat, update:Core, update:Combat]|calls=[2, 2]|'
   matched=[line for line in lines if line.startswith(prefix) and '|observations=[ran:2, ran:1, ran:2, ran:1]|requirements=[component:1, component:2]' in line];assert len(matched)==1,(name,backend,lines);found+=matched
 elif name=='reordered-names':
  literal='names|[Core, Combat]|[Combat, Core]';assert lines.count(literal)==1,(name,backend,lines);found=[literal]
 elif name=='omitted-visibility':
  literal='visibility|[addon:addon]|[addon:addon, combat:combat, core:core]';assert lines.count(literal)==1,(name,backend,lines);found=[literal]
 else:raise AssertionError(name)
 return found
try:
 for label,file in [('runtime','runtime-main.bend'),('recipe','recipe-main.bend'),('scope','scope-main.bend'),('falsify','falsify.bend')]:h.run('preflight-'+label+'-check',['bend',h.stage/str((HERE/file).relative_to(module.ROOT)),'--check-only'],5)
 text=h.run('law-draft-check',['bend',h.stage/str((HERE/'LAWS.bend').relative_to(module.ROOT)),'--check-only'],5,good=False);assert '4 TODOs' in text,text
 for name,needles in diag.items():
  text=h.run(name+'-negative',['bend',h.stage/str((HERE/('negative-'+name+'.bend')).relative_to(module.ROOT)),'--check-only'],5,good=False);assert all(n in text for n in needles),(name,text)
 if args.preflight_only:h.r['status']='PREFLIGHT_PASS';h.r['admission']='Independent review required before backend execution'
 else:
  observed=json.loads(h.run('TS-reference',['node',h.stage/str((HERE/'reference.mjs').relative_to(module.ROOT))],5));trace=['build:Combat','build:Core','bootstrap:Combat','bootstrap:Core','update:Combat','update:Core'];reference=[]
  for root in ['FeatureAlpha','FeatureBeta']:
   reference.append({'root':root,'case':'selected-order','trace':trace,'names':['Combat','Core','Empty'],'empty':{'label':'empty','bootstrap':[],'update':[]}})
   for case,error in [('duplicate','Duplicate feature name: Core'),('missing','Missing required feature: Core'),('duplicate-before-missing','Duplicate feature name: Combat')]:reference.append({'root':root,'case':case,'error':error,'trace':trace})
  assert observed==reference;h.r['TS_observation']=observed
  repeated=json.loads(h.run('TS-repeated-dependency',['node',h.stage/str((HERE/'dependency-reference.mjs').relative_to(module.ROOT))],5));assert repeated==[{'root':r,'trace':['Combat','Core'],'names':['Combat','Core']} for r in ['RepeatedAlpha','RepeatedBeta']];h.r['TS_repeated_dependency']=repeated
  for label,file in [('runtime','runtime-main.bend'),('recipe','recipe-main.bend'),('scope','scope-main.bend'),('falsify','falsify.bend')]:h.backends(label,h.stage/str((HERE/file).relative_to(module.ROOT)),expected[label])
  for name,mutated,prospective,label,file in plans:
   h.guard();assert module.sha(target)==original_hash;target.write_text(mutated);h.staged=dict(prospective);h.guard();h.r['mutants'][name]={**h.r['mutation_plans'][name],'backends':{},'counterexamples':{}}
   h.backends(name,h.stage/str((HERE/file).relative_to(module.ROOT)),expected[label],True)
   for backend in ['JS','Native']:h.r['mutants'][name]['counterexamples'][backend]=witness(name,backend)
   target.write_text(original);h.staged[key]=module.sha(target);h.guard()
  h.r['status']='PASS'
 h.guard()
finally:h.save()
print(args.output)
