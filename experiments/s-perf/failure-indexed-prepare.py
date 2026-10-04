#!/usr/bin/env python3
"""Three-way private diagnostic instrumentation onto frozen indexed IO snapshot."""
import pathlib,json,hashlib,shutil,subprocess,tempfile
H=pathlib.Path(__file__).resolve().parent;R=H.parents[1];S=pathlib.Path('/tmp/bendvy-indexed-final2');D=H/'failure-indexed-overlay'
manifest=json.loads((S/'overlay.json').read_text())
sha=lambda p:hashlib.sha256(p.read_bytes()).hexdigest()
# Snapshot provenance must match its complete declared sources, including dirty copied overrides.
for name,digest in manifest['sources'].items():assert sha(S/name)==digest,name
shutil.copytree(H/'failure-overlay',D,dirs_exist_ok=True)
report={'snapshot_manifest_sha256':sha(S/'overlay.json'),'snapshot_overrides':manifest['overrides'],'merges':[],'sources':{}}
for name in ['storage','identity','commands','query','observations','host','dispatcher','measurement-failure-host']:
 relative=f'experiments/s-integrate/{name}.bend';target=D/relative;indexed=S/relative;baseline=R/relative;quiet=H/'failure-overlay'/relative
 if quiet.read_bytes()==baseline.read_bytes():target.write_bytes(indexed.read_bytes());status='COPY'
 else:
  with tempfile.TemporaryDirectory(prefix='failure-merge-') as temp:
   a=pathlib.Path(temp)/'actual';a.write_bytes(indexed.read_bytes())
   result=subprocess.run(['git','merge-file','-p',str(a),str(baseline),str(quiet)],capture_output=True,timeout=5)
   target.write_bytes(result.stdout);status='MERGED' if result.returncode==0 else 'CONFLICT'
 report['merges'].append({'module':name,'status':status,'indexed_sha256':sha(indexed),'baseline_sha256':sha(baseline),'diagnostic_sha256':sha(quiet)})
for name in ['failure-checks','failure-service-guard']:
 text=(H/(name+'.bend')).read_text().replace('failure-overlay/','failure-indexed-overlay/').replace('./failure-checks.bend','./failure-indexed-checks.bend')
 (H/(name.replace('failure-','failure-indexed-',1)+'.bend')).write_text(text)
for file in D.rglob('*.bend'):
 text=file.read_text().replace('../../../failure-checks.bend','../../../failure-indexed-checks.bend').replace('../../../failure-service-guard.bend','../../../failure-indexed-service-guard.bend')
 file.write_text(text)
# Exact committed candidate correction, rather than a moving working-tree import.
current=subprocess.run(['git','-C','/workspace/formal-proofs/bendvy','show','4963856:experiments/s-perf/candidate/commands.bend'],capture_output=True,check=True,timeout=5).stdout
assert hashlib.sha256(current).hexdigest()=='27c4c4c0db47c6f2b4e21412ec9ebdc630ddec78fa491511f0ed3526a4e7561b'
(D/'experiments/s-integrate/commands.bend').write_bytes(current)
report['post_snapshot_override']={'commit':'4963856','module':'commands','sha256':hashlib.sha256(current).hexdigest(),'reason':'direct tail-loop preflight, shared exact current candidate'}
report['sources']={str(p.relative_to(D)):sha(p) for p in D.rglob('*.bend')}
(H/'failure-indexed-manifest.json').write_text(json.dumps(report,indent=2)+'\n')
print(json.dumps(report['merges'],indent=2))
assert all(x['status']!='CONFLICT' for x in report['merges']),'resolve actual IO instrumentation conflicts explicitly before any checker/timing claim'
