"""Finite independent fixture sensitivity; no compiling subject mutants or universal claim."""
import copy,gzip,hashlib,json
from pathlib import Path
D=Path(__file__).resolve().parents[1]
fixtures=json.loads(gzip.decompress((D/'model/observer-fixtures.json.gz').read_bytes()))
compact=lambda v:json.dumps(v,separators=(',',':'),ensure_ascii=False)
def cells(records):
 out=[]
 def natural(n):out.extend(map(ord,str(n)));out.append(0)
 natural(len(records))
 for value in records:
  text=compact(value);natural(len(text));out.extend(map(ord,text))
 return out
controls=[]
def changed(name,record,path,value):
 original=cells([record]);mutant=copy.deepcopy(record);at=mutant
 for key in path[:-1]:at=at[key]
 at[path[-1]]=value
 assert cells([mutant])!=original
 controls.append(name)
f=fixtures[0];seed=f['common'][0];b=next(x for x in f['common']if x['kind']=='Boundary');end=next(x for x in f['common']if x['kind']=='Boundary'and x['phase']==2)
for k in range(4):
 changed('main.cell'+str(k),b,['rows',0,'main','value','levels',k],9999)
 changed('aux.cell'+str(k),b,['rows',0,'aux','value','layers',k],9999)
 changed('ledger.cell'+str(k),b,['ledger','totals',k],9999)
for name,path,value in [('main.reserve',['rows',0,'main','value','reserve'],99),('main.class',['rows',0,'main','value','class'],99),('aux.grade',['rows',0,'aux','value','grade'],99),('flag.group',['rows',1,'flag','value','group'],99),('optional.variant',['rows',1,'aux'],{'kind':'Found','value':{'layers':[1,2,3,4],'grade':3}}),('ledger.epoch',['ledger','epoch'],99),('iteration',['iteration'],99),('phase',['phase'],99),('target',['target'],99),('current',['current'],99),('reservation',['reservations',0],99),('current.kind',['currentKind'],99),('target.kind',['targetKind'],99)]:changed(name,b,path,value)
changed('stale.actor',end,['stale',0,'actor'],999)
changed('stale.kind',end,['stale',0,'kind'],2)
changed('seed.foreign.main',seed,['foreign','rows',0,'main','value','levels',3],9999)
changed('seed.foreign.ledger',seed,['foreign','ledger','totals',3],9999)
stage=next(x for x in f['common']if x['kind']=='Stage');changed('stage.outcome',stage,['outcome','kind'],'Failure');changed('final.status',f['common'][-1],['status','kind'],'Refused')
reordered=copy.deepcopy(b);reordered['rows'][0],reordered['rows'][1]=reordered['rows'][1],reordered['rows'][0];assert cells([reordered])!=cells([b]);controls.append('row.order')
assert cells([f['common'][0],f['common'][1]])!=cells([f['common'][1],f['common'][0]]);controls.append('record.order')
for role in ['bend','ts']:
 foreign=f['foreign'][role][0]
 changed(role+'.foreign.actor',foreign,['foreign','actor'],99)
 changed(role+'.foreign.variant',foreign,['result'],{'kind':'Different'})
changed('bend.foreign.namespace',f['foreign']['bend'][0],['foreign','namespace'],99)
changed('ts.foreign.rawid',f['foreign']['ts'][0],['foreign','rawId'],99)
text='quote" slash\\ newline\n nul\0 astral😀 combiningé';v={'text':text};encoded=cells([v]);rendered=compact(v);assert encoded==list(map(ord,'1'))+[0]+list(map(ord,str(len(rendered))))+[0]+list(map(ord,rendered));controls.append('escaping.scalar.length')
actual=f['tuple'];bad=actual.copy();bad[-1]^=1;assert bad!=actual;controls.append('full.tuple.changed.with.original.fold.retained')
assert f['foreignTuples']['bend']!=f['foreignTuples']['ts'];assert fixtures[0]['foreignTuples']['bend']!=fixtures[1]['foreignTuples']['bend'];controls.append('foreign.role.world.distinction')
print(json.dumps({'status':'FINITE_MODEL_SENSITIVITY_PASS','scope':'Fixture-only sensitivity; no compiling runtime mutant, no universal serializer proof. Whole actual role streams and tuples remain separately required.','controls':controls,'count':len(controls),'fixtureSHA256':hashlib.sha256((D/'model/observer-fixtures.json.gz').read_bytes()).hexdigest()},indent=2))
