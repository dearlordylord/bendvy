"""Full small/grown application repeated transport. Review before measurement."""
from pathlib import Path
import argparse,hashlib,importlib.util,json,runpy,time,itertools,statistics
HERE=Path(__file__).resolve().parent
spec=importlib.util.spec_from_file_location('feature_log_guard',HERE.parent/'guarded-logs.py');guard=importlib.util.module_from_spec(spec);spec.loader.exec_module(guard)
p=argparse.ArgumentParser();p.add_argument('--output',type=Path,default=guard.ROOT/'.artifacts'/('features40-repeated-'+str(time.time_ns())));p.add_argument('--preflight-only',action='store_true');p.add_argument('--measure',action='store_true');p.add_argument('--host-label',choices=['NOISY','QUIET_UNVERIFIED','QUIET_OBSERVED'],default='NOISY');args=p.parse_args()
ts=guard.ROOT/'.references/bevy-ts'
extras=[Path(__file__),HERE.parent/'guarded-logs.py',HERE/'expected.json',HERE/'repeated-observations.py',HERE/'repeated200-reference.mjs',HERE/'repeat-derivation.json',HERE/'repeat200-delta.json',HERE/'application.bend',HERE/'reference.mjs',ts/'package.json',ts/'packages/core/package.json']+list((ts/'packages/core/src').rglob('*.ts'))
fixtures=[HERE/'repeated200-small.bend',HERE/'repeated200-grown.bend',guard.ROOT/'src/ecs/feature.bend',guard.ROOT/'src/ecs/feature-provision.bend']
h=guard.Harness(args.output,fixtures,extras)
h.guard();planned={};changes={}
for relative in h.staged:
 if relative.startswith('experiments/public-features/') and relative.endswith('.bend'):
  before=(h.stage/relative).read_bytes();text=before.decode();substitutions={'import feature.bend as ':'import ../../src/ecs/feature.bend as ','import provider.bend as ':'import ../../src/ecs/feature-provision.bend as '};counts={old:text.count(old) for old in substitutions}
  for old,new in substitutions.items():text=text.replace(old,new)
  if text.encode()!=before:planned[relative]=text.encode();changes[relative]={'before_sha256':h.staged[relative],'after_sha256':hashlib.sha256(text.encode()).hexdigest(),'anchor_counts':counts}
prospective=dict(h.staged)
for relative,content in planned.items():prospective[relative]=hashlib.sha256(content).hexdigest()
h.r['actual_public_rebase']={'intentional_import_changes':changes,'prospective_full_inventory':prospective}
h.guard()
for relative,content in planned.items():(h.stage/relative).write_bytes(content)
h.staged=dict(prospective);h.guard()
full=json.loads((HERE/'expected.json').read_text());expected={size:[row for row in full if '-'+size+'-' in row.split('=',1)[0]] for size in ['small','grown']};assert all(len(rows)==8 for rows in expected.values())
orders=list(itertools.permutations(['TS','JS','Native']));labels=[]
for size in expected:
 labels+=[size+'-preflight-check',size+'-TS']+[size+suffix for suffix in ['-check','-emit-JS','-run-JS','-emit-Native','-clang','-run-Native']]
 for round_index,order in enumerate(orders):labels+=[size+'-sample-'+str(round_index)+'-'+role for role in order]
