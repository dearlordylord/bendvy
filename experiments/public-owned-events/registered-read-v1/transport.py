"""Source-derived complete DTO transport; no runtime observation supplies defaults."""
import json
import os
from pathlib import Path

ENTRY=Path(__file__).resolve().parent/'main.bend'
ROOT=Path('/workspace/formal-proofs/bendvy')
O='observation.bend';F='fixture.bend';D='direct-controls.bend';L='log.bend'
E=str(ROOT/'src/ecs/event-runtime.bend');W=str(ROOT/'src/ecs/world.bend')
records={
 'Batch':('main',[('standard','Trace'),('capacity','Trace'),('missing','DirectView'),('duplicateRows','DirectView'),('duplicatePublication','DirectView'),('ownedOutput','DirectView')]),
 'Snapshot':(O,[('label','String'),('runtime','RuntimeView'),('fast','ReaderView'),('slow','ReaderView'),('reads',['ReadCompletion']),('retired',['RowView']),('refused',['RowView']),('errors',['Refusal']),('ok','Bool')]),
 'RuntimeView':(O,[('namespace','U32'),('statuses',['ReaderStatus']),('world','WorldMeta'),('batches',['BatchEvent']),('positions',['Position']),('nextReader','U32'),('tick','Nat'),('frameStart','Nat'),('boundary','Nat'),('capacity','Nat'),('droppedThrough','Nat'),('log','LogView')]),
 'ReaderView':(O,[(k,'String' if k=='name' else ['String'] if k=='access' else 'U32') for k in ['namespace','id','registryId','registryNamespace','actualRegistryId','name','access','cursor']]),
 'WorldMeta':(F,[(k,t) for k,t in [('namespace','U32'),('nextId','U32'),('highWater','U32'),('capacity','U32'),('depth','Nat'),('events',['U32']),('registrations',['RegistrationMeta']),('nextSystemId','U32'),('clock','U32')]]),
 'ReaderStatus':(E,[('id','U32'),('cursor','Nat'),('registeredAt','Nat'),('unread','Nat'),('lagged','Bool')]),
 'Position':(E,[('id','U32'),('cursor','Nat'),('registeredAt','Nat')]),
 'BatchEvent':(E,[('tick','Nat'),('values',['U32'])]),
 'RegistrationMeta':(W,[('id','U32'),('name','String'),('access',['String'])]),
 'PayloadView':(O,[('cells',['U32']),('sentinel',['U32'])]),
 'RowView':(O,[('key','U32'),('payload','PayloadView')]),
 'LogView':(O,[('seen',['U32']),('rows',['RowView'])]),
 'PacketView':(F,[('key','U32'),('cells',['U32'])]),
 'Request':(F,[('name','String'),('fail','Bool')]),
 'View':(F,[('name','String'),('keys',['U32']),('packets',['PacketView']),('lagged','Bool'),('errors',['Refusal'])]),
 'DirectView':(D,[('log','LogView'),('value','MaybeCells'),('errors',['Refusal']),('refused',['RowView'])]),
}
sums={
 'Trace':('main',{'Trace':[('snapshots',['Snapshot'])],'SetupRefused':[]}),
 'ReadCompletion':(F,{'ReadSucceeded':[('view','View')],'ReadBodyFailed':[('error','ReadError')],'ReadRejected':[('request','Request')]}),
 'ReadError':(F,{'ReadFailed':[('view','View')]}),
 'Refusal':(L,{'DuplicateKey':[('key','U32')],'MissingKey':[('key','U32')]}),
}
def name(file,tag):
 if file in ('main','Base'):return tag
 target=(ENTRY.parent/file if not file.startswith('/') else Path(file)).resolve()
 return os.path.relpath(target,ENTRY.parent.resolve())[:-5]+'.'+tag

def fields_check(value,fields):
 assert type(value) is dict and set(value)=={k for k,_ in fields}, 'field inventory differs'

def render(t,x):
 if isinstance(t,list):
  assert type(x) is list
  return '['+', '.join(render(t[0],v) for v in x)+']'
 if t=='U32':assert type(x) is int and 0<=x<2**32;return str(x)
 if t=='Nat':assert type(x) is dict and set(x)=={'nat'} and type(x['nat']) is int and x['nat']>=0;return str(x['nat'])+'n'
 if t=='String':assert type(x) is str;return json.dumps(x)
 if t=='Bool':assert type(x) is bool;return 'True{}' if x else 'False{}'
 if t in records:
  file,fields=records[t];fields_check(x,fields)
  tag='Batch' if t=='BatchEvent' else t
  return name(file,tag)+'{'+', '.join(render(ft,x[k]) for k,ft in fields)+'}'
 assert type(x) is dict and len(x)==1
 tag,value=next(iter(x.items()))
 if t=='MaybeCells':
  assert tag in ('Some','None')
  if tag=='None':assert value=={};return 'None{}'
  return 'Some{'+render(['U32'],value)+'}'
 file,variants=sums[t];assert tag in variants;fields=variants[tag];fields_check(value,fields)
 return name(file,tag)+'{'+', '.join(render(ft,value[k]) for k,ft in fields)+'}'

class Parser:
 def __init__(self,text):self.text=text;self.i=0
 def literal(self,s):
  assert self.text.startswith(s,self.i),f'expected {s!r} at {self.i}'
  self.i+=len(s)
 def number(self,nat=False):
  start=self.i
  while self.i<len(self.text) and self.text[self.i].isdigit():self.i+=1
  digits=self.text[start:self.i];assert digits and (digits=='0' or not digits.startswith('0'))
  if nat:self.literal('n');return {'nat':int(digits)}
  value=int(digits);assert value<2**32;return value
 def fields(self,fields):
  self.literal('{');out={}
  for index,(k,t) in enumerate(fields):
   if index:self.literal(', ')
   out[k]=self.read(t)
  self.literal('}');return out
 def read(self,t):
  if isinstance(t,list):
   self.literal('[');out=[]
   if not self.text.startswith(']',self.i):
    out.append(self.read(t[0]))
    while self.text.startswith(', ',self.i):self.literal(', ');out.append(self.read(t[0]))
   self.literal(']');return out
  if t=='U32':return self.number()
  if t=='Nat':return self.number(True)
  if t=='String':
   value,length=json.JSONDecoder().raw_decode(self.text[self.i:]);assert type(value) is str
   self.i+=length;return value
  if t=='Bool':
   if self.text.startswith('True{}',self.i):self.literal('True{}');return True
   self.literal('False{}');return False
  if t in records:
   file,fields=records[t];self.literal(name(file,'Batch' if t=='BatchEvent' else t));return self.fields(fields)
  if t=='MaybeCells':
   if self.text.startswith('None{}',self.i):self.literal('None{}');return {'None':{}}
   self.literal('Some{');value=self.read(['U32']);self.literal('}');return {'Some':value}
  file,variants=sums[t]
  for tag,fields in variants.items():
   token=name(file,tag)
   if self.text.startswith(token+'{',self.i):self.literal(token);return {tag:self.fields(fields)}
  raise AssertionError(f'unknown {t} constructor at {self.i}')

def parse(raw):
 assert type(raw) is bytes
 text=raw.decode('utf-8');p=Parser(text);value=p.read('Batch');p.literal('\n');assert p.i==len(text),'trailing bytes'
 assert (render('Batch',value)+'\n').encode()==raw,'noncanonical transport'
 return value
