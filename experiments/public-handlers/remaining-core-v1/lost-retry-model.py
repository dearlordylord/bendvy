"""Source-derived reached lost-retry counteroracle; never reads runtime files.
Only omitted H.requeued M.queue changes the existing caller's trace.
After first failed transition retained prior exit/Local effects stay committed.
Later markers are idle; reader activation/completion still execute as authored.
"""
from pathlib import Path
import copy,gzip,hashlib,importlib.util,json
HERE=Path(__file__).resolve().parent
spec=importlib.util.spec_from_file_location('normal_handler_model',HERE/'model.py');m=importlib.util.module_from_spec(spec);spec.loader.exec_module(m)
def report(schema):
 rows=json.loads((HERE/'expected-draft.json').read_text())['rows'];failed=copy.deepcopy(rows[schema+'_failed']);failed['pending']=None;out=[]
 for case in m.CASES:
  if case=='failed':row=copy.deepcopy(failed)
  elif case in ('retry','next','missing_reader'):
   row=copy.deepcopy(failed);row['tick']=3 if case=='next' else 2
   if case=='missing_reader':row['streamReader']=None
   else:
    row['streamReader']['position']={'cursor':row['tick'],'registeredAt':2};row['registryCursors'][3]=row['clock']
  else:row=rows[schema+'_'+case]
  out.append(schema+'_'+case+'|{'+','.join(json.dumps(f)+':'+m.rendered(f,row[f]) for f in m.FIELDS)+'}\n')
 return ''.join(out).encode()
if __name__=='__main__':
 for schema in ['A','B']:
  raw=report(schema);assert raw!=m.report(schema);(HERE/(schema+'-lost-retry-expected.stdout.gz')).write_bytes(gzip.compress(raw,mtime=0));print(schema,len(raw),hashlib.sha256(raw).hexdigest())
