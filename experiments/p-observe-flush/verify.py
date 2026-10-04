#!/usr/bin/env python3
"""Verify only partial contextual theorems; approved flush endpoint stays open."""
import hashlib,json,os,re,shutil,signal,subprocess,tempfile
from pathlib import Path
HERE=Path(__file__).resolve().parent;ROOT=HERE.parent.parent
CHECK=ROOT/'experiments/t01/bend-check'
def sha(p):return hashlib.sha256(p.read_bytes()).hexdigest()
def run(args,expected=0,env=None):
 p=subprocess.Popen([str(x) for x in args],stdout=subprocess.PIPE,stderr=subprocess.STDOUT,text=True,start_new_session=True,env=env)
 try:out=p.communicate(timeout=6)[0]
 except subprocess.TimeoutExpired:os.killpg(p.pid,signal.SIGKILL);p.communicate();raise AssertionError('five-second wrapper watchdog failed')
 assert p.returncode==expected,(args,p.returncode,out)
 return {'command':[str(x) for x in args],'exit_code':p.returncode,'output':out}
def main():
 if hasattr(os,'sched_setaffinity'):os.sched_setaffinity(0,{int(os.environ.get('BENDVY_PROOF_CPU','8'))})
 frozen=json.loads((HERE/'subjects.json').read_text())
 for name,h in frozen['canonical_sources'].items():assert sha(ROOT/name)==h,name
 block=re.search(r'(?m)^law explicit_flush_independent:\n(?:(?!^law ).*\n)*',(ROOT/'experiments/t11-replacement/LAWS.bend').read_text()).group().rstrip()
 assert block==frozen['original_block']==(HERE/'LAWS.bend').read_text().split('\n\n',1)[1].rstrip()
 evidence={'status':'PARTIAL: contextual toolkit proved; explicit_flush_independent remains OPEN','checker_limit_seconds':5,'exact_endpoint_selection':True,'checks':[],'mutants':[]}
 for name,flag in [('toolkit.bend','--check-only'),('toolkit.bend','--verdict'),('controls.bend','--verdict')]:
  r=run([CHECK,HERE/name,flag]);assert 'ALL PROOFS CHECK' in r['output'];evidence['checks'].append(r)
 for name,n in [('LAWS.bend',1),('RESIDUAL.bend',3)]:
  r=run([CHECK,HERE/name,'--check-only'],1);assert f'{n} TODO'+('' if n==1 else 's')+' found' in r['output'];evidence['checks'].append(r)
 env=dict(os.environ);env['BENDTT']='/usr/bin/false'
 r=run([CHECK,HERE/'toolkit.bend','--verdict'],1,env);assert 'mismatch' in r['output'];evidence['kernel_negative']=r
 mutants=[('spawn-wrong-tag','case T.Spawn{slot, value}: T.Row{slot, value, False{}} <> rows','case T.Spawn{slot, value}: T.Row{slot, value, True{}} <> rows','spawn_slot',False),('reverse-fifo','case Con{command, tail}: apply_all(tail, apply(command, rows))','case Con{command, tail}: apply(command, apply_all(tail, rows))','target_fifo',True)]
 for label,old,new,location,focused in mutants:
  with tempfile.TemporaryDirectory(prefix='flush-mutant-',dir=HERE) as tmp:
   base=Path(tmp)
   for d in ['t11-replacement','p-observe-lookup']:shutil.copytree(ROOT/'experiments'/d,base/d,ignore=shutil.ignore_patterns('__pycache__'))
   package=base/'p-observe-flush';package.mkdir()
   text=(HERE/'toolkit.bend').read_text()
   if focused:
    # Exclude an earlier independent prefix lemma to observe failure of the
    # unchanged target_fifo theorem itself, rather than masking it in helpers.
    a=text.index('def application_prefix(');b=text.index('# Independent per-slot',a);text=text[:a]+text[b:]
   (package/'toolkit.bend').write_text(text)
   positive=run([CHECK,package/'toolkit.bend','--verdict']);assert 'ALL PROOFS CHECK' in positive['output']
   model=base/'t11-replacement/model.bend';s=model.read_text();assert s.count(old)==1;model.write_text(s.replace(old,new))
   typed=run([CHECK,model,'--check-only']);assert 'ALL PROOFS CHECK' in typed['output']
   rejected=run([CHECK,package/'toolkit.bend','--check-only'],1);assert f'Location: {location}' in rejected['output'],rejected
   evidence['mutants'].append({'name':label,'old':old,'new':new,'theorem':location,'focus_excludes_application_prefix':focused,'copied_positive':positive,'compiling_implementation':typed,'contextual_proof_failure':rejected})
 evidence['canonical_sources']=frozen['canonical_sources']
 evidence['source_hashes']={p.name:sha(p) for p in HERE.glob('*.bend')}
 evidence['lookup_dependency_hashes']={str(p.relative_to(ROOT)):sha(p) for p in (ROOT/'experiments/p-observe-lookup').glob('*.bend')}
 evidence['base_sha256']=sha(Path.home()/'.bend/bend2/base.bend');evidence['runner_sha256']=sha(HERE/'verify.py')
 (HERE/'evidence.json').write_text(json.dumps(evidence,indent=2)+'\n');print(evidence['status'])
if __name__=='__main__':main()
