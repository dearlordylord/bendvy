#!/usr/bin/env python3
"""Replay actual indexed E11 originals and semantic mutants under frozen limits."""
import argparse
import hashlib
import importlib.util
import json
import os
import re
import subprocess
from pathlib import Path
import shutil
import tempfile
import time

HERE = Path(__file__).resolve().parent
ROOT = HERE.parents[2]
BASE = ROOT / 'experiments/s-integrate'


def sha(path):
    return hashlib.sha256(Path(path).read_bytes()).hexdigest()


def load(path):
    spec = importlib.util.spec_from_file_location('indexed_e11_comparison', path)
    result = importlib.util.module_from_spec(spec)
    spec.loader.exec_module(result)
    return result


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('overlay', type=Path)
    parser.add_argument('--cpu',type=int,default=9)
    parser.add_argument('--evidence', type=Path, default=HERE / 'e11-evidence.json')
    parser.add_argument('--reuse-ts-oracle',type=Path,help='Exact unchanged reference outputs from this task; never a fresh TS claim')
    parser.add_argument('--reuse-ts-oracle-sha256')
    parser.add_argument('--joined-only', action='store_true')
    parser.add_argument('--resume-mutants', action='store_true', help='Resume only against exact passing original closure')
    parser.add_argument('--prior', type=Path, help='Preserve superseded original failures in replacement evidence')
    args = parser.parse_args()
    overlay = args.overlay.resolve()
    manifest = json.loads((overlay / 'overlay.json').read_text())
    required = {'storage.bend', 'identity.bend', 'commands.bend', 'host.bend',
                'dispatcher.bend', 'query.bend', 'observations.bend', 'host-batch-invoker.bend'}
    assert required.issubset({Path(n).name for n in manifest['overrides']})
    os.sched_setaffinity(0, {args.cpu})
    report = {'status': 'INCOMPLETE', 'actualJoinedBendExecuted': False,
              'productionAcceptance': False,
              'limits': {'checkerSeconds': 5, 'runtimeSeconds': 5,
                         'referenceSeconds': 5, 'codegenSeconds': 30,
                         'nativeCompilationSeconds': 120},
              'cpuAffinity': [args.cpu], 'adapterSha256': sha(__file__),
              'inputOverlay': str(overlay), 'overlayManifestSha256': sha(overlay / 'overlay.json'),
              'overlayBaseline': manifest['baseline'], 'publicReference': [],
              'actual': [], 'failures': [], 'semanticMutants': {'status': 'PENDING'}}
    if args.prior:
        prior = json.loads(args.prior.read_text())
        report['supersededOriginalRuns'] = prior.get('supersededOriginalRuns', []) + [{'evidenceSha256': sha(args.prior), 'status': prior['status'], 'adapterSha256': prior['adapterSha256'], 'sourceClosure': prior['sourceClosure'], 'publicReferenceCount': len(prior['publicReference']), 'passingBackendCases': prior['actual'], 'failures': prior['failures'], 'limitScope': prior['limits']}]
    with tempfile.TemporaryDirectory(prefix='indexed-e11-') as temporary:
        scratch = Path(temporary) / 'overlay'
        shutil.copytree(overlay, scratch)
        target = scratch / 'experiments/s-integrate'
        for name in ('host-retention-run.py', 'trace-compare.py', 'trace-decode.py'):
            shutil.copy2(BASE / name, target / name)
        reference = scratch / 'experiments/s-integrate-trace/reference-retention.mjs'
        reference.parent.mkdir(parents=True, exist_ok=True)
        shutil.copy2(ROOT / 'experiments/s-integrate-trace/reference-retention.mjs', reference)
        # Reuse the unchanged comparator/mutant definitions, never their baseline execution.
        runner = load(BASE / 'host-retention-run.py')
        runner.HERE = target
        runner.B.CHECK = ROOT / 'experiments/t01/bend-check'
        baseline_fixture = subprocess.check_output(['git','show','a976667:experiments/s-integrate/storage-stage-fixture.bend'],cwd=ROOT,text=True)
        def definitions(text):
            return {m.group(1):m.group(0).rstrip() for m in re.finditer(r'^def ([\w.]+)\([^\n]*(?:\n(?!def |type |import )[^\n]*)*',text,re.M)}
        original_definitions = definitions(baseline_fixture)
        retained_definitions = definitions((target/'storage-stage-fixture.bend').read_text())
        assert retained_definitions
        import importlib.util
        mapping_spec=importlib.util.spec_from_file_location('control_mapping',HERE/'materialize-controls.py');mapping=importlib.util.module_from_spec(mapping_spec);mapping_spec.loader.exec_module(mapping);specialize=mapping.specialize
        assert all(body in (original_definitions[n],specialize(original_definitions[n])) for n,body in retained_definitions.items()),'Seed/formatting helper differs from exact mechanical cached Type/constructor mapping'
        report['prunedFixture']={'scope':'Used seed constructors and Data formatters; unrelated old list-world fixtures excluded','retainedDefinitionSha256':{n:hashlib.sha256(body.encode()).hexdigest() for n,body in retained_definitions.items()},'allRetainedDefinitionsByteIdenticalToBaseline':False,'exactOriginalOrCachedTypeConstructorMapping':True}
        report.update(sourceClosure=runner.source_closure(),
                      referenceSha256=sha(reference), runnerSha256=sha(target / 'host-retention-run.py'),
                      comparisonSha256=runner.comparison_fingerprint(),
                      compactDecoderControls=runner.compact_controls(),
                      versions={'bend': runner.B.command(['bend', 'version']),
                                'node': runner.B.command(['node', '--version'])})
        tools = {'compiler': Path(shutil.which('bend')).resolve(),
                 'Base': Path.home() / '.bend/bend2/base.bend',
                 'buildHelper': ROOT / 'experiments/t05/run.py',
                 'checkerWrapper': runner.B.CHECK}
        report['toolchain'] = {n: {'path': str(p), 'sha256': sha(p)} for n, p in tools.items()}
        # Every semantic mutant's authoritative input is Motion and one lane.
        # Remove only unreachable control scaffolding; keep runtime modules whole.
        original_build = runner.B.build
        def mutation_build(source, folder):
            cases = {n: lane for n, _file, _old, _new, _count, lane in runner.mutation_cases()}
            name = Path(folder).name
            if name in cases and name in {case[0] for case in runner.mutation_cases()[5:]}:
                lane = cases[name]
                constructors = dict(zip(runner.LANES, ('RetMessage','RetRemoved','RetDespawned','RetUnheld','RetMarks')))
                text = source.read_text()
                main_start = text.index('def main() -> IO(Unit):')
                source.write_text(text[:main_start] + 'def main() -> IO(Unit):\n  motion(' + constructors[lane] + '{})\n')
                runtime = set()
                core = source.parent
                def visit(path):
                    relative = str(path.relative_to(target.parent.parent))
                    if relative in runtime: return
                    runtime.add(relative)
                    for imported in re.findall(r'^import (\./\S+\.bend)',path.read_text(),re.M):
                        visit((path.parent/imported).resolve())
                visit(target/'measurement-bend.bend')
                mapping.slice_control_imports(core, source, runtime)
            return original_build(source, folder)
        runner.B.build = mutation_build
        evidence = target / 'host-retention-evidence.json'

        def save():
            evidence.write_text(json.dumps(report, indent=2) + '\n')
            args.evidence.write_text(evidence.read_text())

        if args.resume_mutants:
            prior = json.loads(args.evidence.read_text())
            assert len(prior['actual']) == 20 and len(prior['publicReference']) == 10
            assert all(f['backend'] == 'Mutation' for f in prior['failures'])
            assert prior['sourceClosure'] == report['sourceClosure']
            assert prior['referenceSha256'] == report['referenceSha256']
            assert prior['comparisonSha256'] == report['comparisonSha256']
            report = prior
            report.setdefault('supersededMutationFailures', []).extend(report['failures'])
            report['failures'] = []
            report['status'] = 'JOINED_EXECUTION_PASS_MUTANTS_PENDING'
            report['mutationAdapterSha256'] = sha(__file__)
            original_command = runner.B.command
            def instrumented_command(command, expected=0, timeout=5):
                if "--check-only" in list(map(str,command)):timeout=int(os.environ.get("BENDVY_CHECKER_SECONDS","5"))
                started = time.monotonic()
                phase = {'command':[str(a) for a in command], 'limitSeconds':timeout}
                try:
                    output = original_command(command, expected, timeout)
                    phase['status'] = 'PASS'
                    return output
                except Exception as error:
                    phase.update(status='FAILED',error=str(error)[:3000])
                    raise
                finally:
                    phase['seconds'] = time.monotonic()-started
                    report.setdefault('resumedCommandPhases', []).append(phase)
                    # The original mutation executor owns its current evidence writes.
            runner.B.command = instrumented_command
            save()
            try:
                result = runner.mutants()
                current = json.loads(evidence.read_text())
                current['resumedCommandPhases'] = report.get('resumedCommandPhases', [])
                evidence.write_text(json.dumps(current,indent=2)+'\n')
                return result
            except Exception as error:
                current = json.loads(evidence.read_text())
                current.update(status='MUTATION_BLOCKED',resumedCommandPhases=report.get('resumedCommandPhases', []))
                current['failures'].append({'backend':'Mutation','error':str(error)[:3000]})
                evidence.write_text(json.dumps(current,indent=2)+'\n')
                return 2
            finally:
                args.evidence.write_text(evidence.read_text())
        save()
        # Reference behavior is independent of the Bend provider variant.
        oracle_binding=None
        def bind_oracle():
            root=Path('/workspace/formal-proofs/bendvy/.references/bevy-ts');head=subprocess.check_output(['git','rev-parse','HEAD'],cwd=root,text=True).strip();names=subprocess.check_output(['git','ls-files','packages/core/src'],cwd=root,text=True).splitlines();sources={n:sha(root/n) for n in names}
            assert head=='3040a3b2a3f28fa8554d856f9ccb6bf5433fa334'
            assert all(hashlib.sha256(subprocess.check_output(['git','show','HEAD:'+n],cwd=root)).hexdigest()==v for n,v in sources.items())
            node=Path(shutil.which('node')).resolve()
            return {'referenceHEAD':head,'referenceCoreSources':sources,'adapterSHA256':sha(reference),'Node':{'path':str(node),'sha256':sha(node),'version':runner.B.command(['node','--version'])},'environment':{n:os.environ.get(n) for n in ('NODE_OPTIONS','HOME','PATH','LD_PRELOAD','LD_LIBRARY_PATH')}}
        if args.reuse_ts_oracle:
            assert args.reuse_ts_oracle_sha256 and sha(args.reuse_ts_oracle)==args.reuse_ts_oracle_sha256,'Reviewed oracle receipt digest differs'
            prior=json.loads(args.reuse_ts_oracle.read_text());assert prior['status']=='BOUNDED_JOINED_PASS' and not prior['failures']
            assert prior['referenceSha256']==sha(reference) and prior['comparisonSha256']==runner.comparison_fingerprint()
            oracle_binding=bind_oracle();assert prior['versions']['node']==oracle_binding['Node']['version']
            reference_cases=prior['publicReference'];assert len(reference_cases)==10 and {(r['schema'],r['lane']) for r in reference_cases}=={(schema,lane) for schema in runner.SCHEMAS for lane in runner.LANES};assert all(r['status']=='PASS' and r['capacity']==65536 and r['publicOnly'] for r in reference_cases)
            report['publicReference']=reference_cases;report['referenceReplay']={'status':'EXACT_UNCHANGED_THIS_TASK_TS_ORACLE_REUSED','freshTypeScriptExecution':False,'sourceReceiptSHA256':sha(args.reuse_ts_oracle),'outputSHA256':hashlib.sha256(json.dumps(reference_cases,sort_keys=True,separators=(',',':')).encode()).hexdigest(),'dependencyBindingBefore':oracle_binding,'historicalNodeVersion':prior['versions']['node'],'historicalNodeBinaryPinRecordedInPrior':False,'scope':'Prior observed complete TypeScript outputs; current adapter/reference/Node bytes guarded before and after; no timing or historical binary-hash claim'};save()
        else:
            assert not args.reuse_ts_oracle_sha256
            for schema in runner.SCHEMAS:
                for lane in runner.LANES:
                    try:
                        result=json.loads(runner.B.command(['node',reference,schema,lane]));assert result['status']=='PASS';report['publicReference'].append(result)
                    except Exception as error:report['failures'].append({'schema':schema,'lane':lane,'backend':'TypeScript','error':str(error)[:2000]})
                    save()
        split_subjects=sha(target/'uncached-payload.bend')!=sha(target/'payload.bend')
        programs=None
        if not split_subjects:
            try:programs=runner.B.build(target/'host-retention-controls.bend',Path(temporary))
            except Exception as error:report['status']='BUILD_BLOCKED';report['failures'].append({'backend':'Build','error':str(error)[:2000]});save();return 2
        for schema_index,schema in enumerate(runner.SCHEMAS):
            for lane_index,lane in enumerate(runner.LANES):
                if split_subjects:
                    folder=Path(temporary)/('subject-'+schema+'-'+lane);core=folder/'experiments/s-integrate';shutil.copytree(target,core);source=core/'host-retention-controls.bend';text=source.read_text();start=text.index('def main() -> IO(Unit):');constructors=dict(zip(runner.LANES,('RetMessage','RetRemoved','RetDespawned','RetUnheld','RetMarks')));source.write_text(text[:start]+'def main() -> IO(Unit):\n  '+schema.lower()+'('+constructors[lane]+'{})\n')
                    runtime=set()
                    def visit(path):
                        name=str(path.relative_to(target.parent.parent))
                        if name in runtime:return
                        runtime.add(name)
                        for imported in re.findall(r'^import (\./\S+\.bend)',path.read_text(),re.M):visit((path.parent/imported).resolve())
                    visit(target/'measurement-bend.bend');slices=mapping.slice_control_imports(core,source,runtime);report.setdefault('originalSubjectControlSlices',{})[schema+'/'+lane]=slices;save()
                    try:programs=original_build(source,folder)
                    except Exception as error:report['status']='BUILD_BLOCKED';report['failures'].append({'backend':'Build','schema':schema,'lane':lane,'error':str(error)[:2000]});save();return 2
                reference_case=next((r for r in report['publicReference'] if r['schema']==schema and r['lane']==lane),None)
                if reference_case is None:continue
                outputs=[]
                for backend,program in zip(('Native','JavaScript'),programs):
                    started=time.monotonic()
                    try:
                        text=runner.B.execute(program,[str(schema_index),str(lane_index)]);result=runner.compare_joined(text,reference_case);result.update(backend=backend,executionSeconds=time.monotonic()-started);report['actual'].append(result);outputs.append(text);report['actualJoinedBendExecuted']=True
                    except Exception as error:report['failures'].append({'schema':schema,'lane':lane,'backend':backend,'error':str(error)[:2000]})
                    save()
                if len(outputs)==2:runner.same(outputs[0],outputs[1],'exact Native/JS output')
        if oracle_binding is not None:
            assert bind_oracle()==oracle_binding and sha(args.reuse_ts_oracle)==args.reuse_ts_oracle_sha256,'Reused oracle dependencies drifted';report['referenceReplay']['dependencyBindingAfter']=oracle_binding;save()
        runner.same(runner.source_closure(), report['sourceClosure'], 'unchanged candidate closure')
        if len(report['publicReference']) == 10:
            runner.project(report['publicReference'])
            report['oraclePerturbations'] = runner.perturbations(report['publicReference'])
        if not report['failures'] and len(report['actual']) == 20:
            report['status'] = 'JOINED_EXECUTION_PASS_MUTANTS_PENDING'
        save()
        if report['status'] != 'JOINED_EXECUTION_PASS_MUTANTS_PENDING':
            report['status'] = 'ORIGINAL_CAPABILITY_FAILED'
            report['semanticMutants'] = {'status':'BLOCKED','reason':'All ten original lanes must pass on both actual backends before semantic mutation acceptance','returnCondition':'Repair the recorded actual backend failures; replay unchanged ten fresh TS lanes and all twenty candidate backend cases'}
            save()
            return 2
        if args.joined_only:
            return 0
        try:
            return runner.mutants()
        except Exception as error:
            report = json.loads(evidence.read_text())
            report['status'] = 'MUTATION_BLOCKED'
            report['failures'].append({'backend': 'Mutation', 'error': str(error)[:2000]})
            save()
            return 2
        finally:
            args.evidence.write_text(evidence.read_text())


if __name__ == '__main__':
    raise SystemExit(main())
