#!/usr/bin/env python3
"""New owned-runtime evidence for #12; no old task results counted as acceptance."""
import hashlib,json,os,shutil,sys,tempfile
from pathlib import Path
HERE=Path(__file__).resolve().parent
sys.path.insert(0,str(HERE.parent/'t05'))
from run import CHECK,build,command,execute
ROOT=Path('/workspace/formal-proofs/bendvy')
MUTANTS=[
 ('foreign-lookup-comparison','model.bend','lookup_if(Nat.is_eq(id, namespace),','lookup_if(True{},'),
 ('foreign-command-comparison','runtime.bend','publish_if(U32.is_eq(id,namespace),','publish_if(True{},'),
 ('factory-namespace-constant','runtime.bend','Some{World{next,1,[],[]}}','Some{World{0,1,[],[]}}'),
 ('reservation-always-reject','runtime.bend','reserve_if(U32.is_lt(next,limit),','reserve_if(False{},'),
 ('fifo-reversed','runtime.bend','apply_all(pending,rows),[]','apply_all(List.reverse(&2,Command,pending),rows),[]'),
 ('flush-noop','runtime.bend','apply_all(pending,rows),[]','rows,[]'),
 ('schedule-implicit-flush','runtime.bend','case Nil{}: world\n    case Con{s,tail}: tick','case Nil{}: flush(world)\n    case Con{s,tail}: tick'),
 ('immediate-owned-write-noop','runtime.bend','values[0] <- (value + 1 : U32)','values[0] <- value'),
]

# Actual API callers also have independent compiling defects.
MUTANTS.extend([
 ('owned-query-always-empty','runtime.bend','(world,M.query(data,selection))','(world,[])'),
 ('owned-lookup-always-missing','runtime.bend','(world,M.lookup(data,T.Handle{U32.to_nat(id),U32.to_nat(slot)},selection))','(world,T.Missing{})'),
 ('owned-reserve-always-none','runtime.bend','Some{Handle{id,next}}','None{}'),
 ('owned-schedule-ignores-steps','runtime.bend','case Con{s,tail}: tick(tail,limit,step(limit,world,s))','case Con{s,tail}: tick(tail,limit,world)'),
])

def paired_with_evidence(programs):
    outputs=[execute(p) for p in programs]
    assert outputs[0]==outputs[1],outputs
    return outputs[0].splitlines()

