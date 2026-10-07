#!/usr/bin/env python3
"""Freeze and execute the actual primary TS machine oracle; no Bend implementation."""
import argparse,gzip,hashlib,importlib.util,json,os,pathlib,sys

from pathlib import Path as _runner_Path
import sys as _runner_sys
_runner_root = next(p for p in _runner_Path(__file__).resolve().parents if (p/'scripts/task_runner.py').is_file())
_runner_sys.path.insert(0, str(_runner_root/'scripts'))
import task_runner

ROOT=pathlib.Path(__file__).resolve().parents[2];HERE=pathlib.Path(__file__).resolve().parent
p=argparse.ArgumentParser();p.add_argument('--output',type=pathlib.Path,required=True);p.add_argument('--cpu',type=int,default=7);a=p.parse_args();OUT=a.output.resolve();assert not OUT.exists();OUT.mkdir()
sys.path.insert(0,str(ROOT/'benchmarks/parity-features'));import task_runner
spec=importlib.util.spec_from_file_location('tools',ROOT/'benchmarks/parity-features/tool-pins.py');tools=importlib.util.module_from_spec(spec);spec.loader.exec_module(tools)
sha=lambda p:hashlib.sha256(pathlib.Path(p).read_bytes()).hexdigest()
paths=[HERE/'reference.mjs',pathlib.Path(__file__).resolve(),ROOT/'.references/sources.json',ROOT/'scripts/task_runner.py',ROOT/'benchmarks/parity-features/tool-pins.py',ROOT/'scripts/task_runner.py']
PINS={str(p):sha(p) for p in paths};external=lambda:{str(p):sha(p) for p in sorted((ROOT/'.references/bevy-ts/packages/core/src').rglob('*')) if p.is_file()};EXTERNAL=external();INSTALLED=tools.snapshot();INSTALLED['environment']['CPU']=a.cpu
r={'status':'INCOMPLETE','sources':PINS,'external':EXTERNAL,'installedTools':INSTALLED,'commands':[],'artifacts':{},'cpu':a.cpu,'childEnvironmentFixed':{'BEND_NO_TELEMETRY':'1'},'scope':'Actual primary API finite observation, no law/proof/implementation or contract approval'}
def guard():
 assert all(sha(p)==h for p,h in PINS.items());assert external()==EXTERNAL;tools.verify(INSTALLED)
 assert all(sha(OUT/n)==h for n,h in r['artifacts'].items())
def run(label,args):
 guard();q=task_runner.execute_completed(['taskset','-c',str(a.cpu),*map(str,args)],5,dict(os.environ,BEND_NO_TELEMETRY='1'))
 gzip.open(OUT/(label+'.stdout.gz'),'wb').write(q.stdout);(OUT/(label+'.stderr')).write_bytes(q.stderr)
 for suffix in ['.stdout.gz','.stderr']:r['artifacts'][label+suffix]=sha(OUT/(label+suffix))
 r['commands'].append({'label':label,'command':list(map(str,args)),'cap':5,'exit':q.returncode});assert q.returncode==0,(args,q.stderr);guard();return q.stdout
try:
 manifest=json.loads((ROOT/'.references/sources.json').read_text())['sources']
 for name,known in manifest.items():assert run('head-'+name,['git','-C',ROOT/'.references'/name,'rev-parse','HEAD']).decode().strip()==known['commit']
 output=json.loads(run('reference',['node',HERE/'reference.mjs']))
 assert output['applications'][0]['observations']==output['applications'][1]['observations']
 (OUT/'expected.json').write_text(json.dumps(output,indent=2)+'\n');r['artifacts']['expected.json']=sha(OUT/'expected.json')
 guard();r.update(status='ACTUAL_TS_MACHINE_OBSERVATIONS_PASS',checkpointsPerSchema=len(output['applications'][0]['observations']),pendingContractDecision='Marker-created writes targeting a later already-snapshotted machine are deleted; blanket ticket retention wording conflicts with pinned behavior')
finally:(OUT/'receipt.json').write_text(json.dumps(r,indent=2)+'\n')
print(r['status'])
