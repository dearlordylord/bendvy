"""Strict source-typed whole DTO transport. No field defaults/normalization."""
import importlib.util,json,os
from pathlib import Path
HERE=Path(__file__).resolve().parent
ROOT=Path('/workspace/formal-proofs/bendvy')
PARSER=ROOT/'experiments/public-simulation/bend-v1/parse-report.py'
def inventory(entry):
 entry=Path(entry).resolve();home=entry.parent;base=home.parent
 m=str(base/'main.bend');o=str(base/'observation.bend');i=str(ROOT/'experiments/public-decode/complete-v1/controls.bend');d=str(ROOT/'experiments/public-decode/typed.bend');w=str(ROOT/'src/ecs/world.bend');l=str(ROOT/'src/ecs/lifecycle.bend')
 # A type selects exact source constructor + ordered complete fields.
 def record(module,tag,fields):return (module,{tag:fields})
 fields=lambda **kw:list(kw.items())
 maybe=lambda t:('Base',{'None':[],'Some':[('value',t)]})
 t={
 'Report':record(str(entry),'Report',fields(baseline='Baseline',extension='Extension')),
 'Baseline':record(m,'Report',fields(insert='Cases',spawn='Cases',resource='Cases',otherSchema='Cases',foreign='Foreign')),
 'Cases':record(m,'Cases',[(k,'Observation') for k in ('array3','array128','array256','lateInvalid','struct64','nullableNull','nestedValid','nestedMissing')]),
 'Observation':(m,{'Observed':[('trace','Trace')],'SetupRefused':[('error','WorldError')],'CreateRefused':[('resource','PayloadView')]}),
 'Trace':record(m,'Trace',fields(before='Snapshot',after='Snapshot',flushed='Snapshot',outcome='Outcome',canonical=maybe('Raw'),seedPrevious=maybe('PayloadView'))),
 'Outcome':(m,{'ValidationRefused':fields(incoming='PayloadView',error='Error'),'Replaced':fields(original='Raw',previous=maybe('PayloadView'),handle=maybe('U32')),'OperationRefused':fields(original='Raw',incoming=maybe('PayloadView'),error='WorldError')}),
 'Foreign':(m,{'Foreign':fields(first='Snapshot',result='Observation'),'ForeignSetupRefused':[]}),
 'Snapshot':record(o,'Snapshot',fields(meta='Meta',live=['Bool'],column='ColumnView',resource='PayloadView',pending='U32')),
 'Meta':record(o,'Meta',fields(namespace='U32',nextId='U32',highWater='U32',capacity='U32',depth='Nat',events=['Unit'],registrations=['RegistrationMeta'],nextSystemId='U32',clock='U32')),
 'ColumnView':record(o,'ColumnView',fields(supported='Bool',slots=[maybe('PayloadView')],stamps=['Entry'])),
 'PayloadView':record(o,'PayloadView',fields(raw='Raw',sentinel=['U32'])),
 'Entry':record(l,'Entry',fields(id='U32',stamp='Stamp')),
 'Stamp':record(l,'Stamp',fields(added='U32',changed='U32')),
 'RegistrationMeta':record(w,'RegistrationMeta',fields(id='U32',name='String',access=['String'])),
 'WorldError':(w,{k:[] for k in ('MissingEntity','CapacityExceeded','NamespaceExhausted','SystemIdExhausted')}),
 'Unit':('Base',{'Unit':[]}),
 'Raw':(d,{'Missing':[],'Null':[],'Number':fields(value='U32'),'SignedInteger':fields(negative='Bool',magnitude='Nat'),'Float':fields(value='F32'),'Binary64':fields(high='U32',low='U32'),'Text':fields(value='String'),'Utf16Text':fields(units=['U32']),'Boolean':fields(value='Bool'),'Handle':fields(namespace='U32',id='U32'),'Array':fields(items=['Raw']),'Object':fields(fields=['Field'])}),
 'Field':record(d,'Field',fields(name='String',value='Raw')),
 'Error':(d,{'Invalid':fields(path='String',expected='String',actual='Raw'),'FuelExhausted':fields(path='String')}),
 'Checked':(d,{'Accepted':fields(value='Raw'),'Rejected':fields(error='Error')}),
 'DecodeObservation':record(i,'Observation',fields(originalRaw='Raw',sentinel=['U32'],checked='Checked')),
 'Extension':record(str(entry),'Extension',[(k,'DecodeObservation' if k in ('decodeOverrides','decodeFallsBack') else 'Observation') for k in ('plain','transient','resultRejectsDecodeAccepts','resultAccepts','decodeOverrides','decodeFallsBack','literalAccepts','literalRejects','handleAccepts','handleForeign','handleZero','handleWrongType')]),
 }
 def name(module,tag):return tag if module=='Base' or module==str(entry) else os.path.relpath(Path(module).with_suffix(''),entry.parent)+'.'+tag
 return t,name

def codec(value,typ,types,name,encode):
 if isinstance(typ,list):
  assert type(value) is list
  return [codec(v,typ[0],types,name,encode) for v in value]
 if isinstance(typ,str) and typ in ('U32','Nat','Bool','String','F32'):
  if typ=='U32':assert type(value) is int and 0<=value<2**32;return value
  if typ=='Nat':
   if encode:assert type(value) is int and value>=0;return {'nat':value}
   assert type(value) is dict and set(value)=={'nat'} and type(value['nat']) is int and value['nat']>=0;return value['nat']
  if typ=='String':assert type(value) is str;return value
  if typ=='Bool':
   if encode:assert type(value) is bool;return {'constructor':'True' if value else 'False','fields':[]}
   assert type(value) is dict and set(value)=={'constructor','fields'} and value['constructor'] in ('True','False') and value['fields']==[];return value['constructor']=='True'
  # No floating display is present in this consuming cohort. Never silently
  # coerce an unsupported token to an integer or normalize its representation.
  raise AssertionError('F32 print transport requires separate source-backed qualification')
 module,variants=types[typ] if type(typ) is str else typ
 assert type(value) is dict
 if encode:
  assert '$' in value and type(value['$']) is str and value['$'] in variants
  tag=value['$'];fs=variants[tag];assert set(value)=={'$',*(k for k,_ in fs)}
  return {'constructor':name(module,tag),'fields':[codec(value[k],ft,types,name,True) for k,ft in fs]}
 assert set(value)=={'constructor','fields'} and type(value['constructor']) is str and type(value['fields']) is list
 matches=[tag for tag in variants if name(module,tag)==value['constructor']];assert len(matches)==1,'wrong nominal constructor'
 tag=matches[0];fs=variants[tag];assert len(value['fields'])==len(fs),'field count differs'
 return {'$':tag,**{k:codec(v,ft,types,name,False) for (k,ft),v in zip(fs,value['fields'])}}
def parser():
 spec=importlib.util.spec_from_file_location('strict_bend_structural',PARSER);p=importlib.util.module_from_spec(spec);exec(compile(PARSER.read_bytes(),str(PARSER),"exec"),p.__dict__);return p

def render(expected,entry):
 types,name=inventory(entry);return (parser().render(codec(expected,'Report',types,name,True))+'\n').encode()
def parse(raw,entry):
 assert type(raw) is bytes
 p=parser();term=p.parse(raw.decode());assert (p.render(term)+'\n').encode()==raw,'noncanonical complete output'
 types,name=inventory(entry);return codec(term,'Report',types,name,False)
