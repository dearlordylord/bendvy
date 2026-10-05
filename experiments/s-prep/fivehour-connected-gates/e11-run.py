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
    parser.add_argument('--evidence', type=Path, default=HERE / 'e11-evidence.json')
    parser.add_argument('--joined-only', action='store_true')
    parser.add_argument('--resume-mutants', action='store_true', help='Resume only against exact passing original closure')
    parser.add_argument('--prior', type=Path, help='Preserve superseded original failures in replacement evidence')
    args = parser.parse_args()
    overlay = args.overlay.resolve()
    manifest = json.loads((overlay / 'overlay.json').read_text())
    required = {'storage.bend', 'identity.bend', 'commands.bend', 'host.bend',
                'dispatcher.bend', 'query.bend', 'observations.bend', 'host-batch-invoker.bend'}
    assert required.issubset({Path(n).name for n in manifest['overrides']})
    os.sched_setaffinity(0, {9})
    report = {'status': 'INCOMPLETE', 'actualJoinedBendExecuted': False,
              'productionAcceptance': False,
              'limits': {'checkerSeconds': 5, 'runtimeSeconds': 5,
                         'referenceSeconds': 5, 'codegenSeconds': 30,
                         'nativeCompilationSeconds': 120},
              'cpuAffinity': [9], 'adapterSha256': sha(__file__),
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
        # All ten fresh TS lanes run even if the candidate build is blocked.
        for schema in runner.SCHEMAS:
            for lane in runner.LANES:
                try:
                    result = json.loads(runner.B.command(['node', reference, schema, lane]))
                    assert result['status'] == 'PASS'
                    report['publicReference'].append(result)
                except Exception as error:
                    report['failures'].append({'schema': schema, 'lane': lane,
                                               'backend': 'TypeScript', 'error': str(error)[:2000]})
                save()
        try:
            programs = runner.B.build(target / 'host-retention-controls.bend', Path(temporary))
        except Exception as error:
            report['status'] = 'BUILD_BLOCKED'
            report['failures'].append({'backend': 'Build', 'error': str(error)[:2000]})
            save()
            return 2
        for schema_index, schema in enumerate(runner.SCHEMAS):
            for lane_index, lane in enumerate(runner.LANES):
                reference_case = next((r for r in report['publicReference']
                                       if r['schema'] == schema and r['lane'] == lane), None)
                if reference_case is None:
                    continue
                outputs = []
                for backend, program in zip(('Native', 'JavaScript'), programs):
                    started = time.monotonic()
                    try:
                        text = runner.B.execute(program, [str(schema_index), str(lane_index)])
                        result = runner.compare_joined(text, reference_case)
                        result.update(backend=backend, executionSeconds=time.monotonic() - started)
                        report['actual'].append(result)
                        outputs.append(text)
                        report['actualJoinedBendExecuted'] = True
                    except Exception as error:
                        report['failures'].append({'schema': schema, 'lane': lane,
                                                   'backend': backend, 'error': str(error)[:2000]})
                    save()
                if len(outputs) == 2:
                    runner.same(outputs[0], outputs[1], 'exact Native/JS output')
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
