"""Exploratory public TS application observation; no Bend/backend acceptance."""
import pathlib,sys,hashlib,json,time,os,shutil
D=pathlib.Path(__file__).resolve().parent;R=D.parents[3]
sys.path.insert(0,str(R/'experiments/s-prep/fivehour-connected-gates'));import supervisor
sys.path.insert(0,str(D.parent/'current-core-replay/guarded-v2'));import raw_supervisor
sha=lambda p:hashlib.sha256(p.read_bytes()).hexdigest()
files={pathlib.Path(__file__).resolve(),D/'reference.mjs',pathlib.Path(shutil.which('node')).resolve(),pathlib.Path(supervisor.__file__).resolve(),D.parent/'current-core-replay/guarded-v2/raw_supervisor.py'}|set((R/'.references/bevy-ts/packages/core/src').rglob('*.ts'))
pins={str(p):sha(p) for p in sorted(files)};out=D/'development'/str(time.time_ns());out.mkdir(parents=True)
receipt={'scope':'exploratory actual public TS full application only','pins':pins,'argv':['taskset','-c','8','node',str(D/'reference.mjs')],'limitSeconds':5,'capture':'raw merged stdout/stderr; explicitly empty stderr','status':'INCOMPLETE'};(out/'receipt.json').write_text(json.dumps(receipt,indent=2)+'\n')
r=raw_supervisor.execute(receipt['argv'],5,env=os.environ.copy());(out/'output.stdout').write_bytes(r['stdout']);(out/'output.stderr').write_bytes(r['stderr']);receipt.update({'exit':r['exit'],'failure':r['failure'],'stdoutSHA256':sha(out/'output.stdout'),'stderrSHA256':sha(out/'output.stderr')});assert all(sha(pathlib.Path(p))==h for p,h in pins.items());receipt['status']='ACTUAL_TS_APPLICATION_OBSERVED' if r['exit']==0 and r['failure'] is None else 'FAIL';(out/'receipt.json').write_text(json.dumps(receipt,indent=2)+'\n');print(out,receipt['status'])
