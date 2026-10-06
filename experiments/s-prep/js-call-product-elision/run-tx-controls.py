#!/usr/bin/env python3
"""Exact generated-controller comparison; preserves semantic mutants as supplied."""
import argparse,gzip,hashlib,json,os,subprocess
from pathlib import Path
p=argparse.ArgumentParser();p.add_argument('--baseline',type=Path,required=True);p.add_argument('--output',type=Path,required=True);a=p.parse_args();a.output.mkdir(exist_ok=False);os.sched_setaffinity(0,{9});here=Path(__file__).resolve().parent;r=[]
files=sorted(a.baseline.glob('cached/*/cache-tx-*-controls.js'))+sorted(a.baseline.glob('raw/*/cache-tx-*-controls.js'))+sorted((a.baseline/'suppressed-owner').glob('*/*/cache-tx-*-controls.js'));assert len(files)==8
for source in files:
 label=('suppressed-' if 'suppressed-owner' in str(source) else '')+source.parent.parent.name+'-'+source.parent.name;target=a.output/(label+'.js');argv=['node','--expose-internals',str(here/'rewrite.cjs'),str(source),str(target)];made=subprocess.run(argv,capture_output=True,timeout=5);assert made.returncode==0,made.stderr
 stored=source.with_suffix('.js.jsonl');original=stored.read_bytes() if stored.exists() else subprocess.run(['node',str(source)],check=True,capture_output=True,timeout=5).stdout;got=subprocess.run(['node',str(target)],check=True,capture_output=True,timeout=5).stdout;assert got==original
 (a.output/(label+'.observed.jsonl.gz')).write_bytes(gzip.compress(got,mtime=0));r.append({'source':str(source),'sourceSHA256':hashlib.sha256(source.read_bytes()).hexdigest(),'status':'ALL_CHECKPOINTS_BYTE_EQUAL','checkpointLines':len(got.splitlines()),'storedBaseline':stored.exists(),'stdoutSHA256':hashlib.sha256(got).hexdigest(),'recipe':json.loads(Path(str(target)+'.recipe.json').read_text()),'commands':[argv,*([] if stored.exists() else [['node',str(source)]]),['node',str(target)]],'perCommandLimitSeconds':5})
(a.output/'tx-controls.json').write_text(json.dumps(r,indent=2)+'\n');print({'fixtures':len(r),'checkpoints':sum(x['checkpointLines']for x in r),'status':'ALL_BYTE_EQUAL'})
