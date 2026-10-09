"""No-child exact import-only consumer comparison and retained source diagnostics."""
import hashlib,json,re
from pathlib import Path
HERE=Path(__file__).resolve().parent
comparison=json.loads((HERE/'SOURCE-COMPARISON.json').read_text());mapping={x['original']:x['candidate']for x in comparison['files']}
for row in comparison['files']:
 p=Path(row['original']);target=Path(row['candidate']);assert hashlib.sha256(p.read_bytes()).hexdigest()==row['originalSHA256'];assert hashlib.sha256(target.read_bytes()).hexdigest()==row['candidateSHA256']
 def imp(m):
  n=m.group(1)
  return m[0]if n=='Base'else'import '+mapping.get(str((p.parent/n).resolve()),str((p.parent/n).resolve()))
 expected=re.sub(r'^import (\S+)',imp,p.read_text(),flags=re.M)
 if p.name=='declaration.bend':
  expected='\n'.join(line for line in expected.splitlines()if' as Scoped'not in line)+'\n'
  expected=expected.replace('Scoped.provide(~P,~Request,~Projection,~Args,~Observation,~at(~S,~P,~Request,~Projection,~declaration),~body,owner,args)','Cap.invoke_owned(~(H => Cap.Request<H,Request,Projection>),~Args,~Observation,~(H => read => input => ctx => body(H,read,ctx,input)),~P,~Query.grant(~S,~P,~Cap.Request<P,Request,Projection>,declaration),args,owner)')
 assert target.read_text()==expected
phrases={'args-duplication-negative':'args (consumed more than once)','owner-duplication-negative':'owner (consumed more than once)','write-negative':'ValueWrite','undeclared-negative':'Unit','cross-schema-negative':'Declaration<Other','escape-negative':'Cap.Request<H'}
for label in ['generic','registered','system']+list(phrases):
 receipt=json.loads((HERE/'source-checks'/f'{label}.json').read_text());assert receipt['exit']==(1 if label in phrases else 0)and receipt['failure']is None
 if label!='generic':
  assert receipt['unchangedAfter']
  for key in ['stdout','stderr']:
   ref=receipt[key];data=Path(ref['path']).read_bytes();assert len(data)==ref['bytes']and hashlib.sha256(data).hexdigest()==ref['sha256']
 if label in phrases:assert phrases[label]in(HERE/'source-checks'/f'{label}.stderr').read_text()
print('Exact16 source comparison, 3 accepted consumers/6 intended refusals PASS; no backend qualification')
