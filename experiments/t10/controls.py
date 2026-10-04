#!/usr/bin/env python3
"""Own-path compiling no-op controls; untimed and separate from measurement."""
import os,re,sys,tempfile
from pathlib import Path
HERE=Path(__file__).resolve().parent
sys.path.insert(0,str(HERE.parent/'t05'))
from run import build,command,paired
if os.environ.get('BENDVY_CPU') and hasattr(os,'sched_setaffinity'):
    os.sched_setaffinity(0,{int(os.environ['BENDVY_CPU'])})
def semantic(text):return text.splitlines()[-1].rsplit(':',1)[0]
def copy(folder,old,new):
    folder.mkdir()
    for name in ['core.bend','main.bend']:
        text=(HERE/name).read_text()
        if name=='core.bend':
            assert text.count(old)==1
            text=text.replace(old,new)
        def relocate(match):
            original=(HERE/match[1]).resolve()
            target=folder/original.name if original.parent==HERE else original
            path=os.path.relpath(target,folder)
            if not path.startswith('.'):path='./'+path
            return 'import '+path
        text=re.sub(r'import (\.[^\s]+)',relocate,text)
        (folder/name).write_text(text)
with tempfile.TemporaryDirectory(prefix='b10-control-') as d:
    folder=Path(d)
    original=build(HERE/'main.bend',folder)
    for name,mode,old,new in [('no-op-churn',3,'case 3: churn_round(w)','case 3: Outcome{w, 0}'),('no-op-rollback',5,'case _: fail_round(value, w)','case _: Outcome{w, 0}')]:
        args=[str(mode),'64','2']
        correct=[semantic(command([original[0],*args,'--threads','1','--gpu','off'])),semantic(command(['node',original[1],*args]))]
        reference=semantic(command(['node',HERE/'reference.mjs',*args]))
        assert correct==[reference,reference],(correct,reference)
        target=folder/name;copy(target,old,new)
        programs=build(target/'main.bend',target)
        wrong=[semantic(command([programs[0],*args,'--threads','1','--gpu','off'])),semantic(command(['node',programs[1],*args]))]
        assert wrong[0]==wrong[1] and wrong[0]!=reference,(name,wrong,reference)
        print(name+' detected on native and JS; positive/reference path PASS',flush=True)
print('T10 own-path no-op controls PASS',flush=True)
