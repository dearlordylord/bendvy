#!/usr/bin/env python3
"""Known wrong mark mutation: finite literal oracle must reject; no law/proof."""
import hashlib,json,pathlib,shutil,sys,tempfile
P=pathlib.Path(__file__).resolve().parent
sys.path.insert(0,str(P.parent/'fivehour-connected-gates'))
import supervisor
with tempfile.TemporaryDirectory(prefix='high-guard-mutant-',dir=P) as name:
    Q=pathlib.Path(name)
    for p in P.glob('*.bend'): shutil.copyfile(p,Q/p.name)
    shutil.copyfile(P/'check.py',Q/'check.py')
    p=Q/'transport.bend';s=p.read_text()
    old='Bool.and((0 < id : U32),Bool.and((id <= c : U32),(id <= h : U32)))'
    assert s.count(old)==2
    s=s.replace(old,'Bool.and((0 < id : U32),(id <= c : U32))');p.write_text(s)
    # Child retains all checker/codegen/clang/runtime limits and checks before execution.
    code,diagnostic=supervisor.execute(['python3',Q/'check.py'],240)
    assert code==1 and 'assert state[2]==' in diagnostic and 'AssertionError' in diagnostic,diagnostic
    (P/'high-guard-mutant.out').write_text(diagnostic)
    (P/'high-guard-mutant.json').write_text(json.dumps({'status':'INTENDED_LITERAL_ORACLE_REJECTION','change':'drop high-water check from both original and columns mark guards','exact_match_count':2,'mutant_source_sha256':hashlib.sha256(s.encode()).hexdigest(),'scope':'source checks, codegen and both runtimes complete; independent full-field literal oracle rejects; no proof or timing'},indent=2)+'\n')
print('PASS: compiling high-water-omission mutant rejected by independent full-field literal oracle')
