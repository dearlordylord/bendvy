#!/usr/bin/env python3
import os
from pathlib import Path
import sys
import tempfile
HERE=Path(__file__).resolve().parent
sys.path.insert(0,str(HERE.parent/'t05'))
from run import build,command,paired
if os.environ.get('BENDVY_CPU') and hasattr(os,'sched_setaffinity'):
    os.sched_setaffinity(0,{int(os.environ['BENDVY_CPU'])})

def mutate(folder, file, old, new):
    folder.mkdir()
    for source in HERE.glob('*.bend'):
        text=source.read_text()
        if source.name==file:
            assert text.count(old)==1,(file,old,text.count(old))
            text=text.replace(old,new)
        (folder/source.name).write_text(text)

with tempfile.TemporaryDirectory(prefix='b8-') as d:
    folder=Path(d)
    results={}
    for name,reference,count in [('main','reference.mjs',21),('retention','retention-reference.mjs',5),('expired','expired-reference.mjs',1),('bounds','bounds-reference.mjs',4)]:
        actual=paired(build(HERE/(name+'.bend'),folder)).rstrip('\n')
        expected=command(['node',HERE/reference]).rstrip('\n')
        assert actual==expected,(name,actual,expected)
        assert len(actual.splitlines())==count,(name,count,actual)
        results[name]=actual
        print(f'{name}: {count} ordered native/JS/reference observations PASS',flush=True)
    cases=[
      ('advance-failure','main','core.bend','case False{} old: old','case False{} Reader{_, _, registered}: Reader{tick, tick, registered}'),
      ('skip-lifecycle','main','core.bend','Reader{last, tick, reg}','Reader{tick, tick, reg}'),
      ('skip-keeps-messages','main','core.bend','Reader{last, tick, reg}','Reader{last, 0, reg}'),
      ('overwrite-adds','main','core.bend','case Row{id, Some{_}, added, _}: Row{id, Some{value}, added, tick}','case Row{id, Some{_}, added, _}: Row{id, Some{value}, tick, tick}'),
      ('failed-write-leaks','main','core.bend','case False{}: old','case False{}: next'),
      ('implicit-flush','main','core.bend','Output{queue(commands, w), ""}','Output{flush(queue(commands, w)), ""}'),
      ('ignore-holder','retention','log.bend','oldest_boundary(tail, minimum(last, boundary))','oldest_boundary(tail, boundary)'),
      ('ignore-capacity','bounds','log.bend','capacity_rows(xs, Nat.is_gt(size(xs), capacity),','capacity_rows(xs, False{},'),
      ('ignore-registration','bounds','log.bend','U32.is_gt(dropped, maximum(last, registered))','U32.is_gt(dropped, last)'),
    ]
    for name,entry,file,old,new in cases:
        target=folder/name
        mutate(target,file,old,new)
        wrong=paired(build(target/(entry+'.bend'),target)).rstrip('\n')
        assert wrong!=results[entry],'surviving compiling mutant '+name
        print('compiling mutant detected: '+name,flush=True)
print('T08 bounded change/lifecycle gate PASS; no proof or production-layout claim',flush=True)
