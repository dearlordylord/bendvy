#!/usr/bin/env python3
import pathlib,json,hashlib,tarfile,io
H=pathlib.Path(__file__).resolve().parent;out=H/'evidence';out.mkdir(exist_ok=True)
paths=['/tmp/bendvy-packed-slot-row-controls-v1', '/tmp/bendvy-packed-slot-row-controls-v2', '/tmp/bendvy-packed-slot-value-controls-v1', '/tmp/bendvy-packed-slot-negatives-v1', '/tmp/bendvy-packed-slot-negatives-v2', '/tmp/bendvy-packed-slot-row-mutants-v1', '/tmp/bendvy-packed-slot-row-mutants-wrong-old-v2', '/tmp/bendvy-packed-slot-rollback-v1', '/tmp/bendvy-packed-slot-rollback-v2', '/tmp/bendvy-packed-slot-rollback-v3', '/tmp/bendvy-packed-slot-rollback-v4', '/tmp/bendvy-packed-slot-host-ingress-v1', '/tmp/bendvy-packed-slot-foreign-return-v1', '/tmp/bendvy-packed-slot-foreign-return-v2', '/tmp/bendvy-packed-slot-missing-return-v1', '/tmp/bendvy-packed-slot-factory-v1', '/tmp/bendvy-packed-slot-hole-queue-apply-v1']
allowed={'.json','.jsonl','.txt','.stdout','.stderr','.bend','.c','.js'};items={}
for root in paths:
 p=pathlib.Path(root)
 if not p.exists():continue
 for f in p.rglob('*'):
  if f.is_file() and f.suffix in allowed:items[p.name+'/'+str(f.relative_to(p))]=f.read_bytes()
for label,path in [('original','/tmp/bendvy-packed-main-slot-motion-v4'),('corrected','/tmp/bendvy-packed-main-slot-motion-v4-receipt-v2')]:
 p=pathlib.Path(path)
 for n in ['overlay.json','cache-specialization.json']:items['source-manifests/'+label+'/'+n]=(p/n).read_bytes()
 for f in (p/'experiments/s-integrate').glob('*.bend'):items['source-manifests/'+label+'/sources/'+f.name]=f.read_bytes()
with tarfile.open(out/'controls.tar.gz','w:gz') as tar:
 for n,b in sorted(items.items()):info=tarfile.TarInfo(n);info.size=len(b);info.mtime=0;tar.addfile(info,io.BytesIO(b))
manifest={'files':{n:hashlib.sha256(b).hexdigest() for n,b in sorted(items.items())},'archiveSHA256':hashlib.sha256((out/'controls.tar.gz').read_bytes()).hexdigest(),'excludes':'Native executables; exact C, JS, commands and outputs retained'};(out/'manifest.json').write_text(json.dumps(manifest,indent=2)+'\n');print(len(items),(out/'controls.tar.gz').stat().st_size)
