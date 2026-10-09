"""No-child exact recorded #46 JS observations and Native emission refusal."""
import gzip,hashlib,json
from pathlib import Path
import transport
HERE=Path(__file__).resolve().parent;E=HERE/'evidence/current-v1'
sha=lambda raw:hashlib.sha256(raw).hexdigest()
read=lambda path:gzip.decompress(path.read_bytes())
plans=json.loads((E/'prepared-plan-digests.json').read_text());joins=json.loads((E/'source-joins.json').read_text())
for alias,row in joins.items():
 obj=E/'source-objects'/row['object'];assert obj.is_file() and not obj.is_symlink() and sha(read(obj))==row['sha256']
# Loading unchanged parser/transport is required by this lightweight verifier;
# complete historical source objects remain archived independently.
for path in (HERE/'transport.py',transport.PARSER):
 suffix='/qualification-v1/transport.py' if path.name=='transport.py' else '/public-simulation/bend-v1/parse-report.py'
 hashes={v['sha256'] for k,v in joins.items() if k.endswith(suffix)}
 assert hashes=={sha(path.read_bytes())},'verifier helper differs from recorded source'
counts={}
for name,binding in plans.items():
 folder=E/name;plan=json.loads((folder/'plan.json').read_text());assert sha((folder/'plan.json').read_bytes())==binding['planSha256']
 role,backend=name.split('-');assert plan['role']==role and plan['native']==(backend=='native') and plan['oracleCommit']=='3d77f645'
 assert plan['tools']['python'] in plan['inputs']
 expected_raw=read(folder/'expected.stdout.gz');baseline_raw=read(folder/'baseline.stdout.gz')
 for leaf,body in [('expected.stdout',expected_raw),('baseline.stdout',baseline_raw)]:
  assert plan['inputs'][str(Path(binding['plan']).parent/leaf)]==sha(body)
 oracle_name={'normal':'normal','skipped':'skipped-validator','partial':'partial-write'}[role]+'-expected.json'
 candidates=[v for k,v in joins.items() if k.endswith('/oracle-v1/'+oracle_name)];assert len(candidates)==1
 expected=json.loads(read(E/'source-objects'/candidates[0]['object']));assert candidates[0]['sha256']==plan['oracleSha256']
 entry=Path(plan['commands'][0]['argv'][4]);assert transport.parse(expected_raw,entry)==expected and transport.render(expected,entry)==expected_raw
 receipt_file=folder/'receipt.json'
 if not receipt_file.exists():
  assert backend=='native' and role!='normal' and (not (folder/'raw').exists() or not any((folder/'raw').iterdir()));counts[name]='PREPARED_NOT_EXECUTED';continue
 receipt=json.loads(receipt_file.read_text());assert receipt['preparedPlanSha256']==binding['planSha256'] and receipt.get('guardFailures',[])==[]
 assert {p.name for p in (folder/'raw').iterdir()}=={name+'.gz' for name in receipt['logs']}
 for leaf,digest in receipt['logs'].items():assert sha(read(folder/'raw'/(leaf+'.gz')))==digest
 generated=folder/'generated'
 recorded_generated=receipt['generated']
 assert ({p.name for p in generated.iterdir()} if generated.exists() else set())=={Path(p).name+'.gz' for p in recorded_generated}
 for path,digest in recorded_generated.items():assert sha(read(generated/(Path(path).name+'.gz')))==digest
 if backend=='native':
  assert role=='normal'  and receipt['status']=='INCOMPLETE' and len(receipt['commands'])==1
  row=receipt['commands'][0];assert row['label']=='complete-emit' and row['exit']==1 and row['failure'] is None and row['capSeconds']==30
  assert read(folder/'raw/complete-emit.stderr.gz')==b'Error: an arity over 247\n'
  assert receipt['generated']=={} and 'unexpected command exit: 1' in receipt['error'];counts[name]='C_EMIT_ARITY_REFUSED';continue
 assert receipt['status']=='DEVELOPMENT_PASS' and len(receipt['commands'])==2 and 'error' not in receipt
 for row,command in zip(receipt['commands'],plan['commands']):
  assert row['exit']==0 and row['failure'] is None and all(row[k]==v for k,v in command.items())
  assert row['argv'][:3]==['/usr/bin/taskset','-c','5']
  assert row['runnerSHA256']==joins['/workspace/formal-proofs/bendvy/scripts/task_runner.py']['sha256']
  assert read(folder/'raw'/(row['label']+'.stderr.gz'))==b''
 assert [row['capSeconds'] for row in receipt['commands']]==[30,5]
 observed=read(folder/'raw/complete-run.stdout.gz');assert observed==expected_raw and transport.parse(observed,entry)==expected
 if role!='normal':
  assert observed!=baseline_raw and transport.parse(observed,entry)!=transport.parse(baseline_raw,entry)
  assert receipt['unchangedBaselineRejected']=={'typed':True,'raw':True,'baselineSha256':'ca88bdec56290ba3b5460463f59c4ddda389d2dcc7ecfa58d6d633c35016e075'}
 counts[name]={'status':'COMPLETE_JS_ORACLE_PASS','bytes':len(observed),'rawSha256':sha(observed)}
print(json.dumps({'scope':__doc__,'cohorts':counts,'sourceAliases':len(joins),'NativeQualification':False,'full46Closure':False},indent=2))
