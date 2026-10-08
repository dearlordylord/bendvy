"""Independent failed-reader cleanup full owner oracle, authored before outputs."""
import copy,importlib.util,json
from pathlib import Path
ROOT=Path('/workspace/formal-proofs/bendvy')
spec=importlib.util.spec_from_file_location('failed_cleanup_seed',ROOT/'experiments/public-machines/followup/foreign-model.py');base=importlib.util.module_from_spec(spec);spec.loader.exec_module(base)
def expected():
 result={}
 for schema,seed in base.expected().items():
  worlds={side:copy.deepcopy(rows[:2]) for side,rows in seed['worlds'].items()};fields={side:copy.deepcopy(rows[-1]['fields']) for side,rows in worlds.items()};ns=int(fields['A']['ns']);access=base.base.READ_ACCESS;listing=base.listing
  ordinary=[(1,'flow-hook',['machine.Flow.next','machine.Level.next']),(2,'level-hook',['machine.Flow.next']),(3,'seed',base.base.BODY_ACCESS),(4,'publish',base.base.BODY_ACCESS)]
  registered=ordinary+[(5,'failed-reader',access),(6,'survivor',access)]
  def regs(items):return listing(f'{i}:{n}:{listing(a)}' for i,n,a in reversed(items))
  def record(label,status):
   for side in ['A','B']:worlds[side].append({'label':label,'status':status,'fields':copy.deepcopy(fields[side])})
  fields['A']['registrations']=regs(registered);fields['A']['nextSystem']='7';record('two-same-world-readers','ok')
  fields['A']['tick']='6';fields['A']['flowStream']='batches=[5:[Boot>Play]],positions=[5:0:5],dropped=0,frameStart=2';fields['A']['levelStream']='batches=[],positions=[5:0:5],dropped=0,frameStart=2';record('reader-failed','reader-failed')
  record('foreign-disposal-rejected','cleanup-rejected')
  fields['A']['registrations']=regs(ordinary+[(6,'survivor',access)]);fields['A']['flowStream']='batches=[5:[Boot>Play]],positions=[],dropped=0,frameStart=2';fields['A']['levelStream']='batches=[],positions=[],dropped=0,frameStart=2';record('first-owned-cleanup','cleaned')
  fields['A']['tick']='7';fields['A']['flowStream']='batches=[5:[Boot>Play]],positions=[6:7:6],dropped=0,frameStart=2';fields['A']['levelStream']='batches=[],positions=[6:7:6],dropped=0,frameStart=2';record('same-world-survivor-read','ok')
  fields['A']['registrations']=regs(ordinary);fields['A']['flowStream']='batches=[5:[Boot>Play]],positions=[],dropped=0,frameStart=2';fields['A']['levelStream']='batches=[],positions=[],dropped=0,frameStart=2';record('survivor-owned-cleanup','cleaned')
  def token(i,name):return f'99:{ns}:{i}:{name}:{listing(access)}:0:flow={ns}:{i}:level={ns}:{i}'
  first=token(5,'failed-reader');survivor=token(6,'survivor');pair=lambda label:f'{label}|first={first}|survivor={survivor}'
  delivery='[actual:flow=[Boot>Play]:level=[]:lagged=false,false]'
  result[schema]={'worlds':worlds,'instances':[pair('two-same-world-readers'),'failed-delivery='+delivery,pair('reader-failed'),pair('foreign-disposal-rejected'),'first-owned-cleanup|first=disposed|survivor='+survivor,'survivor-delivery='+delivery,'same-world-survivor-read|first=disposed|survivor='+survivor,'survivor-owned-cleanup|first=disposed|survivor=disposed']}
 return result
if __name__=='__main__':print(json.dumps(expected(),indent=2))
