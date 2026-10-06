#!/usr/bin/env python3
import pathlib,json,hashlib,tarfile,io
H=pathlib.Path(__file__).resolve().parent;out=H/'evidence';out.mkdir(exist_ok=True)
paths=['/tmp/bendvy-query-paired-controls-'+n+'-v1' for n in ['lifecycle','shape','generic','negatives','order-mutants','shape-mutants','generic-mutants']]
allowed={'.json','.jsonl','.txt','.stdout','.stderr','.bend','.c','.js'};items={}
for root in paths:
 p=pathlib.Path(root)
 if not p.exists():continue
 for f in p.rglob('*'):
  if f.is_file() and f.suffix in allowed:items[p.name+'/'+str(f.relative_to(p))]=f.read_bytes()
P=pathlib.Path('/workspace/formal-proofs/bendvy/experiments/s-prep/primitive-storage-integration')
for n in ['owners.bend','query-lifecycle.bend','query-expected.txt']:items['protected-inputs/'+n]=(P/n).read_bytes()
p=pathlib.Path('/tmp/bendvy-query-paired-journal-v1')
for n in ['overlay.json','cache-specialization.json']:items['source-manifests/'+n]=(p/n).read_bytes()
for n in [21,24]:items['governing-issues/'+str(n)+'.json']=pathlib.Path(f'/tmp/identity-controls-issue{n}.json').read_bytes()
with tarfile.open(out/'controls.tar.gz','w:gz') as tar:
 for n,b in sorted(items.items()):info=tarfile.TarInfo(n);info.size=len(b);info.mtime=0;tar.addfile(info,io.BytesIO(b))
manifest={'files':{n:hashlib.sha256(b).hexdigest() for n,b in sorted(items.items())},'archiveSHA256':hashlib.sha256((out/'controls.tar.gz').read_bytes()).hexdigest(),'excludes':'Native executables; exact C, JS, commands and outputs retained'};(out/'manifest.json').write_text(json.dumps(manifest,indent=2)+'\n');print(len(items),(out/'controls.tar.gz').stat().st_size)
