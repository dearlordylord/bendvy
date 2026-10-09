"""Exact source inverse and old/new full-schema refusal equivalence; no profiler/compiler."""
import copy,hashlib,json,math
from pathlib import Path
root=Path(__file__).resolve().parent
delta=json.loads((root/'DELTA.json').read_text());old=Path(delta['originalValidator']).read_text();new=(root/'validate-retained.py').read_text()
assert hashlib.sha256(old.encode()).hexdigest()==delta['originalSHA256'] and hashlib.sha256(new.encode()).hexdigest()==delta['successorSHA256']
inverse=new
for p in reversed(delta['patches']):
    assert inverse.count(p['replacement'])==1;inverse=inverse.replace(p['replacement'],p['original'])
assert inverse==old
def schema(source):return source[source.index("nodes=data['nodes']"):source.index('events=[]')]
def outcome(source,data):
    try:
        context={'data':copy.deepcopy(data),'math':math};exec(compile(schema(source),'full-schema-control','exec'),context);return ('PASS',context['frames'])
    except (AssertionError,KeyError,TypeError,ValueError) as e:return (type(e).__name__,None)
base={'nodes':[{'id':1,'callFrame':{'functionName':'root','url':''},'children':[2]},{'id':2,'callFrame':{'functionName':'emit_body','url':'file:///$bunfs/root/bend'}}],'samples':[1,2],'timeDeltas':[-1,2],'startTime':1,'endTime':2}
assert outcome(old,base)==outcome(new,base) and outcome(new,base)[0]=='PASS'
mutants=[]
def mutant(change):
    item=copy.deepcopy(base);change(item);mutants.append(item)
mutant(lambda d:d['nodes'][1].update(id=1))
mutant(lambda d:d['samples'].__setitem__(0,9))
mutant(lambda d:d['nodes'][0].update(children=[9]))
mutant(lambda d:d.update(timeDeltas=[1]))
mutant(lambda d:d.update(timeDeltas=[float('inf'),2]))
mutant(lambda d:d.update(endTime=0))
mutant(lambda d:d['nodes'][0]['callFrame'].update(functionName=42))
mutant(lambda d:d['nodes'][0].pop('callFrame'))
mutant(lambda d:d.update(samples=[]))
mutant(lambda d:d['samples'].__setitem__(0,'1'))
for item in mutants:assert outcome(old,item)==outcome(new,item) and outcome(new,item)[0]!='PASS'
print(json.dumps({'scope':'Exact validator inverse and same full-schema semantics on signed-delta positive plus10 refusal controls; duplicate IDs/unknown sample/child refused','sourceInverse':True,'positive':1,'refusals':len(mutants),'noSchemaOrCapRelaxation':True}))
