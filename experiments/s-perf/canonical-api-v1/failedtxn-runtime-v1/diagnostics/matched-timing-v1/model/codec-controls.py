"""Finite independent grammar sensitivity fixtures, not a compiling subject mutant."""
from pathlib import Path
import copy,hashlib,json
compact=lambda value:json.dumps(value,separators=(',',':'),ensure_ascii=False)
def natural(value):return [ord(c)for c in str(value)]+[0]
def encode(records):
 out=natural(len(records))
 for record in records:
  text=compact(record);out+=natural(len(text))+[ord(c)for c in text]
 return out
def fold(values):
 out=0
 for value in values:out=(out*33+value)&0xffffffff
 return out
def leaves(value,path=()):
 if isinstance(value,dict):
  for key,child in value.items():yield from leaves(child,path+(key,))
 elif isinstance(value,list):
  for index,child in enumerate(value):yield from leaves(child,path+(index,))
 else:yield path,value
def altered(value,path,replacement):
 result=copy.deepcopy(value);parent=result
 for key in path[:-1]:parent=parent[key]
 parent[path[-1]]=replacement
 return result
fixture=[
 {'kind':'Callback','who':'B','mode':'Fail','iteration':0,'capture':2,'readerStatus':1,'readerError':7,'reading':{'messages':[{'code':0}],'lagged':False},'outcome':{'kind':'Failure','code':7},'reservation':{'kind':'Reserved','actor':65},'payload':{'coordinates':{'a':0,'b':200,'c':300,'d':400},'frame':7},'writes':[{'kind':'Found','value':{'coordinates':{'a':11,'b':2,'c':3,'d':4},'frame':7}},{'kind':'Absent'},{'kind':'Missing'}],'ledger':{'totals':{'a':101,'b':101,'c':102,'d':103},'epoch':4},'rejected':None,'error':None,'pendingLookup':{'kind':'Missing'}},
 {'kind':'Boundary','iteration':0,'phase':'disposed','rows':[{'actor':1,'main':{'kind':'Found','value':{'coordinates':{'a':1,'b':2,'c':3,'d':4},'frame':7}},'aux':{'kind':'Absent'},'flag':{'kind':'Missing'}}],'ledger':{'totals':{'a':101,'b':101,'c':102,'d':103},'epoch':4},'pendingA':{'actor':65,'result':{'kind':'Missing'}},'latestFailed':{'actor':66,'result':{'kind':'Missing'}},'retryB':None,'allFailed':[{'actor':66,'result':{'kind':'Missing'}}],'captures':{'A':1,'B':3}},
 {'kind':'Escaping','value':'A\0B\b\f\n\r\t"\\e\u0301😀','natural':2**80}
]
gold=encode(fixture);checksum=fold(gold);controls=[]
def reject(name,records=None,tuple_value=None):
 actual=encode(records)if records is not None else tuple_value
 assert actual!=gold,name
 # Retaining the original fold cannot satisfy the independent full-tuple join.
 assert not(actual==gold and checksum==fold(gold)),name
 controls.append(name)
for path,value in leaves(fixture):
 replacement=not value if isinstance(value,bool)else value+1 if isinstance(value,int)else value+'!'if isinstance(value,str)else {'kind':'Some'}
 reject('field:'+repr(path),altered(fixture,path,replacement))
reject('record-order',list(reversed(fixture)))
changed=copy.deepcopy(fixture);changed[0]=dict(reversed(list(changed[0].items())));reject('key-order',changed)
reject('record-count',tuple_value=[ord('9'),0]+gold[len(natural(len(fixture))):])
reject('record-scalar-length',tuple_value=gold[:2]+[ord('9'),0]+gold[2+len(natural(len(compact(fixture[0])))):])
reject('last-tuple-value',tuple_value=gold[:-1]+[gold[-1]+1])
assert json.loads(compact(fixture))==fixture
result={'scope':'finite model grammar/sensitivity controls only; not execution of Bend/TS codec, not compiling source mutants or universal proof','positive':1,'rejected':len(controls),'cases':controls,'tupleValues':len(gold),'fold':checksum,'unicodeScalarCount':len(fixture[2]['value']),'sha256':hashlib.sha256(compact(gold).encode()).hexdigest()}
Path(__file__).with_name('CODEC-CONTROLS.json').write_text(json.dumps(result,indent=2)+'\n')
print(json.dumps(result))
