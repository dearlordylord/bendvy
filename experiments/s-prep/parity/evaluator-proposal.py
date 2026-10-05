#!/usr/bin/env python3
"""Dry-run-only evaluator proposal; no subprocess/compiler/benchmark execution.

Execution is unconditionally blocked. A user JSON receipt is not authority.
Canonical Autoresearch accepted state, independently reviewed execution digest,
complete frozen protected manifest and cumulative descendant deadline enforcement
must be implemented/reviewed before a separately authorized execution path.
"""
import argparse
import datetime
import hashlib
import importlib.util
import json
import math
from pathlib import Path
import tempfile

HERE=Path(__file__).resolve().parent
DEADLINE='2026-10-05T01:58:17Z'
_spec=importlib.util.spec_from_file_location('parity_decision',HERE.parent/'parity-decision.py')
D=importlib.util.module_from_spec(_spec);_spec.loader.exec_module(D)


def path_without_links(value, *, directory=True):
    p=Path(value)
    if not p.is_absolute() or '..' in p.parts or p.resolve()!=p or p.is_symlink():raise ValueError('absolute symlink-free nontraversing path required')
    if directory and not p.is_dir():raise ValueError('existing directory required')
    return p


def proposed_metric(cohorts, *, native_factor):
    """Pure numeric assessment only; cannot verify freshness/closure or accept a keep."""
    decision=D.decide(cohorts,native_factor=native_factor)
    qualified=decision['status'] in ('PROPOSED_TARGET_MET','PROPOSED_TARGET_MISSED')
    ratios=[c['raw']['JS']['medianRatio'] for c in decision['cohorts']]
    metric=sum(x/2 for x in ratios) if qualified and len(ratios)==2 else None
    if metric is not None and (not math.isfinite(metric) or metric<=0):metric=None
    return {'qualifiedMetric':metric,'metric':'mean of two same-cohort candidateJS/actualTS median ratios; lower is better','targetMet':decision['qualifiedSuccess'],'decision':decision,'accepted':False,'provenanceVerified':False,'scope':'numeric proposal only; protected provenance/check gates remain external'}


def plan(repo, overlay, artifact_root, *, native_factor):
    if isinstance(native_factor,bool) or not isinstance(native_factor,(int,float)) or not math.isfinite(native_factor) or native_factor<2:raise ValueError('finite native_factor >= user-approved minimum 2 required')
    repo=path_without_links(repo);overlay=path_without_links(overlay);artifacts=path_without_links(artifact_root)
    if artifacts==overlay or artifacts.is_relative_to(overlay) or overlay.is_relative_to(artifacts):raise ValueError('artifact and source roots must be separate')
    focus=repo/'experiments/s-prep/focus-run.py'
    if not focus.is_file():raise ValueError('existing focus runner required')
    commands=[]
    for i in (1,2):
        build=artifacts/f'cohort-{i}'
        if build.exists():raise ValueError('two fresh cohort artifact paths required')
        commands.append(['python3',str(focus),'--overlay',str(overlay),'--build-dir',str(build),'--schema','Health','--workload','dense','--count','256','--repetitions','7','--cpu','8'])
    return {'status':'DRY_RUN_EXECUTION_BLOCKED','accepted':False,'benchmarkExecuted':False,'globalAbsoluteDeadline':DEADLINE,'budgetPolicy':'cumulative two-hour budget includes builds/checks/descendants/recovery; start never reset; stop at earlier budget expiry or absolute deadline','nativeFactor':native_factor,'commandsNotExecuted':commands,'focusRunnerCurrentSha256':hashlib.sha256(focus.read_bytes()).hexdigest(),'artifactRoot':str(artifacts),'metric':'mean of two independent cohort candidateJS/actualTS median ratios, lower is better','cohortProtocol':'two fresh independent seven-rotation cohorts; complete fields/effects, every sample retained; no favorable last sample','decisionImplementationSha256':hashlib.sha256((HERE.parent/'parity-decision.py').read_bytes()).hexdigest(),'blockedOn':['canonical accepted Autoresearch contract state and reviewed execution digest; user JSON cannot substitute','reviewed frozen full manifest: current tools/version/binaries, pinned TS/reference closure, Base, complete candidate/import closure, evaluators/validators, scope proposal and all Main/E11/access/ownership checks','read-only scope audit of exact copied candidate plus reviewed private declarations, bound to same source/import digest used by compilation','before/after unchanged source/tool/reference/check hashes and generated C/JS/native artifact hashes; exact full-field checks bound to these artifacts','independent freshness/provenance of each actual TS and candidate cohort; source/tool pins and raw full-field evidence','cumulative monotonic/absolute deadline supervision of all builds/checks/descendants without resets; existing focus runner alone lacks this boundary'],'limitations':__doc__}


