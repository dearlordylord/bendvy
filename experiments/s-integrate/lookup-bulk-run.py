#!/usr/bin/env python3
"""Actual lookup owner preservation and large-world stack regression controls."""
import hashlib
import importlib.util
import json
from pathlib import Path
import sys
import tempfile
import time

HERE = Path(__file__).resolve().parent
sys.path.insert(0,str(HERE.parent/'t05'))
from run import build,execute,command,CHECK
BASELINE_COMMIT = 'ace04c2'
NAMES = ['types.bend','payload.bend','storage.bend','identity.bend','commands.bend',
         'query.bend','storage-stage-fixture.bend','commands-bulk-controls.bend','lookup-bulk-controls.bend']

def load(name):
    spec=importlib.util.spec_from_file_location(name,HERE/(name+'.py'))
    module=importlib.util.module_from_spec(spec);spec.loader.exec_module(module)
    return module
ORACLE=load('lookup-bulk-oracle')
STAGE=load('storage-stage-run')

def expected(schema,count):
    data=ORACLE.expected(schema,count)
    lines=[str(data['retainedBefore']).lower(),str(data['retainedAfter']).lower()]
    for case in data['lookups']:
        result=case['result']
        value=result['kind']
        if value=='Found':
            row=STAGE.row({'schema':schema,'namespace':result['handle']['namespace']},result['row'],True)
            value='Found('+row+')'
        lines.append(case['label']+'='+value)
    return '\n'.join(lines)

def sources(folder,replace=None,baseline=False):
    folder.mkdir()
    for name in NAMES:
        text=(HERE/name).read_text()
        if name=='query.bend':
            if baseline:
                text=command(['git','-C',HERE,'show',BASELINE_COMMIT+':experiments/s-integrate/query.bend'])
            elif replace:
                old,new=replace
                assert text.count(old)==1,(old,text.count(old))
                text=text.replace(old,new)
        (folder/name).write_text(text)

def observed(programs,args):
    output=[];times=[]
    for program in programs:
        start=time.perf_counter();output.append(execute(program,args));times.append(round(time.perf_counter()-start,6))
    assert output[0]==output[1],output
    return output[0],dict(zip(['nativeSeconds','javascriptSeconds'],times))

def negatives(folder):
    W=STAGE.W; H='S.Handle<T.MotionSchema>'
    signature=STAGE.SIGNATURE
    def source(name,body,handle=H):
        return STAGE.COMMON+'def '+name+signature+body+f'def attempt(world: {W},handle: {handle}) -> {W} & T.Access<String>:\n  Q.lookup({STAGE.ARGS},~{name},Q.Required{{}},world,handle)\n'
    good='  F.motion_client(P,U,get,get_aux,handle,flag,main,aux)\n'
    path=folder/'lookup-positive.bend';path.write_text(source('good',good))
    assert 'ALL PROOFS CHECK' in command([CHECK,path,'--check-only'])
    cases={
        'write-through-read':('  Payload.position_swap(main,1)\n',['expected : T.Position','observed : P']),
        'undeclared-aux':('  Payload.velocity_get(main)\n',['expected : T.Velocity','observed : P']),
        'wrong-token':('  F.motion_client_main(P,U,aux,get_aux,handle,flag,get(main,T.VitalsToken{}))\n',['expected : T.PositionToken','observed : T.VitalsToken']),
        'reconstructed-owner':('  (T.Position{F.vector(10),7},(aux,""))\n',['expected : P','observed : T.Position']),
        'missing-owner':('  ("",(aux,""))\n',['expected : P','observed : String']),
        'consumed-owner':('  ignored = get(main,T.PositionToken{})\n  (main,(aux,""))\n',['consumed more than once']),
    }
    result={}
    for name,(body,diagnostics) in cases.items():
        path=folder/(name+'.bend');path.write_text(source('bad',body))
        actual=command([CHECK,path,'--check-only'],expected=1)
        assert 'Location: bad' in actual and all(s in actual for s in diagnostics),actual
        result[name]=dict(expectedExit=1,location='bad',diagnostic=diagnostics)
    path=folder/'lookup-cross-schema.bend';path.write_text(source('good',good,'S.Handle<T.HealthSchema>'))
    actual=command([CHECK,path,'--check-only'],expected=1)
    assert 'Location: attempt' in actual and 'T.MotionSchema' in actual and 'T.HealthSchema' in actual,actual
    result['cross-schema-handle']=dict(expectedExit=1,location='attempt',diagnostic=['T.MotionSchema','T.HealthSchema'])
    return result