def main():
    if hasattr(os,'sched_setaffinity'):os.sched_setaffinity(0,{int(os.environ.get('BENDVY_LAWS_CPU','8'))})
    version=command(['bend','version']).strip();guide=command(['bend','guide']);assert 'Laws and Proofs' in guide
    pins=json.loads((HERE.parents[1]/'.references/sources.json').read_text())['sources']
    for name,entry in pins.items():
        actual=command(['git','-C',ROOT/'.references'/name,'rev-parse','HEAD']).strip()
        assert actual==entry['commit'],(name,actual)
    node=command(['node','--version']).strip()
    evidence={'bend':version,'node':node,'reference_commits':{n:e['commit'] for n,e in pins.items()},'checker_limit_seconds':5,'build_limits_seconds':{'emit':30,'clang':120},'runtime_limit_seconds':5,'base_sha256':hashlib.sha256((Path.home()/'.bend/bend2/base.bend').read_bytes()).hexdigest(),'native_flags':['--threads','1','--gpu','off'],'mutants':[]}
    with tempfile.TemporaryDirectory(prefix='owned-check-',dir=HERE) as tmp:
        folder=Path(tmp)
        trace=paired_with_evidence(build(HERE/'trace.bend',folder))
        reference=command(['node',HERE/'reference.mjs']).splitlines()
        native_parity=[s for s in trace if not s.startswith(('foreign-collision:','foreign-command-denied:'))]
        ts_parity=[s for s in reference if not s.startswith(('foreign-collision:','foreign-command-collision:'))]
        assert len(native_parity)==len(ts_parity)==72
        assert native_parity==ts_parity,(native_parity,ts_parity)
        assert 'live:any:1:1:0;2:2:0;3:3:0;' in trace
        assert 'immediate-and-pending:any:1:1:0;2:3:0;3:3:0;' in trace
        assert 'removed:any:1:1:0;2:3:1;3:3:0;' in trace
        assert 'stale:any:2:3:1;3:3:0;' in trace
        assert 'new-live:any:2:3:1;3:3:0;4:4:0;' in trace
        assert 'foreign-collision:lookup:MissingEntity' in trace
        assert 'foreign-collision:lookup:match:1:1:1;' in reference
        assert 'foreign-command-denied:any:1:1:1;2:3:1;3:3:0;' in trace
        assert reference[-1]=='foreign-command-collision:remaining:0'
        evidence['finite_trace']={'native':trace,'javascript':trace,'bevy_ts':reference,'equal_public_observations':72,'approved_lookup_divergence':{'owned':'MissingEntity','bevy_ts':'match:1:1:1;'},'foreign_command_security':{'owned_state_preserved':True,'bevy_ts_isolated_collision_remaining':0,'public_rejection_result':'unresolved; current internal publication API returns owned world only'}}
        print('72 ordered real TS/native/JS observations + factory-derived foreign collision controls PASS',flush=True)
        boundary=paired_with_evidence(build(HERE/'boundary.bend',folder))
        assert boundary==['reserved:4294967294:next:4294967295:live:0','rejected:next:4294967295:live:0','created:4294967294:next:4294967295','creation-rejected:next:4294967295','increment-before-max:4294967295'],boundary
        evidence['u32_boundaries']=boundary
        print('5 U32 executable boundary controls PASS',flush=True)
        controls=[]
        for name,expected in [('read-write-negative','expected : Cell'),('schema-negative','A.Motion'),('undeclared-negative','expected : Cell'),('reconstruct-negative','expected : P')]:
            good=command([CHECK,HERE/'access-control.bend','--check-only']);assert 'ALL PROOFS CHECK' in good
            bad=command([CHECK,HERE/(name+'.bend'),'--check-only'],expected=1)
            assert 'SOME PROOFS FAIL' in bad and 'Location: bad' in bad,bad
            if 'schema' in name: assert 'A.Motion' in bad and 'A.Health' in bad,bad
            elif 'reconstruct' in name: assert '- expected : P' in bad and '- observed : R.Cell' in bad,bad
            else: assert '- expected : R.Cell' in bad and '- observed : P' in bad,bad
            controls.append({'negative':name,'positive':'access-control.bend','diagnostic':bad.strip()})
        erasure_good=command([CHECK,HERE/'erasure-control.bend','--check-only'])
        assert 'ALL PROOFS CHECK' in erasure_good,erasure_good
        erasure_bad=command([CHECK,HERE/'erasure-negative.bend','--check-only'],expected=1)
        assert '- expected : -world' in erasure_bad and '- observed : world' in erasure_bad and 'Location: bad' in erasure_bad,erasure_bad
        evidence['erased_owner_boundary']={'proposition_control':'erasure-control.bend','live_leak_negative':'erasure-negative.bend','diagnostic':erasure_bad.strip()}
        evidence['authority_pairs']=controls
        authority=paired_with_evidence(build(HERE/'authority-main.bend',folder))
        assert authority==['7'],authority
        evidence['authority_successful_owned_write']=authority
        print('4 task-local owned-cell access-negative/positive pairs PASS',flush=True)
        for label,file,old,new in MUTANTS:
            mutant=folder/label;mutant.mkdir()
            for p in HERE.glob('*.bend'):
                if p.name=='LAWS.bend':continue
                content=p.read_text()
                if p.name==file:
                    assert content.count(old)==1,(file,old)
                    content=content.replace(old,new)
                (mutant/p.name).write_text(content)
            observed=paired_with_evidence(build(mutant/'trace.bend',mutant))
            assert observed!=trace,'surviving runtime mutant '+label
            index=next(i for i,(a,b) in enumerate(zip(trace,observed)) if a!=b)
            evidence['mutants'].append({'name':label,'file':file,'replacement':[old,new],'native_javascript_agree':True,'first_different_observation':index,'original':trace[index],'mutant':observed[index]})
            print(label,'compiling Native/JS mutant killed at',index,flush=True)
            (HERE/'runtime-evidence.json').write_text(json.dumps(evidence,indent=2)+'\n')
        evidence['source_hashes']={p.name:hashlib.sha256(p.read_bytes()).hexdigest() for p in HERE.glob('*.bend')}
        (HERE/'runtime-evidence.json').write_text(json.dumps(evidence,indent=2)+'\n')
    print('bounded replacement runtime evidence PASS; no universal proof/performance acceptance',flush=True)
if __name__=='__main__':main()
