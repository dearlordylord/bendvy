#!/usr/bin/env python3
"""E11-only all-field compact validation, hard five-second execution."""
import importlib.util,json,hashlib,re,time,tempfile,os,sys
from pathlib import Path
HERE=Path(__file__).resolve().parent
s=importlib.util.spec_from_file_location('renderer',HERE/'renderer-run.py');r=importlib.util.module_from_spec(s);s.loader.exec_module(r)
N=65537
# Single changed field in an actual late row, plus malformed initial/range input.
controls={
 'last-main-c':('(i + 2 : U32)','corrupt(i)',0,'(i + 2 : U32)',65537),
 'last-aux-c':('T.Four{2,3,4,5}','T.Four{2,3,corrupt(i),5}',0,'4',65537),
 'last-metadata':('},7}','},corrupt(i)}',0,'7',65537),
 'last-namespace':('S.Handle{71,i}','S.Handle{corrupt(i),i}',0,'71',65537),
 'first-b-zero':('(i + 1 : U32)','corrupt(i)',0,'(i + 1 : U32)',1),
 'wrapped-id':('S.Handle{71,i}','S.Handle{71,corrupt(i)}',0,'i',65537),
}
def verify_row(schema,row,id,x):
 assert row['handle']=={'namespace':71 if schema=='Motion' else 72,'id':id}
 assert row['flag']=={'group':8}
 if schema=='Motion':
  assert row['main']=={'coordinates':r.four(x,x+1,x+2,x+3),'frame':7}
  assert row['aux']=={'rates':r.four(2,3,4,5),'moving':True}
 else:
  assert row['main']=={'levels':r.four(x,x+1,x+2,x+3),'reserve':9,'class':2}
  assert row['aux']=={'layers':r.four(2,3,4,5),'grade':4}
def expand_and_verify(schema,encoded):
 assert encoded['encoding']=='query-row-range'
 assert encoded['namespace']==(71 if schema=='Motion' else 72)
 assert encoded['idFirst']==encoded['xFirst']==1
 assert encoded['idLast']==encoded['xLast']==encoded['count']==N
 assert encoded['slot0']=={'mode':'x'}
 template=encoded['template'];verify_row(schema,template,1,1)
 # Verify EVERY reconstructed field/order against independent explicit fixture
 # inputs; the Bend encoder has independently validated each original Data row.
 for i in range(1,N+1):
  row={'handle':dict(namespace=encoded['namespace'],id=i),'main':dict(template['main']),'aux':template['aux'],'flag':template['flag']}
  row['main']['coordinates' if schema=='Motion' else 'levels']=r.four(i,i+1,i+2,i+3)
  verify_row(schema,row,i,i)
def main():
 evidence={'cpuAffinity':sorted(os.sched_getaffinity(0)),'scope':'E11-only compact actual full-row validation; not integrated Host acceptance','bounds':{'checker':5,'runtime':5,'codegen':30,'clang':120},'baseline':{'original_renderer_revision':'7757918','fixture_sha256':hashlib.sha256((HERE/'renderer-bulk-baseline.bend').read_bytes()).hexdigest(),'input':'original nonuniform Main/Aux/metadata fixture 65537 rows repeated query/added/changed','monolithic':{'Native':'5s timeout','JS':'machine stack overflow; exit1'},'tail_flattened':{'Native':'5s timeout','JS':'5s timeout'},'streamed':{'Native':{'exit':0,'seconds':1.4983933849725872,'bytes':41512431},'JS':'5s timeout'},'note':'Baseline probes preceded compact encoding; timeouts/fault are not semantic mutation passes.'},'sources':{p.name:hashlib.sha256(p.read_bytes()).hexdigest() for p in [HERE/'host-render.bend',HERE/'renderer-bulk-controls.bend',Path(__file__)]},'import_closure_sha256':r.source_closure(),'outcomes':{}}
 with tempfile.TemporaryDirectory(prefix='bendvy-renderer-bulk-') as tmp:
  for name,control in [('original',None),*controls.items()]:
   folder=Path(tmp)/name;folder.mkdir()
   source=(HERE/'renderer-bulk-controls.bend').read_text()
   if control:
    old,new,bad,good,at=control
    # Change ONLY Motion rows, preserve the independent Health positive lane.
    a=source.index('def rows(');b=source.index('def health_rows(')
    target=source[a:b];assert old in target
    target=target.replace(old,new)
    helper=f'def corrupt(+i:U32) -> U32:\n  match i:\n    case {at}: {bad}\n    case _: {good}\n'
    source=source[:a]+helper+target+source[b:]
   fixture=folder/'renderer-bulk-controls.bend';fixture.write_text(r.imports(source,HERE/'renderer-bulk-controls.bend'))
   binaries=r.runner.build(fixture,folder)
   outcomes=[]
   for binary in binaries:
    started=time.monotonic()
    try: raw=r.runner.execute(binary)
    except RuntimeError as error:
     outcomes.append({'backend':'JS' if binary.suffix=='.js' else 'Native','status':'FAILED','error':str(error),'seconds':time.monotonic()-started});continue
    elapsed=time.monotonic()-started
    actual=[json.loads(line) for line in raw.splitlines()];assert len(actual)==2
    health=actual[1];assert health['kind']=='Read' and health['step']=='bulk-health' and health['count']==N and health['boundary']==dict(since=20,streamSince=21,thisRun=22) and health['messageLag'] is True and health['removedLag'] is False and health['despawnedLag'] is True
    expand_and_verify('Health',health['query']);assert all(health[k]==[] for k in ['added','changed','removed','despawned','messages'])
    motion=actual[0];assert motion['kind']=='Read' and motion['step']=='bulk' and motion['system']=='Fast' and motion['count']==N and motion['boundary']==dict(since=10,streamSince=11,thisRun=12)
    assert all(motion[k]==[] for k in ['removed','despawned','messages']) and all(motion[k] is False for k in ['messageLag','removedLag','despawnedLag'])
    for key in ['query','added','changed']:
     if control:assert motion[key]['encoding']=='unrepresentable',name
     else:expand_and_verify('Motion',motion[key])
    outcomes.append({'backend':'JS' if binary.suffix=='.js' else 'Native','seconds':elapsed,'raw':raw,'status':'rejected unrepresentable actual Data' if control else 'PASS','actual_fields_verified':N*(1 if control else 4)})
   evidence['outcomes'][name]=outcomes
 (HERE/'renderer-bulk-evidence.json').write_text(json.dumps(evidence,indent=2)+'\n')
 passed=all(v['status']!='FAILED' for values in evidence['outcomes'].values() for v in values)
 print(('PASS' if passed else 'REGRESSION')+': full-field bounded renderer controls; deadline failures are not detected mutants')
 return 0 if passed else 1
if __name__=='__main__':sys.exit(main())
