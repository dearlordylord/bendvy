#!/usr/bin/env python3
"""Strict E11 public oracle preparation; actual Host binding is still pending.
--prepare refreshes ten public TS executions and oracle perturbations only.
Default deliberately returns INCOMPLETE until a real joined backend runner exists.
"""
import argparse, copy, hashlib, importlib.util, json
from pathlib import Path
HERE=Path(__file__).resolve().parent

def module(name,path):
    spec=importlib.util.spec_from_file_location(name,path)
    result=importlib.util.module_from_spec(spec);spec.loader.exec_module(result);return result
B=module('bounded_build',HERE.parent/'t05'/'run.py')
CMP=module('strict_trace',HERE/'trace-compare.py')
SCHEMAS=('Motion','Health')
LANES=('message','removed','despawned','unheld','marks')
PUBLIC=('schema','lane','capacity','invocations','rawReservationIds','dispatches','observations')

def sha(path):return hashlib.sha256(path.read_bytes()).hexdigest()
def project(results):
    lanes={}
    for row in results:
        key=row['schema']+'/'+row['lane']
        if key in lanes:raise ValueError('duplicate lane '+key)
        if row.get('status')!='PASS' or row.get('firstDifference') is not None:
            raise ValueError('execution did not pass: '+key)
        if row['capacity']!=65536:raise ValueError('public capacity must remain 65536')
        lanes[key]={name:row[name] for name in PUBLIC}
    wanted={s+'/'+l for s in SCHEMAS for l in LANES}
    if lanes.keys()!=wanted:raise ValueError('requires all ten distinct public cases')
    return lanes

def perturbations(reference):
    tests=[]
    def expect(name,edit):
        candidate=copy.deepcopy(reference);edit(candidate)
        differences=CMP.difference(project(reference),project(candidate))
        assert differences,name
        tests.append({'name':name,'firstDifference':differences[0]})
    message=0;removed=1;marks=4
    expect('dropped-last-message',lambda r:r[message]['observations'][2]['messages'].__setitem__('last',65534))
    expect('wrong-full-payload-field',lambda r:r[removed]['observations'][2]['q']['payload'].__setitem__('frame',999))
    expect('wrong-last-row',lambda r:r[removed]['observations'][2]['q']['ids'].__setitem__('last',65536))
    expect('wrong-compared-row-count',lambda r:r[removed]['observations'][2]['q'].__setitem__('allMainAndAuxFieldsCompared',65536))
    expect('lost-old-surviving-marks',lambda r:r[marks]['observations'][-1].__setitem__('changed',{}))
    expect('incorrect-lag',lambda r:r[message]['observations'][-1]['lag'].__setitem__('messages',True))
    expect('wrong-base-invocation-count',lambda r:r[message]['invocations'].__setitem__('B',3))
    expect('dropped-reader-dispatch',lambda r:r[message]['observations'].pop())
    expect('wrong-failure-code',lambda r:r[message]['dispatches'][7]['result']['error']['error'].__setitem__('code',999))
    for name,rows in [('missing-lane',reference[:-1]),('duplicate-lane',reference+[reference[0]])]:
        try:project(rows)
        except ValueError as error:tests.append({'name':name,'rejected':str(error)})
        else:raise AssertionError(name)
    return tests

def prepare():
    source=HERE.parent/'s-integrate-trace'/'reference-retention.mjs'
    checked=B.command([B.CHECK,HERE/'host-retention-controls.bend','--check-only'])
    assert 'ALL PROOFS CHECK' in checked
    results=[]
    for schema in SCHEMAS:
        for lane in LANES:
            result=json.loads(B.command(['node',source,schema,lane]))
            assert result['status']=='PASS',result
            results.append(result);print('fresh public reference '+schema+'/'+lane+': PASS',flush=True)
    project(results)
    controls=perturbations(results)
    evidence={'status':'PREPARATION_ONLY','actualJoinedBendExecuted':False,
      'pending':'Actual parameterized Host invocation and D.tick binding; no E11 runtime gate claimed',
      'limits':{'checkerSeconds':5,'referenceExecutionSeconds':5},
      'versions':{'bend':B.command(['bend','version']),'node':B.command(['node','--version'])},
      'sha256':{p.name:sha(p) for p in [source,HERE/'host-retention-controls.bend',HERE/'host-retention-run.py',HERE/'HOST-RETENTION-LAWS-DRAFT.md',HERE/'trace-compare.py']},
      'inputCheck':checked,'publicReference':results,'oraclePerturbations':controls}
    (HERE/'host-retention-evidence.json').write_text(json.dumps(evidence,indent=2)+'\n')
    print('PREPARATION_ONLY: ten source runs and eleven comparator controls; actual joined backend binding pending')

def main():
    parser=argparse.ArgumentParser(description=__doc__);parser.add_argument('--prepare',action='store_true')
    args=parser.parse_args()
    if args.prepare:prepare();return 0
    print(json.dumps({'status':'INCOMPLETE','reason':'Real parameterized Host + D.tick binding not delivered; --prepare is oracle preparation only'}));return 2
if __name__=='__main__':raise SystemExit(main())
