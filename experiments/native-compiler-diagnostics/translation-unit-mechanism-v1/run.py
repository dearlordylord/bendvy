#!/usr/bin/env python3
"""Thin launch adapter over the root's existing runner/log/receipt helpers."""
import hashlib
import fcntl
import importlib.util
import json
from pathlib import Path
import sys
from contextlib import contextmanager

HERE=Path(__file__).resolve().parent
PLAN=HERE/'plan.json'
FREEZE=HERE/'FREEZE.json'
HEAVY_LOCK=Path('/tmp/bendvy-parity-heavy.lock')

def digest(path): return hashlib.sha256(Path(path).read_bytes()).hexdigest()
def load(name,path):
    spec=importlib.util.spec_from_file_location(name,path)
    module=importlib.util.module_from_spec(spec)
    spec.loader.exec_module(module)
    return module

@contextmanager
def internal_heavy_lock():
    lock=HEAVY_LOCK.open('a')
    try:
        fcntl.flock(lock.fileno(),fcntl.LOCK_EX|fcntl.LOCK_NB)
    except BaseException:
        lock.close()
        raise
    try:
        yield
    finally:
        fcntl.flock(lock.fileno(),fcntl.LOCK_UN)
        lock.close()

def execute_plan():
    plan=json.loads(PLAN.read_text()); freeze=json.loads(FREEZE.read_text())
    if digest(PLAN)!=freeze['planSha256']: raise RuntimeError('plan hash differs from frozen binding')
    if plan['sourceFiles']!=freeze['sourceFiles']: raise RuntimeError('source maps differ')
    for name,wanted in freeze['sourceFiles'].items():
        if digest(HERE/name)!=wanted: raise RuntimeError('source pin drift: '+name)
    if str(Path(sys.executable).resolve())!=plan['execution']['python']['resolvedPath'] or digest(sys.executable)!=plan['execution']['python']['sha256']:
        raise RuntimeError('running Python differs from frozen identity')
    for path,wanted in freeze['rootHelpers'].items():
        if digest(path)!=wanted: raise RuntimeError('runner helper pin drift: '+path)
    for pin in plan['execution']['toolPins']:
        if str(Path(pin['path']).resolve())!=pin['resolvedPath'] or digest(pin['resolvedPath'])!=pin['sha256']:
            raise RuntimeError('tool pin drift: '+pin['path'])
    witness=Path(plan['generatedSourceBasis']['path'])
    if digest(witness)!=plan['generatedSourceBasis']['sha256']: raise RuntimeError('generated source witness drift')
    helper_root=Path(plan['execution']['runnerRoot'])
    task_runner=load('bendvy_task_runner',helper_root/'scripts/task_runner.py')
    log_module=load('bendvy_receipt_logs',helper_root/'scripts/receipt-logs.py')
    boundaries=load('bendvy_evidence_boundary',helper_root/'scripts/evidence_boundary.py')
    out_root=HERE/plan['execution']['outputDirectory']
    raw_root=HERE/plan['execution']['rawLogDirectory']
    receipt_path=HERE/plan['execution']['receipt']
    if out_root.exists() or raw_root.exists() or receipt_path.exists(): raise RuntimeError('run01 paths are not fresh')
    out_root.mkdir(parents=True); raw_root.mkdir(parents=True)
    logs=log_module.CommandLogs(raw_root,[s['label'] for s in plan['execution']['commands']])
    fixed_inputs=[HERE/name for name in freeze['inputFiles']]+[FREEZE,witness]
    fixed_inputs.extend(Path(path) for path in freeze['rootHelpers'])
    fixed_inputs.extend(Path(pin['resolvedPath']) for pin in plan['execution']['toolPins'])
    inputs=task_runner.Inputs(files=fixed_inputs)
    outputs={path for step in plan['execution']['commands'] for path in step['produces']}
    oracle_path=HERE/plan['expectedOutput']
    receipt={'status':'INCOMPLETE','planSha256':freeze['planSha256'],'commands':[],'artifactHashes':{},'oracleSha256':digest(oracle_path),'guardFailures':[]}
    expected_artifact_hashes={}
    def output_guard():
        observed={}
        for path in out_root.rglob('*'):
            if path.is_symlink(): raise RuntimeError('output tree contains a symlink')
            if path.is_file():
                relative=str(path.relative_to(HERE))
                if relative not in outputs: raise RuntimeError('unplanned output artifact appeared: '+relative)
                observed[relative]=digest(path)
        if observed!=expected_artifact_hashes: raise RuntimeError('generated output membership or bytes changed')
    checks=[('input-pins',inputs.guard),('raw-logs',logs.guard),('output-membership',output_guard)]
    runner=task_runner.Runner(logs,inputs=inputs,env=plan['execution']['environment'],cwd=HERE,capture='split')
    with boundaries.ReceiptBoundary(receipt,receipt_path,checks):
        for step in plan['execution']['commands']:
            output_guard()
            for relative in step['produces']:
                if (HERE/relative).exists(): raise RuntimeError('planned output is not fresh: '+relative)
            row={'label':step['label'],'argv':step['argv'],'timeoutSeconds':step['timeoutSeconds'],'status':'RUNNING'}
            receipt['commands'].append(row)
            try:
                result=runner.run(step['label'],step['argv'],step['timeoutSeconds'],expected=step['expectedExit'])
            except BaseException as error:
                result=getattr(error,'result',None)
                row.update(status='INCOMPLETE',error=type(error).__name__+': '+str(error))
                if result is not None: row.update(exit=result.get('exit'),failure=result.get('failure'),runnerSha256=result.get('runnerSHA256'))
                raise
            row.update(status='PASS',exit=result['exit'],failure=result['failure'],runnerSha256=result['runnerSHA256'])
            for relative in step['produces']:
                path=HERE/relative
                if not path.is_file() or path.is_symlink(): raise RuntimeError('artifact missing or non-regular: '+relative)
                artifact_hash=digest(path)
                expected_artifact_hashes[relative]=artifact_hash
                receipt['artifactHashes'][relative]=artifact_hash
            output_guard()
            if step['observes']:
                actual_path=raw_root/(step['label']+'.stdout')
                actual=actual_path.read_bytes(); expected=(HERE/step['observes']).read_bytes()
                if actual!=expected: raise RuntimeError('complete output differs from oracle at '+step['label'])
                row.update(outputBytes=len(actual),outputSha256=digest(actual_path),oracleSha256=digest(HERE/step['observes']))
        if set(receipt['artifactHashes'])!=outputs: raise RuntimeError('complete artifact set differs from plan')
        receipt['status']='PASS'
    return 0

def main():
    if sys.argv[1:]!=['--execute-reviewed-plan']:
        raise SystemExit('No command is run unless --execute-reviewed-plan is explicit.')
    with internal_heavy_lock():
        return execute_plan()

if __name__=='__main__': raise SystemExit(main())