def baseline(root):
    folder=root/'baseline';sources(folder,baseline=True)
    programs=build(folder/'lookup-bulk-controls.bend',folder)
    evidence=dict(baselineCommit=BASELINE_COMMIT,querySha256=hashlib.sha256((folder/'query.bend').read_bytes()).hexdigest(),fixtureSha256=hashlib.sha256((folder/'lookup-bulk-controls.bend').read_bytes()).hexdigest(),results=[])
    for schema,num in [('Motion',0),('Health',1)]:
        for count in [5,65537]:
            for program in programs:
                start=time.perf_counter();backend='JS' if program.suffix=='.js' else 'Native'
                try:
                    value=execute(program,[str(num),str(count)])
                    assert value==expected(schema,count)
                    assert not(count==65537 and backend=='JS'),'expected baseline JS failure disappeared'
                    row=dict(status='success',outputSha256=hashlib.sha256(value.encode()).hexdigest())
                except RuntimeError as ex:
                    assert count==65537 and backend=='JS' and 'memory fault (machine stack overflow?)' in str(ex),str(ex)
                    row=dict(status='failure',diagnostic='exit 1; bend: memory fault (machine stack overflow?)')
                row.update(schema=schema,count=count,backend=backend,seconds=round(time.perf_counter()-start,6));evidence['results'].append(row)
    (HERE/'lookup-bulk-baseline.json').write_text(json.dumps(evidence,indent=2)+'\n')
    print('Baseline: both large JS lanes reproduce machine stack failure',flush=True)

def main():
    oracle=ORACLE.run();assert oracle['rejectedObservations']==442
    with tempfile.TemporaryDirectory(prefix='lookup-bulk-') as temporary:
        root=Path(temporary)
        if '--baseline' in sys.argv:
            baseline(root);return
        folder=root/'original';sources(folder)
        evidence=dict(status='PASS',scope='actual lookup traversal and owner-return prerequisite',limits=dict(checkerSeconds=5,runtimeSeconds=5,codegenSeconds=30,clangSeconds=120),oracleRejectedObservations=442,negativeControls=negatives(folder),original=[],mutants=[])
        programs=build(folder/'lookup-bulk-controls.bend',folder)
        for schema,num in [('Motion',0),('Health',1)]:
            for count in [5,65537]:
                value,times=observed(programs,[str(num),str(count)])
                assert value==expected(schema,count),(value,expected(schema,count))
                evidence['original'].append(dict(schema=schema,count=count,output=value,**times))
                print(schema,count,times,'PASS',flush=True)
        mutants=[
            ('live-mismatch-as-missing',('LookupRead{before,row,T.Mismatch{}}','LookupRead{before,row,T.Missing{}}')),
            ('discard-prefix',('List.reverse.go(&1,S.Row<M,A,F>,before,row <> tail)','row <> tail')),
            ('reverse-prefix-order',('List.reverse.go(&1,S.Row<M,A,F>,before,row <> tail)','List.append(&1,S.Row<M,A,F>,before,row <> tail)')),
            ('foreign-collision-as-local',('U32.is_eq(namespace,foreign)','True{}')),
            ('erase-retained-mark',('namespace,before,S.Row{id,main,aux,flag,added,changed})','namespace,before,S.Row{id,main,aux,flag,0,changed})')),
        ]
        for name,replacement in mutants:
            folder=root/name;sources(folder,replacement)
            programs=build(folder/'lookup-bulk-controls.bend',folder)
            value,times=observed(programs,['0','5'])
            assert value!=expected('Motion',5),name
            evidence['mutants'].append(dict(name=name,compiled=True,detectedOnBothBackends=True,**times))
            print(name,'DETECTED',flush=True)
        evidence['sources']={name:hashlib.sha256((HERE/name).read_bytes()).hexdigest() for name in NAMES+['lookup-bulk-run.py','lookup-bulk-oracle.py','LOOKUP-BULK-DRAFT.md']}
        (HERE/'lookup-bulk-evidence.json').write_text(json.dumps(evidence,indent=2)+'\n')
    print('LOOKUP BULK PASS; no performance acceptance or universal refinement claim',flush=True)
if __name__=='__main__':main()
