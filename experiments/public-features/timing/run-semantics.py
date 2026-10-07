"""Full feature application equality admission; no timing or thresholds."""
from pathlib import Path
import argparse,importlib.util,json,time,runpy
HERE=Path(__file__).resolve().parent
spec=importlib.util.spec_from_file_location('feature_log_guard',HERE.parent/'guarded-logs.py');guard=importlib.util.module_from_spec(spec);spec.loader.exec_module(guard)
p=argparse.ArgumentParser();p.add_argument('--output',type=Path,default=guard.ROOT/'.artifacts'/('features40-full-application-'+str(time.time_ns())));p.add_argument('--preflight-only',action='store_true');p.add_argument('--plan-only',action='store_true');args=p.parse_args()
expected=json.loads((HERE/'expected.json').read_text());ts=guard.ROOT/'.references/bevy-ts'
extra=[Path(__file__),HERE.parent/'guarded-logs.py',HERE/'expected.json',HERE/'observations.py',HERE/'reference.mjs']+list((ts/'packages/core/src').rglob('*.ts'))+[ts/'package.json',ts/'packages/core/package.json']
h=guard.Harness(args.output,[HERE/'application.bend',guard.ROOT/'src/ecs/feature.bend',guard.ROOT/'src/ecs/feature-provision.bend'],extra)
# All affected authored adapters are rebound by import only onto actual core.
import hashlib
h.guard();planned={};changes={}
for relative in h.staged:
 if relative.startswith('experiments/public-features/') and relative.endswith('.bend'):
  before=(h.stage/relative).read_bytes();text=before.decode()
  substitutions={'import feature.bend as ':'import ../../src/ecs/feature.bend as ','import provider.bend as ':'import ../../src/ecs/feature-provision.bend as '}
  counts={old:text.count(old) for old in substitutions}
  for old,new in substitutions.items():text=text.replace(old,new)
  if text.encode()!=before:planned[relative]=text.encode();changes[relative]={'before_sha256':h.staged[relative],'after_sha256':hashlib.sha256(text.encode()).hexdigest(),'anchor_counts':counts}
prospective=dict(h.staged)
for relative,content in planned.items():prospective[relative]=hashlib.sha256(content).hexdigest()
h.r['actual_public_rebase']={'intentional_import_changes':changes,'prospective_full_inventory':prospective,'core_pins':{key:value for key,value in h.pins.items() if key.startswith('src/ecs/')}}
h.guard()
for relative,content in planned.items():(h.stage/relative).write_bytes(content)
h.staged=dict(prospective);h.guard()
h.r['subject']='Two nominal full feature applications: small/grown affine owner packs, valid selected builders and real registered bootstrap/update schedules, duplicate/missing/priority refusal; not recipe-only'
h.r['representation_limits']='Shared observations exclude Bend-specific World/Registry internals absent from actual TS. They remain retained and checked against the complete Bend literal oracle. No per-feature performance criterion or registration-failure policy selected.'
labels=['application-preflight-check','TS-full-application']+['application'+suffix for suffix in ['-check','-emit-JS','-run-JS','-emit-Native','-clang','-run-Native']]
assert len(labels)==len(set(labels));h.r['prospective_command_labels']=labels
h.guard()
if args.plan_only:
 h.r['status']='PLAN_VALIDATED';h.r['scope']='Source/tool/config freeze and prospective label/import inventory only; no execution or measurement';h.save();print(args.output);raise SystemExit(0)
try:
 h.run('application-preflight-check',['bend',h.stage/str((HERE/'application.bend').relative_to(guard.ROOT)),'--check-only'],5)
 if args.preflight_only:h.r['status']='PREFLIGHT_PASS';h.r['admission']='Independent exact-source semantic admission required before backend or measurement'
 else:
  normalize=runpy.run_path(str(h.stage/str((HERE/'observations.py').relative_to(guard.ROOT))))['normalized'];h.guard();shared_expected=normalize('\n'.join(expected))
  observed=json.loads(h.run('TS-full-application',['node',h.stage/str((HERE/'reference.mjs').relative_to(guard.ROOT))],5));assert observed==shared_expected,(observed,shared_expected);h.r['TS_full_observations']=observed
  h.backends('application',h.stage/str((HERE/'application.bend').relative_to(guard.ROOT)),expected)
  for backend in ['JS','Native']:
   path=h.out/('application-run-'+backend+'.stdout');record=next(item for item in h.r['commands'] if item['label']=='application-run-'+backend);assert guard.sha(path)==record['stdout_sha256'];text=path.read_text();assert guard.sha(path)==record['stdout_sha256'];assert normalize(text)==observed
  h.r['status']='PASS'
 h.guard()
finally:h.save()
print(args.output)
