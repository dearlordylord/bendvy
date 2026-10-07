"""Freeze independent existing models; historical bytes are only a formatter control."""
from pathlib import Path
import ast,hashlib,importlib.util,json,tarfile
HERE=Path(__file__).resolve().parent
sha=lambda b:hashlib.sha256(b).hexdigest()
def load(p,n):
 s=importlib.util.spec_from_file_location(n,p);m=importlib.util.module_from_spec(s);s.loader.exec_module(m);return m
life=load(HERE/'query-lifetime/model.py','independent_lifetime')
def rows(rs):
 def cell(c):
  v=c['value'];return c['key']+'='+('none' if v is None else '['+''.join('1:'+str(x)+',' for x in v)+']' if isinstance(v,list) else '1:'+str(v))+';'
 return ''.join('1:'+str(r['id'])+'['+''.join(str(x)+',' for x in r['component'])+']{'+''.join(cell(c) for c in r['cells'])+'}|' for r in rs)
lines=[]
for root in life.literal():
 lines.append(root['root'])
 for phase in root['phases']:
  lines.append(phase['phase'])
  lines.extend(n+'='+rows(rs) for n,rs in phase['rows'].items())
 lines.append('retained='+rows(root['retained']))
 lines.append('owners=100,10,;200,20,21,;300,30,31,32,33,;400,40,41,42,43,44,45,46,47,;|2,5,:3,|events=|meta=1,6,5,8,3,77,4,0|pending=0')
lifetime='\n'.join(lines)+'\n'
with tarfile.open(HERE.parent/'promotion-capsules/lifetime.tar.gz') as t:
 b=t.extractfile(next(m for m in t.getmembers() if m.name.endswith('normal-run-js.stdout'))).read();assert lifetime.encode()==b
model=load(HERE/'cleanup-model.py','independent_cleanup')
def expected(path,allowed,env):
 tree=ast.parse(path.read_text());body=[n for n in tree.body if isinstance(n,ast.FunctionDef) and n.name=='expected' or isinstance(n,ast.Assign) and any(isinstance(x,ast.Name) and x.id in allowed for x in n.targets)];exec(compile(ast.Module(body=body,type_ignores=[]),str(path),'exec'),env);return '\n'.join(env['expected']())+'\n'
cleanup=expected(HERE/'cleanup-controls.py',{'OWNERS','CASES'},{'model':model})
large=expected(HERE/'large-controls.py',{'OWNERS'},{})
oracles={'lifetime':lifetime,'cleanup':cleanup,'large':large};(HERE/'current-normal-controls-oracles.json').write_text(json.dumps({'scope':'Already-authored complete independent model oracles, frozen before new current runtime.','outputs':oracles,'models':{str(p):sha(p.read_bytes()) for p in [HERE/'query-lifetime/model.py',HERE/'cleanup-model.py',HERE/'cleanup-controls.py',HERE/'large-controls.py']}},indent=2)+'\n');print({k:len(v.splitlines()) for k,v in oracles.items()})
