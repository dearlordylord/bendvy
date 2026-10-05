#!/usr/bin/env python3
"""Single copied-artifact operation diagnostic; never timing evidence."""
import argparse, hashlib, importlib.util, json, pathlib, re, subprocess, tempfile
ROOT = pathlib.Path(__file__).resolve().parents[3]
spec = importlib.util.spec_from_file_location('validator', ROOT/'experiments/s-integrate/measurement-samples-run.py')
V = importlib.util.module_from_spec(spec); spec.loader.exec_module(V)
def sha(p): return hashlib.sha256(p.read_bytes()).hexdigest()
def main():
    p=argparse.ArgumentParser();p.add_argument('--artifact',type=pathlib.Path,required=True);p.add_argument('--output',type=pathlib.Path,required=True);p.add_argument('--mutant',action='store_true');a=p.parse_args()
    a.output.mkdir(parents=True,exist_ok=False)
    source=a.artifact.read_text(); names=['$storage$rows_extract$','$storage$rows_restore$','$storage$take_rows$','$storage$put_rows$','$storage$hook_return$','$storage$mark_main$','$storage$mark_meta$','$payload$health_ledger_get$','$payload$health_ledger_swap$','$transaction$record_main$','$transaction$record_ledger$']
    prologue='const diagnostic={phase:"outside",world:0,counts:{}}; function count(k){const p=diagnostic.phase;const c=diagnostic.counts[p]??={};c[k]=(c[k]??0)+1;}\n'
    for name in names:
        pattern=r'(function '+re.escape(name)+r'\([^\n]*\) \{)'
        source,n=re.subn(pattern,lambda m:m[0]+'\n count('+json.dumps(name)+');',source)
        assert n==1,(name,n)
    for name,hook in [('$measurement$045bend$health_measured$','diagnostic.phase="loop"+(++diagnostic.world);'),('$measurement$045bend$health_stop$','diagnostic.phase="outside";')]:
        source,n=re.subn(r'(function '+re.escape(name)+r'\([^\n]*\) \{)',lambda m:m[0]+'\n '+hook,source);assert n==1
    if a.mutant: source=source.replace('count("$transaction$record_main$");','count("$transaction$record_main$"); count("$transaction$record_main$");')
    source=prologue+'process.on("exit",()=>process.stderr.write("OPERATION-COUNTS:"+JSON.stringify(diagnostic)+"\\n"));\n'+source
    instrumented=a.output/'instrumented.js';instrumented.write_text(source)
    command=['node',str(instrumented),'1','0','256','1']
    evidence={'status':'INCOMPLETE','scope':'Entry counts only; not timing attribution or performance evidence','artifact':str(a.artifact),'artifactSHA256':sha(a.artifact),'instrumentedSHA256':sha(instrumented),'runnerSHA256':sha(pathlib.Path(__file__)),'command':command,'runtimeLimitSeconds':5,'mutant':a.mutant,'hooks':names}
    try:
        reftext=V.B.command(['node',ROOT/'experiments/s-integrate/measurement-reference.mjs','Health','dense','256'])
        (a.output/'reference.json').write_text(reftext);ref=json.loads(reftext)
        child=subprocess.run(command,capture_output=True,text=True,timeout=5)
        (a.output/'stdout.txt').write_text(child.stdout);(a.output/'stderr.txt').write_text(child.stderr)
        assert child.returncode==0,child.returncode
        validated=V.checked('JS',child.stdout,'Health',False,256,1,ref)
        evidence['fullFieldValidation']={k:v for k,v in validated.items() if 'milliseconds' not in k.lower()}
        counts=json.loads(child.stderr.split('OPERATION-COUNTS:',1)[1]);evidence['counts']=counts
        assert counts['world']==2
        for phase in ['loop1','loop2']:
            c=counts['counts'][phase]
            assert c['$transaction$record_main$']==64*256
            assert c['$transaction$record_ledger$']==64*256
            assert c['$storage$mark_main$']==64*256
            assert c['$payload$health_ledger_get$']==64*256
            assert c['$payload$health_ledger_swap$']==64*256
        assert counts['counts']['loop1']==counts['counts']['loop2']
        evidence['status']='FINITE_FULL_FIELD_AND_COUNT_PASS'
    except Exception as e:evidence.update(status='FAIL',error=str(e))
    (a.output/'evidence.json').write_text(json.dumps(evidence,indent=2)+'\n');print(json.dumps(evidence,indent=2));return evidence['status']!='FINITE_FULL_FIELD_AND_COUNT_PASS'
if __name__=='__main__':raise SystemExit(main())
