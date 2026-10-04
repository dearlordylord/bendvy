#!/usr/bin/env python3
"""Verify exact general flush proof, contextual links and own-endpoint mutant."""
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
 selected=(HERE/'LAWS.bend').read_text()
 assert block==frozen['original_block']==selected.split('\n\n',1)[1].rstrip()
 assert re.findall(r'(?m)^law (\w+):',selected)==['explicit_flush_independent']
 for alias,name in [('T','types'),('M','model'),('S','spec')]:assert f'import ../t11-replacement/{name}.bend as {alias}' in selected
 evidence={'status':'PASS: exact general explicit_flush_independent proof and own-endpoint mutant gate','checker_limit_seconds':5,'exact_endpoint_selection':True,'checks':[],'mutants':[]}
 for name,flag in [('toolkit.bend','--check-only'),('toolkit.bend','--verdict'),('coherence.bend','--check-only'),('coherence.bend','--verdict'),('prefix.bend','--check-only'),('prefix.bend','--verdict'),('materialization.bend','--check-only'),('materialization.bend','--verdict'),('PROOF.bend','--check-only'),('PROOF.bend','--verdict'),('controls.bend','--verdict')]:
  r=run([CHECK,HERE/name,flag]);assert 'ALL PROOFS CHECK' in r['output'];evidence['checks'].append(r)
 for name,n in [('LAWS.bend',1),('RESIDUAL.bend',1)]:
  r=run([CHECK,HERE/name,'--check-only'],1);assert f'{n} TODO'+('' if n==1 else 's')+' found' in r['output'];evidence['checks'].append(r)
 env=dict(os.environ);env['BENDTT']='/usr/bin/false'
 r=run([CHECK,HERE/'toolkit.bend','--verdict'],1,env);assert 'mismatch' in r['output'];evidence['kernel_negative']=r
 mutants=[('spawn-wrong-tag','case T.Spawn{slot, value}: T.Row{slot, value, False{}} <> rows','case T.Spawn{slot, value}: T.Row{slot, value, True{}} <> rows','spawn_slot',False),('reverse-fifo','case Con{command, tail}: apply_all(tail, apply(command, rows))','case Con{command, tail}: apply(command, apply_all(tail, rows))','target_fifo',True)]
 for label,old,new,location,focused in mutants:
  with tempfile.TemporaryDirectory(prefix='flush-mutant-',dir=HERE) as tmp:
   base=Path(tmp)
   for d in ['t11-replacement','p-observe-lookup','p-observe-queries']:shutil.copytree(ROOT/'experiments'/d,base/d,ignore=shutil.ignore_patterns('__pycache__'))
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
 # Actual Target publication/application caller linkage, isolated from the
 # older same-slot theorem so its own general command endpoint is observed.
 with tempfile.TemporaryDirectory(prefix='flush-command-mutant-',dir=HERE) as tmp:
  base=Path(tmp)
  for d in ['t11-replacement','p-observe-lookup','p-observe-queries']:shutil.copytree(ROOT/'experiments'/d,base/d,ignore=shutil.ignore_patterns('__pycache__'))
  package=base/'p-observe-flush';package.mkdir()
  text=(HERE/'toolkit.bend').read_text();text=text[:text.index('def target_fifo(')]
  (package/'toolkit.bend').write_text(text);shutil.copyfile(HERE/'coherence.bend',package/'coherence.bend')
  positive=run([CHECK,package/'coherence.bend','--verdict']);assert 'ALL PROOFS CHECK' in positive['output']
  model=base/'t11-replacement/model.bend';text=model.read_text()
  old='case T.Target{slot, action}: modify(slot, action, rows)';new='case T.Target{slot, action}: rows'
  assert text.count(old)==1;model.write_text(text.replace(old,new))
  typed=run([CHECK,model,'--check-only']);assert 'ALL PROOFS CHECK' in typed['output']
  rejected=run([CHECK,package/'coherence.bend','--check-only'],1);assert 'Location: command_slot' in rejected['output'],rejected
  evidence['mutants'].append({'name':'target-application-noop','old':old,'new':new,'theorem':'command_slot','focus_excludes_target_fifo':True,'copied_positive':positive,'compiling_implementation':typed,'contextual_proof_failure':rejected})
 # End-to-end approved law gate: mutate only the actual flush caller, leaving
 # all contextual algorithms/independent oracle unchanged.
 with tempfile.TemporaryDirectory(prefix='flush-endpoint-mutant-',dir=HERE) as tmp:
  base=Path(tmp)
  for d in ['t11-replacement','p-observe-lookup','p-observe-queries']:shutil.copytree(ROOT/'experiments'/d,base/d,ignore=shutil.ignore_patterns('__pycache__'))
  package=base/'p-observe-flush';package.mkdir()
  for source in HERE.glob('*.bend'):shutil.copyfile(source,package/source.name)
  positive=run([CHECK,package/'PROOF.bend','--verdict']);assert 'ALL PROOFS CHECK' in positive['output']
  model=base/'t11-replacement/model.bend';text=model.read_text()
  old='case T.World{id, next, rows, pending}: T.World{id, next, apply_all(pending, rows), []}'
  new='case T.World{id, next, rows, pending}: T.World{id, next, rows, []}'
  assert text.count(old)==1;model.write_text(text.replace(old,new))
  typed=run([CHECK,model,'--check-only']);assert 'ALL PROOFS CHECK' in typed['output']
  rejected=run([CHECK,package/'PROOF.bend','--check-only'],1);assert 'Location: Laws.explicit_flush_independent' in rejected['output'],rejected
  literal=package/'own-witness.bend'
  ground=(HERE/'controls.bend').read_text()
  start=ground.index('def flush_complete_observation(');end=ground.index('def flush_valid_premise(',start)
  literal.write_text('import Base\nimport ../t11-replacement/types.bend as T\nimport ../t11-replacement/model.bend as M\n\n'+ground[start:end])
  witness=run([CHECK,literal,'--check-only'],1);assert 'Location: flush_complete_observation' in witness['output']
  evidence['mutants'].append({'name':'explicit-flush-caller-noop','old':old,'new':new,'theorem':'Laws.explicit_flush_independent','copied_positive':positive,'compiling_implementation':typed,'own_endpoint_failure':rejected,'valid_original_ground_witness_rejected':witness})
 evidence['canonical_sources']=frozen['canonical_sources']
 evidence['source_hashes']={p.name:sha(p) for p in HERE.glob('*.bend')}
 evidence['lookup_dependency_hashes']={str(p.relative_to(ROOT)):sha(p) for p in (ROOT/'experiments/p-observe-lookup').glob('*.bend')}
 evidence['query_dependency_hashes']={str(p.relative_to(ROOT)):sha(p) for p in (ROOT/'experiments/p-observe-queries').glob('*.bend')}
 evidence['base_sha256']=sha(Path.home()/'.bend/bend2/base.bend');evidence['runner_sha256']=sha(HERE/'verify.py')
 (HERE/'evidence.json').write_text(json.dumps(evidence,indent=2)+'\n');print(evidence['status'])
if __name__=='__main__':main()
