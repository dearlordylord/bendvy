"""No-child exact copied-reference continuation metadata joins, not ELF attribution."""
import gzip,hashlib,json
from pathlib import Path
HERE=Path(__file__).resolve().parent;E=HERE/'evidence/current-v1';sha=lambda b:hashlib.sha256(b).hexdigest();read=lambda p:gzip.decompress(p.read_bytes())
plan=json.loads((E/'plan.json').read_text());r=json.loads((E/'receipt.json').read_text());summary=json.loads((E/'RESULT.json').read_text());joins=json.loads((E/'source-joins.json').read_text())
assert sha((E/'plan.json').read_bytes())==r['planSHA256']==summary['planSha256']=='d72b6eea600f2f4d0a2f85dfe43acf8b233e4d83fcce535280ccc8e2e1023f89'
assert r['status']=='REFERENCE_DIAGNOSTIC_TERMINAL' and r['qualifiesInstalledCompiler'] is False and r.get('guardFailures',[])==[] and 'error' not in r
assert len(r['commands'])==1;row=r['commands'][0];assert row['argv']==plan['argv'] and row['capSeconds']==30 and row['exit']==1 and row['failure'] is None
assert plan['argv'][:3]==['/usr/bin/taskset','-c','5'] and row['capture']=='split'
for alias,v in joins.items():assert sha(read(E/'source-objects'/v['object']))==v['sha256']==plan['pins'][alias]
for stream in ('stdout','stderr'):
 raw=read(E/('emit.'+stream+'.gz'));assert sha(raw)==row[stream]['sha256'] and len(raw)==row[stream]['bytes']
assert read(E/'emit.stdout.gz')==b'' and 'artifactSHA256' not in r
assert len(r['guards'])==4
for entry,label in zip(r['guards'],('emit-pre','emit-acquired','emit-post','final')):
 raw=read(E/(label+'.guard.json.gz'));assert sha(raw)==entry['sha256']
 guard=json.loads(raw);assert guard['unchanged'] is True and guard['label']==label
 assert all(guard['actualPins'][k]==v for k,v in plan['pins'].items())
lines=read(E/'emit.stderr.gz').decode().splitlines();cont=[json.loads(x.split(' ',1)[1]) for x in lines if x.startswith('REFERENCE_CONTINUATION_LAYOUT ')];bad=[json.loads(x.split(' ',1)[1]) for x in lines if x.startswith('REFERENCE_ARITY_DIAGNOSTIC ')];loaded=[json.loads(x.split(' ',1)[1]) for x in lines if x.startswith('REFERENCE_LOADED_INPUTS ')]
assert len(cont)==80 and len({x['continuation'] for x in cont})==16 and all(x['source'] is None and x['heldWords']+x['resultWords']==x['total']>247 for x in cont)
assert len(bad)==1 and len(bad[0]['badEntries'])==16 and bad[0]['badNodes']==[]
assert bad[0]['badEntries']==summary['finalBadEntries'] and summary['finalBadNodes']==[]
assert len(loaded)==1 and loaded[0]==summary['loadedSources'] and len(loaded[0])==25
assert all(path in plan['pins'] for path in loaded[0])
assert 'Error: an arity over 247' in '\n'.join(lines) and summary['CArtifactProduced'] is False
assert summary['stderrSha256']==sha(read(E/'emit.stderr.gz')) and summary['stderrBytes']==238803
print('PASS: exact copied-reference source/plan/raw/four-guard joins;80 continuation records,16 oversized frames,25 loaded modules; no C, no installed ELF/performance claim')
