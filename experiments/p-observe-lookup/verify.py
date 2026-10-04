#!/usr/bin/env python3
"""Exact selection, ordinary checker/kernel proof, fresh controls and own-law mutant."""
import hashlib,json,os,re,shutil,signal,subprocess,tempfile
from pathlib import Path
HERE=Path(__file__).resolve().parent
ROOT=HERE.parent.parent
CHECK=ROOT/'experiments/t01/bend-check'
FROZEN=json.loads((HERE/'subjects.json').read_text())

def digest(p):return hashlib.sha256(p.read_bytes()).hexdigest()
def invoke(args,expected=0,env=None):
    p=subprocess.Popen([str(a) for a in args],stdout=subprocess.PIPE,stderr=subprocess.STDOUT,text=True,start_new_session=True,env=env)
    try:out=p.communicate(timeout=6)[0]
    except subprocess.TimeoutExpired:
        os.killpg(p.pid,signal.SIGKILL);p.communicate();raise AssertionError('wrapper failed its five-second checker deadline')
    assert p.returncode==expected,(args,p.returncode,out)
    return {'command':[str(a) for a in args],'exit_code':p.returncode,'output':out}

def main():
    if hasattr(os,'sched_setaffinity'):os.sched_setaffinity(0,{int(os.environ.get('BENDVY_PROOF_CPU','8'))})
    for name,sha in FROZEN['canonical_sources'].items():assert digest(ROOT/name)==sha,name
    original=(ROOT/'experiments/t11-replacement/LAWS.bend').read_text()
    block=re.search(r'(?m)^law lookup_full_exact:\n(?:(?!^law ).*\n)*',original).group().rstrip()
    selected=(HERE/'LAWS.bend').read_text()
    assert block==FROZEN['exact_original_block']
    assert selected.split('\n\n',1)[1].rstrip()==block
    assert re.findall(r'(?m)^law (\w+):',selected)==['lookup_full_exact']
    for alias,name in [('T','types'),('M','model'),('S','spec')]:
        assert f'import ../t11-replacement/{name}.bend as {alias}' in selected
    report={'issue':18,'selected_law':'lookup_full_exact','exact_selection':True,'checker_limit_seconds':5,'canonical_sources':FROZEN['canonical_sources'],'checks':[]}
    for flag in ['--check-only','--verdict']:
        r=invoke([CHECK,HERE/'PROOF.bend',flag]);assert 'ALL PROOFS CHECK' in r['output'];report['checks'].append(r)
    r=invoke([CHECK,HERE/'controls.bend','--verdict']);assert 'ALL PROOFS CHECK' in r['output'];report['checks'].append(r)
    env=dict(os.environ);env['BENDTT']='/usr/bin/false'
    r=invoke([CHECK,HERE/'PROOF.bend','--verdict'],1,env);assert 'ALL PROOFS CHECK' not in r['output'];report['kernel_negative_control']=r
    with tempfile.TemporaryDirectory(prefix='lookup-mutant-',dir=HERE) as tmp:
        base=Path(tmp)
        shutil.copytree(ROOT/'experiments/t11-replacement',base/'t11-replacement',ignore=shutil.ignore_patterns('__pycache__'))
        package=base/'p-observe-lookup';package.mkdir()
        for name in ['LAWS.bend','PROOF.bend','controls.bend']:shutil.copyfile(HERE/name,package/name)
        # Verify the copied positive from precisely the location used by mutation.
        r=invoke([CHECK,package/'PROOF.bend','--verdict']);assert 'ALL PROOFS CHECK' in r['output'];report['copied_positive']=r
        target=base/'t11-replacement/model.bend';text=target.read_text()
        old='lookup_if(Nat.is_eq(id, namespace), slot, selection, rows)'
        new='lookup_if(False{}, slot, selection, rows)'
        assert text.count(old)==1;target.write_text(text.replace(old,new))
        typed=invoke([CHECK,target,'--check-only']);assert 'ALL PROOFS CHECK' in typed['output']
        rejected=invoke([CHECK,package/'PROOF.bend','--check-only'],1)
        assert 'Location: L.lookup_full_exact' in rejected['output'],rejected
        assert 'expected :' in rejected['output'] and 'observed :' in rejected['output']
        literal=package/'mutant-witness.bend'
        literal.write_text('import Base\nimport ../t11-replacement/types.bend as T\nimport ../t11-replacement/model.bend as M\n\ndef local_found() -> {M.lookup(T.World{0n,2n,[T.Row{1n,7n,True{}}],[]},T.Handle{0n,1n},T.Any{}) == T.Found{T.Row{1n,7n,True{}}} : T.Lookup}:\n  {==}\n')
        witness=invoke([CHECK,literal,'--check-only'],1);assert 'Location: local_found' in witness['output']
        report['mutant']={'old':old,'new':new,'compiles':typed,'own_proof_failure':rejected,'local_true_original_false_mutant':witness}
    report['source_hashes']={p.name:digest(p) for p in HERE.glob('*.bend')}
    report['runner_sha256']=digest(HERE/'verify.py')
    report['base_sha256']=digest(Path.home()/'.bend/bend2/base.bend')
    report['status']='PASS: general exact lookup theorem checked by checker and kernel; compiling semantic mutant rejected at its own endpoint'
    (HERE/'evidence.json').write_text(json.dumps(report,indent=2)+'\n')
    print(report['status'])
if __name__=='__main__':main()
