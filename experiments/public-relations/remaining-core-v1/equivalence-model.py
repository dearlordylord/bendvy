"""Independent split/uninterrupted complete-state and reached-counterfactual model."""
from pathlib import Path
import gzip, hashlib, importlib.util, json
HERE=Path(__file__).resolve().parent
spec=importlib.util.spec_from_file_location('cleanup_model',HERE/'model.py');m=importlib.util.module_from_spec(spec);spec.loader.exec_module(m)
def completed(namespace,split,drop_frames=False,silent=False):
 world=m.World(namespace);frames=[('enter',1)]
 if split:
  m.advance(world,frames,4)
  if drop_frames:frames=[]
  m.advance(world,frames,32)
 else:m.advance(world,frames,36)
 assert not frames
 if silent:world.events=[notice for notice in world.events if not notice.startswith('removed:')]
 before=m.observed(world,frames);world.pending=0;world.clock+=1;after=m.observed(world,frames)
 return before+'\n'+after+'\n'
def report(drop_frames=False,silent=False):
 all=[]
 for case,namespace in [('Workshop',31),('Garden',47)]:
  split=completed(namespace,True,drop_frames,silent);direct=completed(namespace,False,False,silent)
  if not drop_frames:assert split==direct
  all.append(case+'\nsplit\n'+split+'uninterrupted\n'+direct+'equal='+str(split==direct)+'\n')
 return (json.dumps(''.join(all))+'\n').encode()
if __name__=='__main__':
 for case,drop,silent in [('equivalence',False,False),('lost-frame',True,False),('failed-publication',False,True)]:
  raw=report(drop,silent);(HERE/(case+'-expected.stdout.gz')).write_bytes(gzip.compress(raw,mtime=0));print(case,len(raw),hashlib.sha256(raw).hexdigest())
