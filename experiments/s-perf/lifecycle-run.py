#!/usr/bin/env python3
"""Indexed Lifecycle: full-field validation before rotated timing and clean RSS."""
import argparse
import datetime
import hashlib
import importlib.util
import json
import os
from pathlib import Path
import shutil
import sys

ROOT = Path(__file__).resolve().parents[2]
BASE = ROOT / 'experiments/s-integrate'

def module(name, path):
    spec = importlib.util.spec_from_file_location(name, path)
    result = importlib.util.module_from_spec(spec)
    spec.loader.exec_module(result)
    return result

def sha(path):
    return hashlib.sha256(path.read_bytes()).hexdigest()

def stamp():
    return datetime.datetime.now(datetime.timezone.utc).isoformat()

def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('--overlay', required=True, type=Path)
    parser.add_argument('--build-dir', required=True, type=Path)
    parser.add_argument('--protocol', type=Path, default=ROOT/'experiments/s-perf/measure-run.py')
    parser.add_argument('--cpu', type=int, default=10)
    args = parser.parse_args()
    os.sched_setaffinity(0, {args.cpu})
    args.build_dir.mkdir(parents=True, exist_ok=False)
    P = module('indexed_measurement_protocol', args.protocol)
    V = module('indexed_lifecycle_validator', BASE/'measurement-lifecycle-timed-run.py')
    B = V.B
    manifest = json.loads((args.overlay/'overlay.json').read_text())
    reference = BASE/'measurement-lifecycle-timing-reference.mjs'
    original_reference = BASE/'measurement-reference.mjs'
    evidence = {
        'status':'INCOMPLETE', 'startedAt':stamp(), 'overlay':manifest,
        'workload':'Lifecycle', 'iterations':64, 'repetitions':7,
        'initialLiveCounts':[64,256,1024], 'schemas':['Motion','Health'],
        'warmupWorlds':1, 'measuredWorlds':1, 'cpuAffinity':[args.cpu],
        'limitsSeconds':{'checker':5,'runtime':5,'codegen':30,'clang':120},
        'isolation':'affinity only; machine is not exclusively reserved',
        'clock':'Bend IO.now integer ms; TS performance.now; inner interval',
        'authoredWork':'Select+Reserve,Observe,Deferred,Observe,Dispose+Deferred,Observe; ascending query, Ledger, current/foreign lookups and every historical stale lookup',
        'fullValidation':'192 authored boundaries, 6112 historical stale lookups, 64 actual reservations, all component fields and final owner/capture/clock observations',
        'approvedDifference':'foreign TS numeric-ID collision remains observable; Bend returns MissingEntity',
        'rssScope':'whole child process, including setup/warmup/final serialization; small C exec-reset launcher wait4(actual child), Linux KiB',
        'occupancy':{'status':'UNAVAILABLE','reason':'this timing adapter does not instrument actual physical logs/holders, staged/pending peaks or registered reader positions; final empty pending is not a peak or physical-retention measurement'},
        'runnerSHA256':sha(Path(__file__)), 'protocolSHA256':sha(args.protocol),
        'validatorSHA256':sha(Path(V.__file__)), 'referenceSHA256':sha(reference),
        'originalReferenceSHA256':sha(original_reference),
        'contractSHA256':sha(BASE/'measurement-lifecycle-timing-plan.md'),
        'buildHelperSHA256':sha(ROOT/'experiments/t05/run.py'),
        'checkerWrapperSHA256':sha(ROOT/'experiments/t01/bend-check'),
        'baseSHA256':sha(Path.home()/'.bend/bend2/base.bend'),
        'compilerSHA256':sha(Path(shutil.which('bend')).resolve()),
        'compiler':B.command(['bend','version']).strip(),
        'node':B.command(['node','--version']).strip(),
        'clang':B.command(['clang','--version']).splitlines()[0],
        'cases':[{'schema':schema,'count':count,'status':'NOT_RUN',
                  'verification':{},'samples':{'Native':[],'TS':[],'JS':[]}}
                 for schema in ('Motion','Health') for count in (64,256,1024)]}

    def save():
        (args.build_dir/'evidence.json').write_text(json.dumps(evidence,indent=2)+'\n')

    save()
    try:
        assert all(sha(args.overlay/p)==value for p,value in manifest['sources'].items()), 'overlay source hash mismatch'
        launcher_source = BASE/'measurement-samples-rss-launcher.c'
        launcher = args.build_dir/'rss-launcher'
        B.command(['clang','-O2',launcher_source,'-o',launcher],timeout=120)
        evidence['launcherSourceSHA256'] = sha(launcher_source)
        evidence['launcherSHA256'] = sha(launcher)
        entry = args.overlay/'experiments/s-integrate/measurement-lifecycle-timed.bend'
        evidence['build']={'status':'IN_PROGRESS','entry':str(entry),'startedAt':stamp()}
        save()
        try:
            programs = B.build(entry,args.build_dir)
        except (RuntimeError,AssertionError) as error:
            evidence['build'].update(status='FAIL',error=str(error),finishedAt=stamp())
            for case in evidence['cases']:
                case.update(status='BUILD_BLOCKED',reason='candidate timed Lifecycle entry failed its unchanged bounded build/check gate')
            raise
        evidence['build'].update(status='PASS',finishedAt=stamp(),artifacts={p.name:sha(p) for p in programs})
        save()
        for case in evidence['cases']:
            schema,count = case['schema'],case['count']
            number = 0 if schema=='Motion' else 1
            command = ['node',original_reference,schema,'lifecycle',str(count)]
            case['referenceCommand'] = list(map(str,command))
            try:
                legacy_text = B.command(command)
                legacy = json.loads(legacy_text)
                reference_file = args.build_dir/f'{schema}-{count}-authoritative.json'
                reference_file.write_text(legacy_text)
                case['reference']={'status':'PASS','sha256':sha(reference_file)}
            except (RuntimeError,json.JSONDecodeError) as error:
                case.update(status='REFERENCE_FAILED',reference={'status':'FAIL','error':str(error)})
                save()
                continue

            def command_for(backend,full):
                if backend=='TS':
                    return ['node',reference,schema,str(count),str(int(full))]
                if backend=='JS':
                    return ['node',programs[1],str(number),str(count),str(int(full))]
                return [programs[0],str(number),str(count),str(int(full)),'--threads','1','--gpu','off']

            def attempt(backend,full,label):
                folder = args.build_dir/'raw'/f'{schema}-{count}'/label/backend
                folder.mkdir(parents=True,exist_ok=False)
                command = command_for(backend,full)
                meta,text = P.child(command,folder,launcher)
                meta.update(command=list(map(str,command)),rawPath=str(folder.relative_to(args.build_dir)))
                if text is not None:
                    try:
                        meta.update(V.validate(text,schema,count,backend,full,legacy))
                        meta['stdoutSHA256'] = sha(folder/'child-output.txt')
                    except (AssertionError,TypeError,ValueError,KeyError) as error:
                        meta.update(status='FAIL',error='complete semantic validation: '+str(error))
                (folder/'attempt.json').write_text(json.dumps(meta,indent=2)+'\n')
                return meta

            for backend in ('Native','TS','JS'):
                case['verification'][backend] = attempt(backend,True,'full')
                save()
            if not all(v['status']=='PASS' for v in case['verification'].values()):
                case.update(status='PREREQUISITE_FAILED',reason='all three complete semantic gates must pass before timing')
                save()
                print(schema,count,case['status'],flush=True)
                continue
            for repetition in range(7):
                order = ['Native','TS','JS']
                offset = repetition%3
                order = order[offset:]+order[:offset]
                for backend in order:
                    sample = attempt(backend,False,f'sample-{repetition+1}')
                    sample.update(repetition=repetition+1,backendOrder=order)
                    case['samples'][backend].append(sample)
                    save()
            complete = all(len(samples)==7 and all(s['status']=='PASS' for s in samples)
                           for samples in case['samples'].values())
            case['status'] = 'MEASURED' if complete else 'REPETITION_FAILED'
            case['summary'] = {}
            for backend,samples in case['samples'].items():
                if len(samples)==7 and all(s['status']=='PASS' for s in samples):
                    case['summary'][backend] = {
                        'milliseconds':P.stats([s['milliseconds'] for s in samples]),
                        'peakRssKiB':P.stats([s['peakRssKiB'] for s in samples])}
            if complete:
                medians = {b:s['milliseconds']['median'] for b,s in case['summary'].items()}
                case['ratios'] = {b+'/TS':medians[b]/medians['TS'] for b in ('Native','JS')}
                case['resolutionLimited'] = any(s['milliseconds']<10 for s in case['samples']['Native'])
                case['acceptance'] = 'descriptive only; no numerical performance thresholds approved'
            save()
            print(schema,count,case['status'],case.get('ratios'),flush=True)
        assert all(sha(args.overlay/p)==value for p,value in manifest['sources'].items()), 'overlay drift'
        evidence['status'] = 'MEASURED' if all(c['status']=='MEASURED' for c in evidence['cases']) else 'PARTIAL'
    except Exception as error:
        evidence.update(status='FAIL',error=str(error))
    evidence['finishedAt'] = stamp()
    save()
    print(evidence['status'],evidence.get('error'),flush=True)
    return int(evidence['status']=='FAIL')

if __name__=='__main__':
    sys.exit(main())
