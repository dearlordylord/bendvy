#!/usr/bin/env python3
"""Finite indexed command controls; no production or universal proof claim."""
import argparse, hashlib, json, os, shutil, signal, subprocess, tempfile
from pathlib import Path
ROOT = Path(__file__).resolve().parents[2]

def run(command, limit, output=None):
    process = subprocess.Popen(command, stdout=subprocess.PIPE, stderr=subprocess.PIPE,
                               start_new_session=True)
    try:
        stdout, stderr = process.communicate(timeout=limit)
    except subprocess.TimeoutExpired:
        os.killpg(process.pid, signal.SIGKILL)
        stdout, stderr = process.communicate()
        raise RuntimeError(f"DEADLINE {limit}s: {command!r}\n{stderr.decode()}")
    if process.returncode:
        raise RuntimeError(f"EXIT {process.returncode}: {command!r}\n{stderr.decode()}\n{stdout.decode()}")
    if output is not None:
        output.write_bytes(stdout)
    return stdout

def main():
    parser = argparse.ArgumentParser()
    parser.add_argument('--storage', type=Path, default=ROOT/'experiments/s-perf/candidate/storage.bend')
    parser.add_argument('--identity', type=Path, default=ROOT/'experiments/s-perf/candidate/identity.bend')
    parser.add_argument('--output', type=Path, required=True)
    parser.add_argument('--cpu', default='10')
    args = parser.parse_args()
    args.output.mkdir(parents=True, exist_ok=True)
    sources = {'storage.bend': args.storage, 'identity.bend': args.identity,
               'types.bend': ROOT/'experiments/s-integrate/types.bend',
               'commands.bend': ROOT/'experiments/s-perf/candidate/commands.bend'}
    fixture = ROOT/'experiments/s-perf/command-controls.bend'
    prefix = ['taskset', '-c', args.cpu]
    evidence = {'claim': 'finite owned command controls only', 'sources': {}, 'cases': []}
    with tempfile.TemporaryDirectory(prefix='bendvy-command-controls-') as work:
        work = Path(work)
        for name, source in sources.items():
            shutil.copyfile(source, work/name)
            evidence['sources'][name] = hashlib.sha256(source.read_bytes()).hexdigest()
        control = fixture.read_text().replace('./candidate/', './')
        evidence['sources']['control.bend'] = hashlib.sha256(fixture.read_bytes()).hexdigest()
        expected = None
        variants = [('original', None, None),
                    ('fifo-reversed', 'List.reverse(&1,S.Command<M,A,F>,pending),namespace,tick,Running{rows,[]}', 'pending,namespace,tick,Running{rows,[]}'),
                    ('lost-main-changed', '[S.MainChanged{S.Handle{namespace,id}}]', '[]'),
                    ('skip-despawn', 'RowEdit{None{},[S.MainRemoved{S.Handle{namespace,id}},S.Despawned{S.Handle{namespace,id}}]}', 'RowEdit{Some{S.Row{id,None{},None{},None{},0,0}},[]}')]
        original = sources['commands.bend'].read_text()
        for name, before, after in variants:
            source = original
            if before:
                if source.count(before) != 1:
                    raise RuntimeError(f'mutation match count for {name}: {source.count(before)}')
                source = source.replace(before, after)
            (work/'commands.bend').write_text(source)
            (work/'control.bend').write_text(control)
            run(prefix+[str(ROOT/'experiments/t01/bend-check'),str(work/'control.bend'),'--check-only'], 5)
            run(prefix+['bend',str(work/'control.bend'),'-o',str(work/'control.c')],30)
            run(prefix+['clang','-O3',str(work/'control.c'),'-lm','-lpthread','-o',str(work/'native')],120)
            run(prefix+['bend',str(work/'control.bend'),'-o',str(work/'control.js')],30)
            native = run(prefix+[str(work/'native'),'--threads','1','--gpu','off'],5,args.output/(name+'-native.txt'))
            js = run(prefix+['node',str(work/'control.js')],5,args.output/(name+'-js.txt'))
            if native != js:
                raise RuntimeError(f'backend disagreement: {name}')
            if name == 'original':
                expected = (ROOT/'experiments/s-perf/command-controls-expected.txt').read_bytes()
                if native != expected:
                    raise RuntimeError('original disagrees with exact full-field fixture expectations')
            elif native == expected:
                raise RuntimeError(f'surviving compiling mutant: {name}')
            evidence['cases'].append({'name':name,'checker':'PASS','native':'PASS' if name=='original' else 'KILLED','js':'PASS' if name=='original' else 'KILLED','sha256':hashlib.sha256(native).hexdigest()})
    (args.output/'evidence.json').write_text(json.dumps(evidence,indent=2)+'\n')
    print(json.dumps(evidence,indent=2))

if __name__ == '__main__':
    main()
