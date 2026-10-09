"""Check import-only promotion and actual complete consumers; no backend child."""
import hashlib,json,re,types
from pathlib import Path
HERE=Path(__file__).resolve().parent
HELPER=Path('/workspace/formal-proofs/bendvy/scripts/task_runner.py')
runner=types.ModuleType('promotion_task_runner')
runner.__file__=str(HELPER)
exec(compile(HELPER.read_bytes(),str(HELPER),'exec'),runner.__dict__)
manifest=json.loads((HERE/'import-only-map.json').read_text())
deltas={r['candidate']:r for r in json.loads((HERE/'binding-deltas.json').read_text())}
pattern=re.compile(r'^import .*$',re.M)
for row in manifest['files']:
 source=Path(row['source']).read_bytes();candidate=(HERE/row['candidate']).read_bytes()
 assert hashlib.sha256(source).hexdigest()==row['sourceSha256']
 if row['candidate'] in deltas:
  assert hashlib.sha256(candidate).hexdigest()==deltas[row['candidate']]['after']
 else:
  assert hashlib.sha256(candidate).hexdigest()==row['candidateSha256']
  assert pattern.sub('',source.decode())==pattern.sub('',candidate.decode())
checks=[]
for name in manifest['entries']:
 argv=['flock','/tmp/bendvy-parity-heavy.lock','taskset','-c','5','timeout','--signal=KILL','5s','/home/node/.bend/bin/bend-2.0.35',str(HERE/name),'--check-only']
 result=runner.run(argv,timeout=8,capture_output=True,text=True)
 negative='/negatives/' in name
 checks.append({'entry':name,'argv':argv,'exit':result.returncode,'stdout':result.stdout,'stderr':result.stderr,'expected':'type rejection' if negative else 'source acceptance'})
 assert result.returncode==1 if negative else result.returncode==0,(name,result)
 assert 'Error' in result.stdout+result.stderr if negative else 'ALL PROOFS CHECK' in result.stdout
(HERE/'source-checks.json').write_text(json.dumps({'scope':'source/type only; no new backend or proof claim','checks':checks},indent=2)+'\n')
print('PASS preserved bodies/binding deltas + two complete consumers + eight actual authority/affine negatives')
