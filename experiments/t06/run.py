#!/usr/bin/env python3
import os
from pathlib import Path
import re
import sys
import tempfile
HERE=Path(__file__).resolve().parent
sys.path.insert(0,str(HERE.parent/'t05'))
from run import build, command, paired
if os.environ.get('BENDVY_CPU') and hasattr(os,'sched_setaffinity'):
    os.sched_setaffinity(0,{int(os.environ['BENDVY_CPU'])})

def mutant(folder, old, new):
    folder.mkdir()
    names=['core.bend','payload.bend','systems.bend','driver.bend','setup.bend','main.bend']
    for name in names:
        text=(HERE/name).read_text()
        def rewrite(match):
            original=(HERE/match.group(1)).resolve()
            target=folder/original.name if original.parent==HERE else original
            path=os.path.relpath(target,folder)
            return 'import '+(path if path.startswith('.') else './'+path)
        text=re.sub(r'import (\.[^\s]+)',rewrite,text)
        if name=='core.bend':
            assert text.count(old)==1,old
            text=text.replace(old,new)
        (folder/name).write_text(text)

with tempfile.TemporaryDirectory(prefix='b6-') as directory:
    folder=Path(directory)
    correct=paired(build(HERE/'main.bend',folder))
    reference=command(['node',HERE/'reference.mjs']).rstrip('\n')
    assert correct==reference,(correct,reference)
    assert len(correct.splitlines())==8
    print('8 ordered failure native/JS/reference observations PASS',flush=True)
    control=paired(build(HERE/'control.bend',folder))
    assert control==command(['node',HERE/'reference.mjs','control']).rstrip('\n')
    assert len(control.splitlines())==4
    print('4 ordered success-control native/JS/reference observations PASS',flush=True)
    good=paired(build(HERE/'good.bend',folder))
    assert good==command(['node',HERE/'reference.mjs','good']).rstrip('\n')
    assert len(good.splitlines())==5
    print('5 ordered Good-provider native/JS/reference observations PASS',flush=True)
    assert 'restored:5:7:13:events=1,:commands=remove:0,' in correct
    assert 'full:10,13,10,10:other-position=1' in correct
    assert 'full:10,19,10,10:other-position=1' in control
    for name,expected in [('control',0),('negative',1)]:
        result=command([HERE.parent/'t01'/'bend-check',HERE/('read-'+name+'.bend'),'--check-only'],expected=expected)
        if expected==0:assert 'ALL PROOFS CHECK' in result
        else:assert '- expected : A.Tx' in result and '- observed : T' in result
    print('paired abstract read capability rejection PASS',flush=True)
    cases=[
      ('no-undo','(undo_all(undo, Store{columns, meta}), Failure{system, error})','(Store{columns, meta}, Failure{system, error})'),
      ('forward-undo','(undo_all(undo, Store{columns, meta}), Failure{system, error})','(undo_all(List.reverse(&1, Undo, undo), Store{columns, meta}), Failure{system, error})'),
      ('whole-schedule','(undo_all(undo, Store{columns, meta}), Failure{system, error})','(initial(), Failure{system, error})'),
      ('publish-failed','case Tx{columns, Side{meta, undo, staged, pending}}: Tx{columns, Side{meta, undo, List.append(&2, U32, staged, [value]), pending}}','case Tx{columns, Side{Meta{resource, events, commands}, undo, staged, pending}}: Tx{columns, Side{Meta{resource, List.append(&2, U32, events, [value]), commands}, undo, staged, pending}}'),
    ]
    for name,old,new in cases:
        target=folder/name
        mutant(target,old,new)
        wrong=paired(build(target/'main.bend',target))
        assert wrong!=correct,'surviving compiling mutant '+name
        print('compiling mutant detected: '+name,flush=True)
print('T06 bounded rollback gate PASS; generic affine update restoration remains open',flush=True)
