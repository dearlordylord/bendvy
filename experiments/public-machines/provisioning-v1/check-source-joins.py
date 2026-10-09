"""No-child source/authority/raw joins; no runtime or proof inference."""
import hashlib,json,os,re
from pathlib import Path
HERE=Path(__file__).resolve().parent
ROOT=Path('/workspace/formal-proofs/bendvy')
def sha(path):return hashlib.sha256(Path(path).read_bytes()).hexdigest()
rows=json.loads((HERE/'SCENE-IMPORT-JOIN.json').read_text())
for row in rows:
 source=Path(row['source']);assert sha(source)==row['sha256']
 def routed(match):
  imp=match.group(1)
  if imp=='Base':return match.group(0)
  target=(source.parent/imp).resolve()
  if target==ROOT/'experiments/public-machines/machine.bend':target=ROOT/'src/ecs/machine.bend'
  elif target==ROOT/'experiments/public-machines/world.bend':target=ROOT/'src/ecs/machine-world.bend'
  elif target.parent==source.parent:target=HERE/'scene'/target.name
  return 'import '+os.path.relpath(target,HERE/'scene')
 expected=re.sub(r'^import (\S+)',routed,source.read_text(),flags=re.M)
 if source.name=='provider.bend':
  expected=expected.replace('  LevelChanged{}\ntype ConditionEnv','  LevelChanged{}\n  FlowExists{}\n  LevelExists{}\ntype ConditionEnv')
  expected=expected.replace('    case LevelChanged{}, ConditionEnv{_,level}: M.changed(~S,~LevelToken,~Level,level)','    case LevelChanged{}, ConditionEnv{_,level}: M.changed(~S,~LevelToken,~Level,level)\n    case FlowExists{}, ConditionEnv{flow,_}: slot_exists(~S,~FlowToken,~Flow,flow)\n    case LevelExists{}, ConditionEnv{_,level}: slot_exists(~S,~LevelToken,~Level,level)')
  pos=expected.index('def condition_leaf(')
  helper='def slot_exists(~S: Data,~Token: Data,~V: Data,slot: M.Slot<S,Token,V>) -> Bool:\n  match slot:\n    case M.Missing{}: False{}\n    case M.Present{_,_,_,_}: True{}\n\n'
  expected=expected[:pos]+helper+expected[pos:]
  expected=expected.replace('    case LevelChanged{}: [2]','    case LevelChanged{}: [2]\n    case FlowExists{}: [1]\n    case LevelExists{}: [2]')
  expected=expected.replace('  condition_ready(~S,condition_provisioned(~S,condition_needs(~S,tree),env),tree,env)','  ConditionValue{Cond.evaluate(~Atom<S>,~ConditionEnv<S>,~(atom => values => condition_leaf(~S,atom,values)),tree,env)}')
 if source.name=='application.bend':
  expected=expected.replace('    case P.LevelChanged{}: "LevelChanged"','    case P.LevelChanged{}: "LevelChanged"\n    case P.FlowExists{}: "FlowExists"\n    case P.LevelExists{}: "LevelExists"')
 assert (HERE/'scene'/row['copy']).read_text()==expected,source.name
normal=(HERE/'declared.bend').read_text()
old='case Req.Missing{owners,world,_}: App.FrameResult{owners,world,"machine-provision-rejected"}'
new='case Req.Missing{owners,world,_}: App.named(~S,owners,name,items,W.namespace(~S,~P.Store<S>,~P.Resources<S>,~Unit,world))'
assert normal.count(old)==1
assert (HERE/'declared-missing-mutant.bend').read_text()==normal.replace(old,new)
assert (HERE/'main-mutant.bend').read_text()==(HERE/'main.bend').read_text().replace('import declared.bend as Decl','import declared-missing-mutant.bend as Decl')
checks={'initial':0,'requirements':0,'declared':0,'main':0,'main-mutant':0,'generic-type':0,'negative-schema':1,'negative-token':1,'negative-owner':1,'negative-registered-owner':1,'negative-read':1}
for name,exit_code in checks.items():
 directory=HERE/'final-source-v1';receipt=json.loads((directory/(name+'.json')).read_text())
 assert receipt['exit']==exit_code and receipt['failure'] is None and receipt['unchanged']
 assert receipt['capSeconds']==5 and receipt['argv'][:3]==['/usr/bin/taskset','-c','5']
 for path,digest in receipt['pins'].items():assert sha(path)==digest,path
 for channel,row in receipt['captures'].items():
  raw=(directory/(name+'.'+channel)).read_bytes()
  assert hashlib.sha256(raw).hexdigest()==row['sha256'] and len(raw)==row['bytes']
for name,fragment in {'negative-schema':'D.Plan<P.SchemaB>','negative-token':'observed : Undeclared','negative-owner':'world (consumed more than once)','negative-registered-owner':'owners (consumed more than once)','negative-read':'observed : Cap.ValueRead'}.items():
 assert fragment in (HERE/'final-source-v1'/(name+'.stderr')).read_text(),name
print('12 source reuse joins, sole reached mutation and 11 current source controls PASS; no backend/proof credit')
