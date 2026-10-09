"""Independent prior neutral models plus source-only nominal rebinding; no output input."""
from pathlib import Path
import json,types,hashlib,re
ROOT=Path('/workspace/formal-proofs/bendvy')
SOURCE=Path('/workspace/formal-proofs/bendvy-worktrees/parity-53-canonical-capability/experiments/public-owned-events/declaration-read-v1/canonical-capability-v1/reached-provide-v1/source')
HERE=Path(__file__).resolve().parent
used={}
def source_load(name,path):
 path=Path(path).resolve();raw=path.read_bytes();used[str(path)]=hashlib.sha256(raw).hexdigest()
 m=types.ModuleType(name);m.__file__=str(path);exec(compile(raw,str(path),'exec'),m.__dict__)
 class Loader:
  def __init__(self,path):self.path=path
  def exec_module(self,module):
   path=Path(self.path).resolve();raw=path.read_bytes();used[str(path)]=hashlib.sha256(raw).hexdigest();module.__file__=str(path);exec(compile(raw,str(path),'exec'),module.__dict__)
   if 'importlib'in module.__dict__:module.importlib=types.SimpleNamespace(util=types.SimpleNamespace(spec_from_file_location=spec,module_from_spec=make_module))
 def spec(name,path):return types.SimpleNamespace(name=name,path=path,loader=Loader(path))
 def make_module(s):m=types.ModuleType(s.name);m.__file__=str(s.path);return m
 if 'importlib'in m.__dict__:m.importlib=types.SimpleNamespace(util=types.SimpleNamespace(spec_from_file_location=spec,module_from_spec=make_module))
 return m
roles={
 'registered':('experiments/public-owned-events/declaration-read-v1/oracle-v1/registered-expected.json','experiments/public-owned-events/declaration-read-v1/transport.py','registered','declaration-read-v1/registered-v1/main.bend'),
 'full':('experiments/public-owned-events/system-event-v1/generic-v1/oracle-v1/full-expected.json','experiments/public-owned-events/system-event-v1/generic-v1/transport.py','full','system-event-v1/generic-v1/main.bend'),
 'second':('experiments/public-owned-events/system-event-v1/generic-v1/oracle-v1/second-expected.json','experiments/public-owned-events/system-event-v1/generic-v1/transport.py','second','system-event-v1/generic-v1/second-schema.bend')}
def model(role):
 neutral,transport,parserrole,entry=roles[role];path=ROOT/neutral;used[str(path)]=hashlib.sha256(path.read_bytes()).hexdigest();value=json.loads(path.read_bytes())
 m=source_load('independent_'+role,ROOT/transport);p,t=m.parser(parserrole);p.ENTRY=SOURCE/entry
 old=str(ROOT/'experiments/public-owned-events/declaration-read-v1/registered-v1');new=str(SOURCE/'declaration-read-v1/registered-v1')
 p.records={k:(f.replace(old,new),fields)for k,(f,fields)in p.records.items()}
 p.sums={k:(f.replace(old,new),fields)for k,(f,fields)in p.sums.items()}
 raw=(p.render(t,value)+'\n').encode();r=p.Parser(raw.decode());observed=r.read(t);r.literal('\n');assert r.i==len(r.text)and observed==value
 return value,raw
if __name__=='__main__':
 for role in roles:
  value,raw=model(role);(HERE/(role+'-expected.json')).write_text(json.dumps(value,indent=2)+'\n');(HERE/(role+'-expected.stdout')).write_bytes(raw)
 pins=dict(used)
 def visit(path):
  path=path.resolve();key=str(path)
  if key in pins:return
  raw=path.read_bytes();pins[key]=hashlib.sha256(raw).hexdigest()
  for dep in re.findall(r'^import (\S+)',raw.decode(),re.M):visit(Path('/home/node/.bend/bend2/base.bend')if dep=='Base'else path.parent/dep)
 for row in roles.values():visit(SOURCE/row[3])
 (HERE/'source-basis.json').write_text(json.dumps({'sourceCommit':'9bd4496e','scope':'Source-only unchanged complete neutral models; raw namespace rebound before backend','pins':pins},indent=2)+'\n')
 for role in roles:
  raw=(HERE/(role+'-expected.stdout')).read_bytes();print(role,len(raw),hashlib.sha256(raw).hexdigest())