assert len(labels)==len(set(labels));h.r['prospective_command_labels']=labels
h.r['comparison_protocol']={'iterations_per_process':200,'full_cases_per_iteration_per_group':8,'groups':['small','grown'],'balanced_role_orders':orders,'timer':'perf_counter_ns directly around reviewed supervisor.execute (process startup, complete200iterations/output/finite cleanup included); all source/tool/log guards outside timer','host_label':args.host_label,'limits':'checker5,emit30,clang120,runtime5; Native1thread/GPUoff','cost_limits':'Both execute same shared feature behavior and complete owners/refusals. Extra Bend World/Registry observations remain checked and timed; no fabricated TS fields, strict universal equal cost or feature acceptance claimed. Startup included once and amortized; no cold-only proxy.','threshold':'NONE; descriptive six balanced samples/group, existing global/shared gates separate'}
h.guard()
try:
 for size in expected:h.run(size+'-preflight-check',['bend',h.stage/str((HERE/('repeated200-'+size+'.bend')).relative_to(guard.ROOT)),'--check-only'],5)
 if args.preflight_only:h.r['status']='PREFLIGHT_PASS';h.r['admission']='Independent frozen-source protocol and semantic admission required before backend/measurement'
 else:
  normalize=runpy.run_path(str(h.stage/str((HERE/'repeated-observations.py').relative_to(guard.ROOT))))['normalized_group'];h.guard()
  for size in expected:
   shared=normalize('\n'.join(expected[size]),size);reference=h.run(size+'-TS',['node',h.stage/str((HERE/'repeated200-reference.mjs').relative_to(guard.ROOT)),size],5);blocks=reference.strip().splitlines();assert len(blocks)==200;assert all(json.loads(block)==shared for block in blocks);h.r.setdefault('TS_full_observations',{})[size]=[json.loads(block) for block in blocks]
   h.backends(size,h.stage/str((HERE/('repeated200-'+size+'.bend')).relative_to(guard.ROOT)),expected[size]*200)
   for role in ['JS','Native']:
    path=h.out/(size+'-run-'+role+'.stdout');record=next(item for item in h.r['commands'] if item['label']==size+'-run-'+role);assert guard.sha(path)==record['stdout_sha256'];lines=path.read_text().strip().splitlines();assert guard.sha(path)==record['stdout_sha256'];assert len(lines)==1600;assert all(normalize('\n'.join(lines[i:i+8]),size)==shared for i in range(0,1600,8))
  h.r['status']='CORRECTNESS_PASS'
  if args.measure:
   execute=guard.shared.supervisor.execute;durations={}
   def timed_execute(argv,cap,env=None):
    start=time.perf_counter_ns()
    try:return execute(argv,cap,env)
    finally:durations['last']=time.perf_counter_ns()-start
   guard.shared.supervisor.execute=timed_execute
   try:
    for size in expected:
     shared=normalize('\n'.join(expected[size]),size);samples=[];h.r.setdefault('samples',{})[size]=samples
     for round_index,order in enumerate(orders):
      row={'round':round_index,'order':order,'nanoseconds':{},'status':'INCOMPLETE'};samples.append(row)
      for role in order:
       argv=['node',h.stage/str((HERE/'repeated200-reference.mjs').relative_to(guard.ROOT)),size] if role=='TS' else ['node',h.out/(size+'.js')] if role=='JS' else [h.out/(size+'.native'),'--threads','1','--gpu','off']
       label=size+'-sample-'+str(round_index)+'-'+role;durations.pop('last',None)
       try:text=h.run(label,argv,5)
       finally:
        if 'last' in durations:
         row['nanoseconds'][role]=durations['last']
         if h.r['commands'] and h.r['commands'][-1]['label']==label:h.r['commands'][-1]['elapsed_ns']=durations['last']
       if role=='TS':blocks=text.strip().splitlines();assert len(blocks)==200;assert all(json.loads(block)==shared for block in blocks)
       else:assert text.strip().splitlines()==expected[size]*200
      row['status']='FULL_OUTPUTS_VALIDATED'
     h.r.setdefault('samples',{})[size]=samples;h.r.setdefault('descriptive_ratios',{})[size]={role:statistics.median(row['nanoseconds'][role]/row['nanoseconds']['TS'] for row in samples) for role in ['JS','Native']}
   finally:guard.shared.supervisor.execute=execute
   h.r['status']='MEASURED_DESCRIPTIVE_ONLY'
 h.guard()
finally:h.save()
print(args.output)
