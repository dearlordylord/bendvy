#!/usr/bin/env python3
"""Contextual prefix-safety gate; every Bend invocation is capped at five seconds."""
import hashlib,json,os,pathlib,shutil,subprocess,tempfile
ROOT=pathlib.Path(__file__).resolve().parents[2]
HERE=pathlib.Path(__file__).resolve().parent
WRAPPER=ROOT/'experiments/t01/bend-check'
def sha(p): return hashlib.sha256(p.read_bytes()).hexdigest()
records=[]
def run(p,verdict=False,failure=None,kernel_negative=False):
    env=dict(os.environ)
    if kernel_negative: env['BENDTT']='/usr/bin/false'
    r=subprocess.run([str(WRAPPER),str(p),'--verdict' if verdict else '--check-only'],capture_output=True,text=True,env=env,timeout=6)
    out=r.stdout+r.stderr
    assert r.returncode==(1 if failure or kernel_negative else 0),(r.returncode,out)
    if failure: assert failure in out,out
    elif kernel_negative: assert 'formalized BendTT kernel' in out,out
    else: assert 'ALL PROOFS CHECK' in out,out
    records.append({'file':p.name,'kernel_requested':verdict,'kernel_negative':kernel_negative,'exit':r.returncode,'output':out})
for name in ['safety.bend','transport.bend','controls.bend']:
    for verdict in [False,True]: run(HERE/name,verdict)
run(HERE/'transport.bend',True,kernel_negative=True)
with tempfile.TemporaryDirectory(prefix='owned-safety-') as td:
    experiments=pathlib.Path(td)/'experiments';experiments.mkdir()
    for child in (ROOT/'experiments').iterdir():
        if child.name!=HERE.name: (experiments/child.name).symlink_to(child,target_is_directory=child.is_dir())
    package=experiments/HERE.name;shutil.copytree(HERE,package)
    # A fresh literal complete ModelSafe witness isolates the mutated predicate.
    (package/'mutant-witness.bend').write_text('import Base\nimport ./safety.bend as V\nimport ../t11-replacement/types.bend as T\ndef original_true() -> {True{} == V.ModelSafe([T.Bump{0n}],1n,T.World{7n,1n,[T.Row{0n,2n,False{}}],[]}) : Bool}:\n  {==}\n')
    run(package/'mutant-witness.bend',True)
    s=(package/'safety.bend').read_text()
    needle='Bool.and(S.step_safe(world,head),ModelSafe(tail,limit,M.step(limit,world,head)))'
    assert s.count(needle)==1
    (package/'safety.bend').write_text(s.replace(needle,'Bool.and(Bool.not(S.step_safe(world,head)),ModelSafe(tail,limit,M.step(limit,world,head)))'))
    run(package/'safety.bend')
    run(package/'transport.bend',failure='head_safe')
    run(package/'mutant-witness.bend',failure='original_true')
    # Invalid original oracle premise is rejected before transport can be called.
    (package/'invalid-premise.bend').write_text('import Base\nimport ../t11-replacement/types.bend as T\nimport ../t11-replacement/spec.bend as S\ndef invalid() -> {True{} == S.run_safe([],0n,T.World{7n,1n,[],[]}) : Bool}:\n  {==}\n')
    run(package/'invalid-premise.bend',failure='invalid')
subjects={p.name:sha(p) for p in (ROOT/'experiments/t11-replacement').glob('*.bend')}
assert subjects['LAWS.bend']=='e0c607d723ad250a189c096d9fa3fd6a36913f4c72efd3a3be6dacd7fadb2cbc'
evidence={'scope':'contextual safety transport for approved owned endpoint; not owned endpoint completion','baseline':'bb2be06742ba387fc42bd69cf50bedf4ac37a7c1','version':subprocess.check_output(['bend','version'],text=True).strip(),'sources':{p.name:sha(p) for p in HERE.glob('*.bend')},'subjects':subjects,'approval_sha256':sha(ROOT/'docs/reviews/delegated-owned-law-approval.md'),'compiler_sha256':sha(pathlib.Path(shutil.which('bend'))),'Base_sha256':sha(pathlib.Path.home()/'.bend/bend2/base.bend'),'contextual_imports':{str(p.relative_to(ROOT)):sha(p) for name in ['p-observe-schedule','p-observe-queries','p-observe-flush'] for p in (ROOT/'experiments'/name).glob('*.bend')},'checks':records}
assert evidence['compiler_sha256']=='d4821d04932218216c9dc906223ed0e23dd86726d4357a567fb76ee6c976db4e'
assert evidence['Base_sha256']=='c742fae9c49b14f0cc9128429a2c6109364c8a933a142f2c90b9f2e5fd976661'
(HERE/'evidence.json').write_text(json.dumps(evidence,indent=2)+'\n')
print('PASS: universal independent-to-model prefix safety, controls, compiling safety mutant and independent kernel gate')
