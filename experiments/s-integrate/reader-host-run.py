#!/usr/bin/env python3
"""Five-second checked/Native/JS adapter joins using actual factory/commands."""
import hashlib, importlib.util, json, os, re, tempfile
from pathlib import Path
HERE=Path(__file__).resolve().parent
spec=importlib.util.spec_from_file_location('builds',HERE.parent/'t05'/'run.py')
B=importlib.util.module_from_spec(spec);spec.loader.exec_module(B)
FILES=['reader-host.bend','reader-host-controls.bend']
def sha(p):return hashlib.sha256(p.read_bytes()).hexdigest()
def copy(folder):
    folder.mkdir()
    for name in FILES:
        text=(HERE/name).read_text()
        def rewrite(m):
            original=(HERE/m[1]).resolve()
            target=folder/original.name if original.name in FILES else original
            return 'import '+os.path.relpath(target,folder)
        (folder/name).write_text(re.sub(r'import (\.[^\s]+)',rewrite,text))
    return folder

def expected(capacity):
    empty='messages=;removed=;despawned=;lag=false/false/false'
    held='messages=11,22,;removed=1/1;1/2;;despawned=1/2;;lag=false/false/false'
    prefix='messages=;removed=1/1;1/2;;despawned=1/2;;lag=false/false/false' if capacity==1 else held
    lossy='messages=;removed=1/2;;despawned=1/2;;lag=true/true/false' if capacity==1 else held
    late='messages=;removed=1/2;;despawned=1/2;;lag=false/false/false' if capacity==1 else held
    rows=[f'added-not-removed:since=0/0;run=2;{empty}',f'no-lifecycle-boundary:since=0/0;run=5;{prefix}',f'failed:since=2/2;run=6;{lossy}',f'retry:since=2/2;run=7;{lossy}',f'late:since=0/0;run=8;{late}',f'completed:since=7/7;run=9;{empty}']
    return '\n'.join(['Motion',*rows,'Health',*rows])
def run(folder):return B.paired(B.build(folder/FILES[1],folder))
def replace(folder,old,new):
    p=folder/FILES[0];t=p.read_text();assert t.count(old)==1,(old,t.count(old));p.write_text(t.replace(old,new))
def main():
    evidence={'scope':'Actual factory/command notification to reader-host adapter, separate from full dispatcher',
        'versions':{'bend':B.command(['bend','version']),'node':B.command(['node','--version'])},
        'checkerAndExecutionLimitSeconds':5,'sourceSha256':{p.name:sha(p) for p in [HERE/f for f in FILES+['reader-host-run.py','readers.bend','streams.bend','commands.bend','storage.bend','identity.bend','types.bend','storage-stage-fixture.bend','reader-host-schema-positive.bend','reader-host-schema-negative.bend']]},'original':[],'mutants':[]}
    positive=B.command([B.CHECK,HERE/'reader-host-schema-positive.bend','--check-only'])
    negative=B.command([B.CHECK,HERE/'reader-host-schema-negative.bend','--check-only'],expected=1)
    assert 'ALL PROOFS CHECK' in positive
    assert 'SOME PROOFS FAIL' in negative and 'MotionSchema' in negative and 'HealthSchema' in negative
    evidence['schemaControl']={'positive':positive,'negative':negative}
    mutations=[
      ('drop-despawn','S.append_lifecycle(W.Handle<Schema>,despawned,tick,[handle])','despawned'),
      ('added-as-removed','case saved _: saved','case Logs{ping,removed,despawned} W.MainAdded{handle}: Logs{ping,S.append_lifecycle(W.Handle<Schema>,removed,tick,[handle]),despawned}\n    case saved _: saved'),
      ('suppress-removal-lag','messageLag,removedLag,despawnedLag}}','messageLag,False{},despawnedLag}}'),
      ('wrong-main-holder-kind','R.Removed{0}','R.Removed{1}'),
      ('trim-without-lifecycle-boundary','case None{}: log','case None{}: S.trim_lifecycle(W.Handle<Schema>,log,0,holds)'),
      ('discard-message-publication','S.append(P,ping,tick,values)','ping'),
    ]
    with tempfile.TemporaryDirectory(prefix='build-reader-host-',dir=HERE) as td:
      root=Path(td)
      for c in [1,3]:
        folder=copy(root/f'original{c}')
        p=folder/FILES[1];p.write_text(p.read_text().replace('H.initial(Schema,P,1)','H.initial(Schema,P,'+str(c)+')'))
        output=run(folder);assert output==expected(c),(c,output,expected(c))
        evidence['original'].append({'capacity':c,'bothBackends':True,'stdout':output});print(f'actual factory/command/read adapter C{c}: Native/JS PASS',flush=True)
      for name,old,new in mutations:
        folder=copy(root/name);replace(folder,old,new)
        # Publication deletion must be tested without the later capacity loss masking it.
        c=3 if name=='discard-message-publication' else 1
        p=folder/FILES[1];p.write_text(p.read_text().replace('H.initial(Schema,P,1)','H.initial(Schema,P,'+str(c)+')'))
        output=run(folder);assert output!=expected(c),(name,output)
        first=next(({'actual':a,'expected':b} for a,b in zip(output.splitlines(),expected(c).splitlines()) if a!=b),None)
        assert first
        evidence['mutants'].append({'name':name,'capacity':c,'old':old,'new':new,'checkedBuiltBothBackends':True,'firstDifference':first,'stdout':output})
        print(name+': actual difference PASS',flush=True)
    (HERE/'reader-host-evidence.json').write_text(json.dumps(evidence,indent=2)+'\n')
if __name__=='__main__':main()
