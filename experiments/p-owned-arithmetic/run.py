#!/usr/bin/env python3
"""Five-second bounded checker/kernel gate; preserves canonical subjects."""
import hashlib, json, os, pathlib, subprocess, tempfile
ROOT = pathlib.Path(__file__).resolve().parents[2]
HERE = pathlib.Path(__file__).resolve().parent
WRAPPER = ROOT / 'experiments/t01/bend-check'
def digest(path):
    return hashlib.sha256(path.read_bytes()).hexdigest()
def run(path, verdict=False, bad=None):
    cmd = [str(WRAPPER), str(path), '--verdict' if verdict else '--check-only']
    env = dict(os.environ)
    p = subprocess.run(cmd, capture_output=True, text=True, timeout=6, env=env)
    output = p.stdout + p.stderr
    assert p.returncode == (1 if bad else 0), (cmd, p.returncode, output)
    if bad:
        assert bad in output, output
    else:
        assert 'ALL PROOFS CHECK' in output, output
    return {'file':path.name, 'kernel_requested':verdict,'exit':p.returncode,'output':output}
records = []
for name in ['structural.bend','controls.bend']:
    for verdict in [False,True]: records.append(run(HERE/name, verdict))
records.append(run(HERE/'false.bend', bad='bad_carry'))
with tempfile.TemporaryDirectory(prefix='owned-arithmetic-') as tmp:
    tmp = pathlib.Path(tmp)
    original = (HERE/'structural.bend').read_text()
    positive = tmp/'positive.bend'
    positive.write_text(original)
    records.append(run(positive, True))
    mutant = tmp/'mutant.bend'
    needle = 'Word.adc(n,w,Word.zero(n),False{},True{}) == Word.inc(n,w)'
    assert original.count(needle) == 1
    mutant.write_text(original.replace(needle,'Word.adc(n,w,Word.zero(n),False{},False{}) == Word.inc(n,w)'))
    records.append(run(mutant, bad='adc_carry'))
subjects = ['LAWS.bend','runtime.bend','owned-spec.bend','spec.bend','model.bend','types.bend']
evidence = {'scope':'contextual structural arithmetic only; no approved ECS endpoint completed',
            'version':subprocess.check_output(['bend','version'], text=True).strip(),
            'base_sha256':digest(pathlib.Path.home()/'.bend/bend2/base.bend'),
            'sources':{x.name:digest(x) for x in HERE.iterdir() if x.suffix == '.bend'},
            'subjects':{n:digest(ROOT/'experiments/t11-replacement'/n) for n in subjects},
            'checks':records}
assert evidence['subjects']['LAWS.bend'] == 'e0c607d723ad250a189c096d9fa3fd6a36913f4c72efd3a3be6dacd7fadb2cbc'
(HERE/'evidence.json').write_text(json.dumps(evidence,indent=2)+'\n')
print('PASS: contextual structural arithmetic, literal controls, false control and carry mutation; no ECS endpoint completed.')
