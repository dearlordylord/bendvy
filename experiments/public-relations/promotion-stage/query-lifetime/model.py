"""Independent full row/phase model; never calls maintained graph helpers."""
import re
COMPONENTS={1:[100,10],2:[200,20,21],3:[300,30,31,32,33],4:[400,40,41,42,43,44,45,46,47]}
def query_rows(applied=False):
 forward={3:2 if applied else 1,2:1,5:1};inverse={1:[2,5] if applied else [3,2,5],2:[3] if applied else []}
 other={1:4,4:2};other_inverse={4:[1],2:[4]};result={}
 for name in ['other-optional','optional','outgoing','incoming','with-out','without-out','with-in','without-in','multi','cross-filters','empty']:
  rows=[]
  for id,component in COMPONENTS.items():
   target=forward.get(id);sources=inverse.get(id) or None;ot=other.get(id);os=other_inverse.get(id) or None
   include=(name not in ['outgoing','with-out','multi'] or target is not None) and (name not in ['incoming','with-in'] or sources is not None) and (name!='without-out' or target is None) and (name!='without-in' or sources is None) and (name!='multi' or os is None) and (name!='cross-filters' or ot is not None and target is None)
   if not include:continue
   cells=[]
   if name=='other-optional':cells=[{'key':'otherTarget','value':ot},{'key':'otherSources','value':os}]
   if name in ['optional','outgoing','multi']:cells.append({'key':'target','value':target})
   if name in ['optional','incoming','cross-filters']:cells.append({'key':'sources','value':sources})
   if name=='multi':cells.extend([{'key':'otherTarget','value':ot},{'key':'otherSources','value':os}])
   rows.append({'id':id,'component':component,'cells':cells})
  result[name]=rows
 return result

def row_list(encoded):
 rows=[]
 for row in encoded.split('|'):
  if not row:continue
  m=re.fullmatch(r'1:(\d+)\[([0-9,]*)\]\{(.*)\}',row);assert m,row;cells=[]
  for field in m[3].split(';'):
   if not field:continue
   key,value=field.split('=',1)
   if value=='none':value=None
   elif value.startswith('['):
    handles=[x for x in value[1:-1].split(',') if x];assert all(x.startswith('1:') for x in handles),'foreign inverse namespace';value=[int(x.split(':')[1]) for x in handles]
   else:assert value.startswith('1:'),value;value=int(value.split(':')[1])
   cells.append({'key':key,'value':value})
  rows.append({'id':int(m[1]),'component':[int(x) for x in m[2].split(',') if x],'cells':cells})
 return rows

def literal():
 return [{'root':root,'phases':[{'phase':phase,'rows':query_rows(phase=='applied')} for phase in ['initial','queued','applied']],'retained':query_rows()['optional']} for root in ['Workshop','Other']]
def portable(text):
 result=[];root=None;phase=None
 for line in text.splitlines():
  if line in ['Workshop','Other']:root={'root':line,'phases':[]};result.append(root)
  elif line in ['initial','queued','applied']:phase={'phase':line,'rows':{}};root['phases'].append(phase)
  elif line.startswith('retained='):root['retained']=row_list(line.split('=',1)[1])
  elif line and not line.startswith('owners='):
   name,rows=line.split('=',1);phase['rows'][name]=row_list(rows)
 return result

def validate(text,mutant=False):
 actual=portable(text);expected=literal();witnesses=[]
 assert [r['root'] for r in actual]==['Workshop','Other']
 for got,want in zip(actual,expected):
  assert [p['phase'] for p in got['phases']]==['initial','queued','applied']
  for gp,wp in zip(got['phases'],want['phases']):
   for name,rows in wp['rows'].items():
    if gp['rows'][name]!=rows:witnesses.append({'root':got['root'],'phase':gp['phase'],'query':name,'expected':rows,'actual':gp['rows'][name]})
  if got['retained']!=want['retained']:witnesses.append({'root':got['root'],'phase':'retained','expected':want['retained'],'actual':got['retained']})
 if mutant:assert witnesses,'no reached semantic witness'
 else:assert not witnesses,witnesses
 return actual,witnesses
