#!/usr/bin/env python3
"""Finite #17 evidence; dependency-free. Each checker/runtime is bounded by 5s."""
import hashlib
import json
import os
from pathlib import Path
import sys
import tempfile

HERE=Path(__file__).resolve().parent
ROOT=HERE.parent.parent
REFERENCES=Path('/workspace/formal-proofs/bendvy/.references')
sys.path.insert(0,str(HERE.parent/'t05'))
from run import CHECK, build, command, paired

def sha(path):
    return hashlib.sha256(path.read_bytes()).hexdigest()

def copy_mutant(folder, replacements):
    folder.mkdir()
    for source in HERE.glob('*.bend'):
        text=source.read_text()
        for name,old,new in replacements:
            if source.name==name:
                assert text.count(old)==1,(name,old)
                text=text.replace(old,new)
        # All Bend imports are local to this experiment; no missing references
        # or mutable external modules are copied into the mutant.
        (folder/source.name).write_text(text)

def first_difference(correct, wrong):
    for i,(a,b) in enumerate(zip(correct.splitlines(),wrong.splitlines()),1):
        if a!=b:return {'line':i,'normal':a,'mutant':b}
    return {'line':min(len(correct.splitlines()),len(wrong.splitlines()))+1,'normal_lines':len(correct.splitlines()),'mutant_lines':len(wrong.splitlines())}

def main():
    if os.environ.get('BENDVY_CPU') and hasattr(os,'sched_setaffinity'):
        os.sched_setaffinity(0,{int(os.environ['BENDVY_CPU'])})
    pins=json.loads((ROOT/'.references/sources.json').read_text())['sources']
    for name,pin in pins.items():
        assert command(['git','-C',REFERENCES/name,'rev-parse','HEAD']).strip()==pin['commit'],name
    environment={'bend':command(['bend','version']).strip(),'node':command(['node','--version']).strip(),'clang':command(['clang','--version']).splitlines()[0],
      'bend_sha256':sha(Path(command(['which','bend']).strip())), 'base_sha256':sha(Path.home()/'.bend/bend2/base.bend'),
      'affinity':sorted(os.sched_getaffinity(0)) if hasattr(os,'sched_getaffinity') else None,
      'references':{name:pin['commit'] for name,pin in pins.items()},'checker_seconds':5,'runtime_seconds':5,'codegen_seconds':30,'clang_seconds':120}
    assert environment['bend']=='bend 2.0.34',environment
    command(['bend','guide'])
    expected=(HERE/'expected.txt').read_text().rstrip('\n')
    reference=command(['node',HERE/'reference.mjs']).rstrip('\n')
    assert reference==expected,'actual TS checkpoints changed'
    results={'environment':environment,'trace_lines':len(expected.splitlines()),'controls':{},'mutants':{}}
    with tempfile.TemporaryDirectory(prefix='capture-17-') as temporary:
        folder=Path(temporary)
        correct=paired(build(HERE/'main.bend',folder))
        assert correct==reference,(correct,reference)
        print(str(results['trace_lines'])+' ordered Native/JS/actual TS checkpoints PASS',flush=True)
        regenerated=folder/'regenerated-closure'
        copy_mutant(regenerated,[('schedule.bend','import ./local.bend as L','import ./local.bend as L\nimport ./closure.bend as F'),('schedule.bend','L.invoke(a)','F.invoke(a)'),('schedule.bend','L.invoke(b)','F.invoke(b)')])
        assert paired(build(regenerated/'main.bend',regenerated))==reference,'regenerated closure schedule mismatch'
        results['regenerated_closure_trace_lines']=len(reference.splitlines())
        print('Regenerated affine-closure schedule: same '+str(results['trace_lines'])+' Native/JS/actual TS checkpoints PASS',flush=True)
        for name in ['local-control','closure']:
            assert paired(build(HERE/(name+'.bend'),folder),quoted=True)=='2,1',name
            results[name]='2,1'
        print('Explicit owner and regenerated one-shot closure: isolated repeat2,1 PASS',flush=True)
        controls=[('undeclared','C.Tx','T'),('schema','C.Motion','C.Other'),('read','C.Tx','T'),('consume','f','f (consumed more than once)'),('snapshot','Data','Type'),('destructive','payload','payload (consumed more than once)')]
        for name,expected_type,observed_type in controls:
            yes=command([CHECK,HERE/(name+'-control.bend'),'--check-only'])
            no=command([CHECK,HERE/(name+'-negative.bend'),'--check-only'],expected=1)
            assert 'ALL PROOFS CHECK' in yes
            assert 'SOME PROOFS FAIL' in no and '- expected : '+expected_type+'\n' in no and '- observed : '+observed_type+'\n' in no and 'Location: bad' in no,(name,no)
            results['controls'][name]={'positive_exit':0,'negative_exit':1,'expected':expected_type,'observed':observed_type,'location':'bad'}
            print('Paired intended rejection: '+name+' PASS',flush=True)
        mutants=[
          ('lose-persistence',[('local.bend','+next = (old + 1 : U32)','+next = (0 + 1 : U32)')]),
          ('share-state',[('schedule.bend','case True{}: after_b(mode, label, a, w, tail, L.invoke(b))','case True{}: after_a(True{}, mode, label, b, w, tail, L.invoke(a))')]),
          ('omit-restoration',[('core.bend','Prepared{unwind(undo, w), Failure{name, code}, trace}','Prepared{w, Failure{name, code}, trace}')]),
          ('reverse-undo',[('core.bend','Prepared{unwind(undo, w), Failure{name, code}, trace}','Prepared{unwind(List.reverse(&1, U32, undo), w), Failure{name, code}, trace}')]),
          ('advance-failed-reader',[('core.bend','Prepared{unwind(undo, w), Failure{name, code}, trace}','Prepared{skipped(unwind(undo, w)), Failure{name, code}, trace}')]),
        ]
        # Move the failed-reader helper above finish in this mutant only; defs
        # must be declared before callers. This move changes no normal behavior.
        for name,replacements in mutants:
            mutant=folder/name
            copy_mutant(mutant,replacements)
            if name=='advance-failed-reader':
                source=mutant/'core.bend';text=source.read_text();start=text.index('def skipped(');end=text.index('def barrier(',start);helper=text[start:end];text=text[:start]+text[end:];where=text.index('def finish(');text=text[:where]+helper+text[where:];source.write_text(text)
            wrong=paired(build(mutant/'main.bend',mutant))
            assert wrong!=correct,'surviving compiling mutant '+name
            results['mutants'][name]={'checker':'PASS','native_js_agree':True,'first_difference':first_difference(correct,wrong)}
            print('Compiling Native/JS mutant killed: '+name,flush=True)
    results['source_sha256']={p.name:sha(p) for p in sorted(HERE.glob('*.bend'))}
    results['source_sha256'].update({name:sha(HERE/name) for name in ['reference.mjs','run.py','expected.txt']})
    (HERE/'results.json').write_text(json.dumps(results,indent=2)+'\n')
    print('#17 finite experiment PASS; general System/Local/destructive rollback and universal refinement remain open',flush=True)

if __name__=='__main__':main()
