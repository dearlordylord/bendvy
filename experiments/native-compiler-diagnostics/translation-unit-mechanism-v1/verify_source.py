#!/usr/bin/env python3
"""Static ABI/provenance/oracle checks only; never compiles or runs C."""
import hashlib
import json
from pathlib import Path
import re

HERE=Path(__file__).resolve().parent
PLAN=json.loads((HERE/'plan.json').read_text())
FREEZE=json.loads((HERE/'FREEZE.json').read_text())

def sha(path): return hashlib.sha256(Path(path).read_bytes()).hexdigest()
def require(ok, message):
    if not ok: raise SystemExit(message)

source=Path(PLAN['generatedSourceBasis']['path'])
require(sha(source)==PLAN['generatedSourceBasis']['sha256'],'retained generated C source hash drift')
source_lines=source.read_text().splitlines()
excerpt='\n'.join(f"{n}: {source_lines[n-1]}" for n in PLAN['generatedSourceBasis']['excerptLines'])+'\n'
require((HERE/'generated-abi-excerpt.txt').read_text()==excerpt,'generated ABI excerpt differs from pinned source')
header=(HERE/'tu-abi.h').read_text()
for n in ('WL_SIG','WL_ALL'):
    line_number=10251 if n=='WL_SIG' else 10253
    wanted=source_lines[line_number-1]
    require(wanted in header,f'{n} differs from retained generated source')
require(source_lines[126641-1] in header,'WlFn calling convention differs from retained generated source')
parameter_text=source_lines[10251-1].split(' ',2)[2]
parameters=[p.strip() for p in parameter_text.split(',')]
require(len(parameters)==46,f'expected exact 46-argument signature, found {len(parameters)}')
arg_text=source_lines[10253-1].split(' ',2)[2]
args=[a.strip() for a in arg_text.split(',')]
names=[]
for parameter in parameters:
    match=re.search(r'([A-Za-z_][A-Za-z_0-9]*)\s*$',parameter)
    require(match is not None,'cannot parse generated signature parameter')
    names.append(match.group(1))
require(args==names,'WL_ALL order does not exactly match WL_SIG')
require(source_lines[123-1] in header and source_lines[124-1] in header,'musttail direct/indirect forms differ')
require('visibility("hidden")' in header,'cross-TU linkage is not hidden')

worker_a=(HERE/'worker_a.c').read_text(); worker_b=(HERE/'worker_b.c').read_text(); owner=(HERE/'runtime_owner.c').read_text()
require(worker_a.count('WL_JMP(FID_MID)')==1,'missing direct cross-TU musttail edge')
require(worker_b.count('WL_DYN(FID_DONE)')==1,'missing indirect table musttail edge')
for fid,body in [('FID_START',worker_a),('FID_MID',worker_b),('FID_DONE',owner)]:
    require(len(re.findall(r'^WL_FN WL_'+fid+r'\(WL_SIG\)',body,re.M))==1,f'{fid} definition count is not one')
require(len(re.findall(r'^struct RuntimeState runtime_state\s*=',owner,re.M))==1,'runtime state must have one owner')
require(len(re.findall(r'^const WlFn wl_tab\[FID_COUNT\].*=\s*\{',owner,re.M))==1,'dispatch table must have one owner')
for fid in ('FID_START','FID_MID','FID_DONE'):
    require(len(re.findall(r'^\s*\['+fid+r'\]\s*=\s*WL_'+fid+r',',owner,re.M))==1,f'{fid} must occur once in the owned table')
monolithic=(HERE/'monolithic.c').read_text()
for source_name in ('worker_a.c','worker_b.c','runtime_owner.c'):
    require(monolithic.count(f'#include "{source_name}"')==1,f'{source_name} must be included once in the monolithic counterpart')

oracle=json.loads((HERE/'ORACLE.json').read_text())
initial=oracle['input']; steps=oracle['steps']
r0=initial['r0']; rp=initial['rp']; r40=initial['r40']; heap=initial['heap0']; transitions=0
transitions+=steps[0]['transitionsDelta']; heap+=steps[0]['heap0Delta']; r0+=steps[0]['r0Delta']; rp+=steps[0]['rpDelta']
transitions+=steps[1]['transitionsDelta']; heap+=steps[1]['heap0Delta']; r0*=steps[1]['r0Multiply']; r40+=steps[1]['r40Delta']
transitions+=steps[2]['transitionsDelta']; result=r0+rp+r40+heap
computed={'r0':r0,'rp':rp,'r40':r40,'heap0':heap,'transitions':transitions,'result':result}
require(computed==oracle['derived'],f'independent oracle arithmetic differs: {computed}')
output=f"result={result} state={transitions} mem={heap}\n".encode()
expected=(HERE/'expected.stdout').read_bytes()
require(output==expected,'expected stdout differs from independent source arithmetic')
require(sha(HERE/'expected.stdout')==oracle['expectedStdoutSha256'],'oracle output hash mismatch')
require(PLAN['abi']['argumentCount']==46 and PLAN['generatedSourceBasis']['sha256']==sha(source),'plan/source ABI binding mismatch')
require(len(PLAN['execution']['commands'])==8,'plan command sequence is not the reviewed eight-step split/mono sequence')
require(all(s['timeoutSeconds']==5 for s in PLAN['execution']['commands']),'command cap differs from 5 seconds')
require(PLAN['execution']['outputDirectory']=='out','plan output root mismatch')
require(PLAN['execution']['internalHeavyLock']=={'mode':'exclusive-nonblocking','path':'/tmp/bendvy-parity-heavy.lock','scope':'all eight commands, output freshness and guards, and terminal receipt'},'internal heavy-lock binding mismatch')
runner_source=(HERE/'run.py').read_text()
require("HEAVY_LOCK=Path('/tmp/bendvy-parity-heavy.lock')" in runner_source and 'fcntl.LOCK_EX|fcntl.LOCK_NB' in runner_source,'runner does not acquire the exact internal heavy lock')
for name,wanted in PLAN['sourceFiles'].items():
    require(sha(HERE/name)==wanted,f'leaf source pin mismatch: {name}')
require(PLAN['sourceFiles']==FREEZE['sourceFiles'],'plan and freeze source maps differ')
require(sha(HERE/'plan.json')==FREEZE['planSha256'],'plan/freeze hash mismatch')
for path,wanted in FREEZE['rootHelpers'].items():
    require(sha(path)==wanted,f'root helper pin drift: {path}')
for pin in PLAN['execution']['toolPins']:
    require(str(Path(pin['path']).resolve())==pin['resolvedPath'],'tool resolved path drift')
    require(sha(pin['resolvedPath'])==pin['sha256'],f'tool pin drift: {pin["path"]}')
require(PLAN['status'].startswith('PREPARED_NOT_EXECUTED'),'plan no longer says not executed')
print('source-only ABI/oracle/plan checks PASS; no compiler or runtime invoked')
