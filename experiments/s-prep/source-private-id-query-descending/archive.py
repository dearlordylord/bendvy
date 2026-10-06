#!/usr/bin/env python3
import pathlib,json,hashlib,tarfile,io
H=pathlib.Path(__file__).resolve().parent;out=H/'evidence';out.mkdir(exist_ok=True)
paths=['/tmp/bendvy-cursor-descending-motion-build-v1', '/tmp/bendvy-cursor-descending-health-build-v1', '/tmp/bendvy-cursor-descending-motion-full65-v1', '/tmp/bendvy-cursor-descending-health-full65-v1', '/tmp/bendvy-cursor-descending-lifecycle-v1', '/tmp/bendvy-cursor-descending-order-v1', '/tmp/bendvy-cursor-descending-shape-v1', '/tmp/bendvy-cursor-descending-row-v1', '/tmp/bendvy-cursor-descending-mutants-v1']
allowed={'.json','.jsonl','.txt','.stdout','.stderr','.bend','.c','.js'};items={}
for root in paths:
 p=pathlib.Path(root)
 if not p.exists():continue
 for f in p.rglob('*'):
  if f.is_file() and f.suffix in allowed:items[p.name+'/'+str(f.relative_to(p))]=f.read_bytes()
for label,path in [('baseline','/tmp/bendvy-private-id-query-v4'),('candidate','/tmp/bendvy-private-id-query-descending-v1'),('reproduced','/tmp/bendvy-private-id-query-descending-reproduced-v1')]:
 p=pathlib.Path(path)
 for n in ['overlay.json','cache-specialization.json']:items['source-manifests/'+label+'/'+n]=(p/n).read_bytes()
 for f in (p/'experiments/s-integrate').glob('*.bend'):items['source-manifests/'+label+'/sources/'+f.name]=f.read_bytes()
for n in ['query-lifecycle.bend','query-expected.txt','owners.bend']:
 p=pathlib.Path('/workspace/formal-proofs/bendvy/experiments/s-prep/primitive-storage-integration')/n;items['protected-inputs/'+n]=p.read_bytes()
items['guide/bend-guide.txt']=pathlib.Path('/tmp/bendvy-cursor-descending-guide.txt').read_bytes()
with tarfile.open(out/'controls.tar.gz','w:gz') as tar:
 for n,b in sorted(items.items()):info=tarfile.TarInfo(n);info.size=len(b);info.mtime=0;tar.addfile(info,io.BytesIO(b))
manifest={'files':{n:hashlib.sha256(b).hexdigest() for n,b in sorted(items.items())},'archiveSHA256':hashlib.sha256((out/'controls.tar.gz').read_bytes()).hexdigest(),'excludes':'Native executables; exact C, JS, commands and outputs retained'};(out/'manifest.json').write_text(json.dumps(manifest,indent=2)+'\n');print(len(items),(out/'controls.tar.gz').stat().st_size)
