#!/usr/bin/env python3
"""Checked route diagnostics, never a success gate for the seventh theorem."""
import hashlib
import json
import os
from pathlib import Path
import signal
import shutil
import subprocess
import tempfile

HERE=Path(__file__).resolve().parent
ROOT=HERE.parent.parent
CHECK=ROOT/'experiments/t01/bend-check'

def sha(path):
    return hashlib.sha256(path.read_bytes()).hexdigest()

def run(path,expected,needles):
    command=[str(CHECK),str(path),'--verdict']
    process=subprocess.Popen(command,stdout=subprocess.PIPE,stderr=subprocess.STDOUT,text=True,start_new_session=True)
    try:
        output=process.communicate(timeout=6)[0]
    except subprocess.TimeoutExpired:
        os.killpg(process.pid,signal.SIGKILL)
        process.communicate()
        raise AssertionError('five-second checker wrapper watchdog failed')
    assert process.returncode==expected,(command,process.returncode,output)
    assert all(text in output for text in needles),(command,output)
    return {'command':command,'exit_code':process.returncode,'output':output}

frozen=json.loads((HERE/'subjects.json').read_text())
for name,digest in frozen['canonical_sources'].items():
    assert sha(ROOT/name)==digest,name
original=(ROOT/'experiments/t11-replacement/LAWS.bend').read_text()
assert frozen['exact_original_block']==original[original.index('law owned_runtime_schedule_correspondence:'):].strip()
# Freeze that exact-empty diagnostic is copied without altering its signature.
assert (HERE/'empty-exact-negative.bend').read_text()==(ROOT/'experiments/p-observe-feasibility/empty-schedule-attempt.bend').read_text()
rows=[]
for name in ['language','owner-diagnostic','dead-formation','guard-witness','empty-instances','live-empty-constructor','empty-family']:
    rows.append({'scope':'language/transport/finite diagnostic only; no general owned theorem',
                 'name':name,**run(HERE/(name+'.bend'),0,['ALL PROOFS CHECK'])})
negatives=[
 ('erased-guard-negative',['expected : -guard','observed : guard']),
 ('dead-proof-negative',['expected : -proof','observed : proof']),
 ('dead-rewrite-negative',['expected : -proof','observed : proof']),
 ('live-call-negative',['expected : -n','observed : n']),
 ('erased-owner-forward-negative',['expected : -owner','observed : owner']),
 ('empty-conditional-negative',['expected : -world','observed : world']),
 ('erased-field-negative',['expected : -proof','observed : proof']),
 ('false-negative',['expected : 0n','observed : 1n']),
 ('false-transport-negative',['expected : True{}','observed : False{}']),
 ('empty-exact-negative',['non-inferrable term','S.When(S.admissible','Location: attempt'])]
for name,needles in negatives:
    rows.append({'name':name,**run(HERE/(name+'.bend'),1,['SOME PROOFS FAIL']+needles)})
# Actual-subject constructor pair differs only by binder liveness and its name.
negative=(HERE/'empty-conditional-negative.bend').read_text().split('def attempt',1)[1]
positive=(HERE/'live-empty-constructor.bend').read_text().split('def construct',1)[1]
assert negative.replace('-world: R.World','world: R.World')==positive
proposal=(HERE/'PROPOSED.bend').read_text()
proposed_block=proposal[proposal.index('law owned_runtime_schedule_correspondence:'):].strip()
assert proposed_block==frozen['exact_original_block'].replace('for -world: R.World','for world: R.World')
rows.append({'name':'PROPOSED remains unapproved/open',**run(HERE/'PROPOSED.bend',1,['SOME PROOFS FAIL','1 TODO found'])})
# Mutant validates the actual runtime projection link of the narrow family.
with tempfile.TemporaryDirectory(prefix='owned-family-mutant-') as temporary:
    base=Path(temporary)
    shutil.copytree(ROOT/'experiments/t11-replacement',base/'t11-replacement')
    shutil.copytree(HERE,base/'p-owned-route',ignore=shutil.ignore_patterns('evidence.json'))
    copied_positive=run(base/'p-owned-route/empty-family.bend',0,['ALL PROOFS CHECK'])
    target=base/'t11-replacement/runtime.bend'
    source=target.read_text()
    old='T.World{U32.to_nat(id),U32.to_nat(next),rows,commands_project(pending)}'
    new='T.World{1n+U32.to_nat(id),U32.to_nat(next),rows,commands_project(pending)}'
    assert source.count(old)==1
    target.write_text(source.replace(old,new))
    compiling=run(target,0,['ALL PROOFS CHECK'])
    failed=run(base/'p-owned-route/empty-family.bend',1,['SOME PROOFS FAIL','Location: equation'])
    mutant={'scope':'empty-row family equation only, NOT seventh-law mutation gate',
            'old':old,'new':new,'copied_positive':copied_positive,
            'compiling_runtime':compiling,'family_failure':failed}

# A verdict invocation must really run its kernel.
prior=os.environ.get('BENDTT')
os.environ['BENDTT']='/usr/bin/false'
try:
    kernel_negative=run(HERE/'language.bend',1,['SOME PROOFS FAIL','mismatch'])
finally:
    if prior is None:os.environ.pop('BENDTT',None)
    else:os.environ['BENDTT']=prior
refs=Path('/workspace/formal-proofs/bendvy/.references')
manifest=json.loads((ROOT/'.references/sources.json').read_text())
commits={name:subprocess.check_output(['git','-C',str(refs/name),'rev-parse','HEAD'],text=True).strip() for name in ['bevy-ts','bevy','bend2']}
assert all(commits[name]==manifest['sources'][name]['commit'] for name in commits)
report={'status':'ROUTE BLOCKED: diagnostics verified; exact seventh theorem and arbitrary-world empty case remain unproved',
        'completed_approved_laws':[], 'checker_limit_seconds':5,
        'compiler_version':subprocess.check_output(['bend','version'],text=True).strip(),
        'compiler_binary_sha256':sha(Path(shutil.which('bend')).resolve()),
        'canonical_sources':frozen['canonical_sources'],'reference_commits':commits,
        'checks':rows,'kernel_negative_control':kernel_negative,'family_mutant':mutant,
        'proposal_sha256':sha(HERE/'PROPOSED.bend'),'proposal_law_block_sha256':hashlib.sha256(proposed_block.encode()).hexdigest(),
        'source_hashes':{p.name:sha(p) for p in HERE.glob('*.bend')},
        'runner_sha256':sha(HERE/'run.py'),
        'base_sha256':sha(Path('/home/node/.bend/bend2/base.bend')),
        'installed_kernel_source_sha256':sha(Path('/home/node/.bend/bend2/bendtt.lean')),
        'pinned_checker_source_sha256':sha(refs/'bend2/bend2/bend.ts')}
(HERE/'evidence.json').write_text(json.dumps(report,indent=2)+'\n')
print(report['status'])
