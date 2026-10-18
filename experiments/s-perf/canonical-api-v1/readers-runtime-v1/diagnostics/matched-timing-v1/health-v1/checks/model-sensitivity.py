"""Finite independent fixture sensitivity, not compiling mutants or universal proofs."""
from pathlib import Path
import copy,gzip,hashlib,json
D=Path(__file__).resolve().parents[1];raw=(D/'model/observer-fixtures.json.gz').read_bytes();fixtures=json.loads(gzip.decompress(raw));f=fixtures[0];records=f['records'];compact=lambda v:json.dumps(v,separators=(',',':'),ensure_ascii=False)
def cells(values):
 out=[]
 def nat(n):out.extend(map(ord,str(n)));out.append(0)
 nat(len(values))
 for v in values:
  text=compact(v);nat(len(text));out.extend(map(ord,text))
 return out
checks=[]
def change(name,record,path,value):
 altered=copy.deepcopy(record);at=altered
 for key in path[:-1]:at=at[key]
 at[path[-1]]=value
 assert cells([altered])!=cells([record]);checks.append(name)
prime=next(x for x in records if x['kind']=='Read'and x['phase']=='Prime');read=next(x for x in records if x['kind']=='Read'and x['phase']=='Read');slow=next(x for x in records if x['kind']=='Read'and len(x['removed']['values'])>1)
for k in range(4):
 for label,path in [('main',['rows',0,'main','value','levels',k]),('aux',['rows',0,'aux','value','layers',k]),('added',['added',0,'main','value','levels',k]),('changed',['changed',0,'main','value','levels',k])]:change(label+'.cell'+str(k),prime,path,9999)
 change('ledger.cell'+str(k),records[-1],['ledger','totals',k],9999)
for name,path,value in [('main.reserve',['rows',0,'main','value','reserve'],99),('main.class',['rows',0,'main','value','class'],99),('aux.grade',['rows',0,'aux','value','grade'],99),('flag.group',['rows',1,'flag','value','group'],99),('optional.variant',['rows',1,'aux'],{'kind':'MissingEntity'}),('reader.identity',['who'],'Slow'),('phase',['phase'],'Drain'),('iteration',['iteration'],999),('status',['status','kind'],'Failed')]:change(name,prime,path,value)
change('ping.code',read,['ping','values',0,'code'],999);change('ping.lagged',read,['ping','lagged'],True)
change('removed.actor',slow,['removed','values',0,'actor'],999);change('despawned.actor',slow,['despawned','values',0,'actor'],999)
change('seed.actor',records[0],['actors',0],999);change('final.epoch',records[-1],['ledger','epoch'],999);change('final.status',records[-1],['status','kind'],'Refused')
stage=next(x for x in records if x['kind']=='Stage');change('stage.outcome',stage,['outcome','kind'],'Failure');change('stage.label',stage,['stage'],'Other')
for name,record,path in [('row.order',prime,['rows']),('removed.order',slow,['removed','values']),('despawned.order',slow,['despawned','values'])]:
 value=copy.deepcopy(record);at=value
 for key in path:at=at[key]
 at[0],at[1]=at[1],at[0];assert cells([value])!=cells([record]);checks.append(name)
assert cells(records[:2])!=cells(list(reversed(records[:2])));checks.append('record.order')
text='quote" slash\\ newline\n nul\0 astral😀 combiningé';value={'text':text};rendered=compact(value);assert cells([value])==list(map(ord,'1'))+[0]+list(map(ord,str(len(rendered))))+[0]+list(map(ord,rendered));checks.append('escaping.scalar.length')
changed=f['tuple'].copy();changed[-1]^=1;assert changed!=f['tuple'];checks.append('fulltuple.changed.originalfoldretained')
assert fixtures[0]['tuple']==fixtures[1]['tuple'];assert fixtures[0]['rawActorMap']!=fixtures[1]['rawActorMap'];checks.append('logicalsame.rawnamespace_distinct')
print(json.dumps({'status':'FINITE_MODEL_SENSITIVITY_PASS','scope':'Fixture-only, not runtime compiling mutants or universal encoding proof. Full actual role oracle comparisons remain mandatory.','count':len(checks),'controls':checks,'fixtureSHA256':hashlib.sha256(raw).hexdigest()},indent=2))
