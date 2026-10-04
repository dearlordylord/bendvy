#!/usr/bin/env python3
"""Independent full extra-mutant stage; original exact controls rechecked first.
Useful for a segmented rerun when law subjects/input pools have not changed.
This does not replace the 31 primary law/control/mutant grids in falsify.py.
"""
import os,json,tempfile
from pathlib import Path
import falsify as f

os.sched_setaffinity(0,{int(os.environ.get('BENDVY_LAWS_CPU','7'))})
report=[]
with tempfile.TemporaryDirectory(prefix='extra-canary-',dir=f.HERE) as tmp:
    root=Path(tmp); original=root/'original';f.copies(original)
    mapping={n:(b,c) for n,b,c in f.read_laws()};cached={}
    for label,name,mutation in f.EXTRA:
        b,c=mapping[name]
        if name not in cached:
            cached[name]=f.original_instances(original,name,b,c,f.samples(b))
        controls=f.extra_controls(original,label,name,b,c,cached[name])
        result=f.mutate(root/label,name,b,c,controls,mutation)
        report.append({'name':label,'law':name,**result})
        print(label,'PASS',flush=True)
    (f.HERE/'extra-canary.json').write_text(json.dumps(report,indent=2)+'\n')