def synthetic():
    def cohorts(js=80,native=30):
        return [{'id':str(i),'evidence':{'status':'FINITE_FULL_FIELD_PASS','repetitions':7,'resolutionLimited':False,'samples':[{'backend':b,'repetition':r,'status':'PASS','milliseconds':x} for b,x in [('JS',js),('Native',native),('TS',100)] for r in range(1,8)]}} for i in range(2)]
    good=proposed_metric(cohorts(),native_factor=2);assert good['qualifiedMetric']==0.8 and good['targetMet']
    missed=proposed_metric(cohorts(js=110),native_factor=2);assert missed['qualifiedMetric']==1.1 and not missed['targetMet']
    broken=cohorts();broken[1]['evidence']['samples'].pop();bad=proposed_metric(broken,native_factor=2);assert bad['qualifiedMetric'] is None
    noisy=cohorts();noisy[1]['evidence']['samples']=[{**s,'milliseconds':s['milliseconds']*1.5} for s in noisy[1]['evidence']['samples']];noise=proposed_metric(noisy,native_factor=2);assert noise['qualifiedMetric'] is None
    with tempfile.TemporaryDirectory(prefix='parity-evaluator-control-') as directory:
        root=Path(directory);overlay=root/'overlay';artifacts=root/'artifacts';overlay.mkdir();artifacts.mkdir();link=root/'link';link.symlink_to(overlay)
        try:path_without_links(link)
        except ValueError:symlink='REJECTED'
        else:raise AssertionError('symlink survived')
    return {'syntheticOnly':True,'benchmarkExecuted':False,'accepted':False,'controls':{'qualified-success':good,'qualified-target-missed':missed,'missing-sample':bad,'noise':noise,'symlink':symlink,'execute':'UNCONDITIONALLY_BLOCKED'},'limitations':__doc__}


if __name__=='__main__':
    p=argparse.ArgumentParser(description=__doc__);p.add_argument('--dry-run',action='store_true');p.add_argument('--execute',action='store_true');p.add_argument('--synthetic',action='store_true');p.add_argument('--repo');p.add_argument('--overlay');p.add_argument('--artifact-root');p.add_argument('--native-factor',type=float);args=p.parse_args()
    if args.execute:p.exit(2,'BLOCKED: no accepted canonical contract/protected boundary; --execute cannot launch anything\n')
    if args.synthetic:
        if args.repo or args.overlay or args.artifact_root or args.native_factor is not None:p.error('synthetic mode is separate')
        (HERE/'evaluator-synthetic-receipt.json').write_text(json.dumps(synthetic(),indent=2,allow_nan=False)+'\n');print('PASS pure evaluator controls; execution blocked')
    else:
        if not args.repo or not args.overlay or not args.artifact_root or args.native_factor is None:p.error('dry-run requires explicit repo/overlay/artifact-root/native-factor')
        try:print(json.dumps(plan(args.repo,args.overlay,args.artifact_root,native_factor=args.native_factor),indent=2))
        except ValueError as exc:p.exit(1,'REJECTED: '+str(exc)+'\n')
