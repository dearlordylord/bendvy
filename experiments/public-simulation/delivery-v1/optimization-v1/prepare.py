"""Single reversible scenario continuation overlay; no children."""
import hashlib,json,shutil
from pathlib import Path
H=Path(__file__).resolve().parent
sha=lambda b:hashlib.sha256(b).hexdigest()
BASE=Path('/tmp/bendvy63-ordinary-delivery-plan-v6.json')
OLD=Path('/tmp/bendvy63-ordinary-delivery-stage-v1')
NEW=Path('/tmp/bendvy63-named-loop-stage-v1')
REL='experiments/public-simulation/bend-v1/scenario.bend'
def transform(s):
 s=s.replace(',next: App.Application<S> -> List<&2,Phase<S>> -> ScenarioRun<S>','').replace('next: App.Application<S> -> List<&2,Phase<S>> -> ScenarioRun<S>,','')
 for name in ['observed','executed','command']:
  begin=s.index('def '+name);end=s.index('\n',begin);line=s[begin:end];s=s[:begin]+line.replace('-> ScenarioRun<S>:','-> App.Application<S> & List<&2,Phase<S>>:')+s[end:]
 s=s.replace('next(app,Phase{snapshot,result} <> trace)','(app,Phase{snapshot,result} <> trace)').replace('observed(~S,result,trace,next,','observed(~S,result,trace,').replace('executed(~S,label,trace,next,','executed(~S,label,trace,')
 begin=s.index('def loop(');end=s.index('def initial_observed',begin)
 s=s[:begin]+"def loop(~S: Data,commands: List<&2,Actions.Command>,state: App.Application<S> & List<&2,Phase<S>>) -> ScenarioRun<S>:\n  match commands state:\n    case Nil{} Tuple{app,trace}: ScenarioRun{app,List.reverse(&2,Phase<S>,trace)}\n    case Con{head,rest} Tuple{app,trace}: loop(~S,rest,command(~S,head,app,trace))\n"+s[end:]
 return s.replace('loop(~S,Actions.commands(Unit{}),app,[Phase{snapshot,Actions.ReadersResult{result}}])','loop(~S,Actions.commands(Unit{}),(app,[Phase{snapshot,Actions.ReadersResult{result}}]))')
def prepare():
 p=json.loads(BASE.read_bytes());assert sha(BASE.read_bytes())=='89b02105f70aecdc82cdabff3be0b492f4e8d565018b7037957b6b8494af0635'
 assert not NEW.exists() and not NEW.is_symlink()
 for r,v in p['stagePins'].items():
  q=OLD/r;assert not q.is_symlink() and sha(q.read_bytes())==v
  d=NEW/r;d.parent.mkdir(parents=True,exist_ok=True);d.write_bytes(q.read_bytes())
 before=(OLD/REL).read_text();after=transform(before);assert after==(H/'scenario.bend').read_text() and 'next:'not in after
 (NEW/REL).write_text(after)
 change={'basePlanSHA256':sha(BASE.read_bytes()),'sourceCount':len(p['stagePins']),'onlyChanged':REL,'beforeSHA256':sha(before.encode()),'afterSHA256':sha(after.encode()),'stageRoot':str(NEW),'entry':str(NEW/'experiments/public-simulation/bend-v1/main.bend'),'wholeOracleSHA256':p['oracleSHA256'],'delta':'Named decreasing loop receives owned Application/trace pair; helpers return it; no per-command runtime continuation'}
 metadata=json.loads((NEW/'stage.json').read_bytes());metadata['sources'][REL]['stagedSha256']=sha(after.encode());metadata['optimization']='Named loop receives Application/trace pair; no runtime continuation';(NEW/'stage.json').write_text(json.dumps(metadata,indent=2)+'\n')
 (H/'SOURCE-DELTA.json').write_text(json.dumps(change,indent=2)+'\n');return change
if __name__=='__main__':print(json.dumps(prepare(),indent=2))
