#!/usr/bin/env python3
import os
from pathlib import Path
import re
import sys
import tempfile
HERE=Path(__file__).resolve().parent
sys.path.insert(0,str(HERE.parent/'t05'))
from run import build,command,paired
if os.environ.get('BENDVY_CPU') and hasattr(os,'sched_setaffinity'):
    os.sched_setaffinity(0,{int(os.environ['BENDVY_CPU'])})

def copy_mutant(folder, old, new):
    folder.mkdir()
    for name in ['streams.bend','runtime.bend','main.bend','bounds.bend','retention.bend']:
        text=(HERE/name).read_text()
        if name=='streams.bend':
            assert text.count(old)==1,old
            text=text.replace(old,new)
        (folder/name).write_text(text)

with tempfile.TemporaryDirectory(prefix='b7-') as directory:
    folder=Path(directory)
    results={}
    for name,reference,count in [('main','reference.mjs',12),('retention','retention-reference.mjs',4),('bounds','bounds-reference.mjs',8)]:
        correct=paired(build(HERE/(name+'.bend'),folder)).rstrip('\n')
        actual=command(['node',HERE/reference]).rstrip('\n')
        assert correct==actual,(name,correct,actual)
        assert len(correct.splitlines())==count
        results[name]=correct
        print(f'{name}: {count} ordered native/JS/reference observations PASS',flush=True)
    cases=[
      ('global-consume','main','(Log{capacity, xs, dropped}, (since(xs, last),','(Log{capacity, [], dropped}, (since(xs, last),'),
      ('advance-failure','main','case False{}: cursor','case False{}: complete_success(cursor, started)'),
      ('skip-keeps-backlog','main','def skip(cursor: Cursor, current: U32) -> Cursor:\n  complete_success(cursor, current)','def skip(cursor: Cursor, current: U32) -> Cursor:\n  cursor'),
      ('ignore-capacity','bounds','capacity_rows(xs, Nat.is_gt(size(xs), capacity),','capacity_rows(xs, False{},'),
      ('ignore-registration','bounds','U32.is_gt(dropped, maximum(last, registered))','U32.is_gt(dropped, last)'),
      ('ignore-holders','retention','oldest_boundary(tail, minimum(last, boundary))','oldest_boundary(tail, boundary)'),
    ]
    for name,entry,old,new in cases:
        target=folder/name
        copy_mutant(target,old,new)
        wrong=paired(build(target/(entry+'.bend'),target)).rstrip('\n')
        assert wrong!=results[entry],'surviving compiling mutant '+name
        print('compiling mutant detected: '+name,flush=True)
print('T07 bounded event readers/retention gate PASS; no change-reader or proof claim',flush=True)
