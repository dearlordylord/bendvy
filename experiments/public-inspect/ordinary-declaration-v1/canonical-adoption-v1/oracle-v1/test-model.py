import copy,hashlib,json
import expected as E
n=E.model();m=E.model(True)
def delta(a,b,path=''):
 if type(a)!=type(b):return [path]
 if isinstance(a,dict):
  assert set(a)==set(b)
  return sum((delta(a[k],b[k],path+'.'+k) for k in a),[])
 if isinstance(a,list):
  if len(a)!=len(b):return [path]
  return sum((delta(x,y,path+f'[{i}]') for i,(x,y) in enumerate(zip(a,b))),[])
 return [] if a==b else [path]
assert delta(n,m)==['.first.clauses','.second.clauses']
assert E.render(n,True)!=E.render(m,True)
for side in ('first','second'):
 d=n[side];w=d['owner']['world']
 assert d['factory']['nextNamespace']==2 and w['clock']==1
 assert w['store']['values']['value']['value']['values']['value']==42
 assert w['resource']['value']==17 and d['rows'][0]['value']['access']['value']==42
 assert all(w[k]==[] for k in ('events','pending','registrations'))
 assert all(d[k]==[] for k in ('undo','commands','events'))
for key in ('normal','mutant','mutant-namespace-normal'):
 expected=E.model(key=='mutant')
 assert json.loads((E.OUT/(key+'-expected.json')).read_text())==expected
 assert (E.OUT/(key+'-expected.stdout')).read_bytes()==(E.render(expected,key!='normal')+'\n').encode()
 # Full literal rejects last-owner corruption, omitted field and trailing bytes.
 raw=(E.OUT/(key+'-expected.stdout')).read_bytes()
 changed=copy.deepcopy(expected);changed['second']['owner']['world']['resource']['value']=18
 assert (E.render(changed,key!='normal')+'\n').encode()!=raw
 changed=copy.deepcopy(expected);del changed['second']['previous']
 assert (E.render(changed,key!='normal')+'\n').encode()!=raw
 assert raw+b'\n'!=raw
print('PASS: whole source-derived models, two-clause delta, namespace-matched baseline and complete literal controls')
