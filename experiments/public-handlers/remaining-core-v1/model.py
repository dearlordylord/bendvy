"""Serialize the unchanged independent capability-v2 oracle in source observer order.
No runtime files are read. Native/JS use the same IO.print ordinary entry.
"""
from pathlib import Path
import gzip, hashlib, json
HERE=Path(__file__).resolve().parent
FIELDS=['namespace','entity','component','resource','locals','current','pending','previous','changed','streamReader','publications','publicationTicks','deliveries','tick','structuralApplied','prefix','clock','pendingStructural','registryIds','registryCursors']
LIST_SHOW_FIELDS={'locals','publications','publicationTicks','deliveries','prefix','registryIds','registryCursors'}
def rendered(field,value):
 if field in LIST_SHOW_FIELDS:return '['+', '.join(json.dumps(item,separators=(',',':')) for item in value)+']'
 return json.dumps(value,separators=(',',':'))
CASES=['initial','failed','retry','next','condition_false','requirement_missing','missing_reader']
def report(schema):
 rows=json.loads((HERE/'expected-draft.json').read_text())['rows'];lines=[]
 for case in CASES:
  name=schema+'_'+case;row=rows[name];assert set(row)==set(FIELDS)
  lines.append(name+'|'+'{'+','.join(json.dumps(field)+':'+rendered(field,row[field]) for field in FIELDS)+'}'+'\n')
 return ''.join(lines).encode()
if __name__=='__main__':
 for schema in ['A','B']:
  raw=report(schema);(HERE/(schema+'-expected.stdout.gz')).write_bytes(gzip.compress(raw,mtime=0));print(schema,len(raw),hashlib.sha256(raw).hexdigest())
