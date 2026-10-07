#!/usr/bin/env python3
"""Single Data-list append in collected, on admitted count+append stage."""
import argparse,json,pathlib,shutil,sys
HERE=pathlib.Path(__file__).resolve().parent
sys.path.insert(0,str(HERE.parent))
import preflight
from stage import inventory

def main():
 p=argparse.ArgumentParser();p.add_argument('--original',type=pathlib.Path,required=True);p.add_argument('--output',type=pathlib.Path,required=True);p.add_argument('--mutant',action='store_true');a=p.parse_args()
 assert not a.output.exists();m=json.loads((a.original/'stage.json').read_text());assert inventory(a.original/'stage')==m['stageInventory'];assert preflight.snapshot()==m['sources']
 shutil.copytree(a.original,a.output);file=a.output/'stage/src/ecs/reader-domains.bend';old=file.read_text()
 seam='case Events{+ns,+batches,+positions,+next,+tick,+start,+boundary,+capacity,+dropped,+old}, (+fresh,+removals): detach(~S,~C,~R,~E,Ev.sync_values(~S,~C,~R,~E,(W.events_replace(~S,~C,~R,~E,world,Ev.append(~E,old,fresh)),Ev.append(~E,old,fresh)),ns,batches,positions,next,1n+tick,start,boundary,capacity,dropped),removals)'
 assert old.count(seam)==1
 merge='Ev.append(~E,fresh,old)' if a.mutant else 'Ev.append(~E,old,fresh)'
 replacement='''case Events{+ns,+batches,+positions,+next,+tick,+start,+boundary,+capacity,+dropped,+old}, (+fresh,+removals):
      +all = '''+merge+'''
      detach(~S,~C,~R,~E,Ev.sync_values(~S,~C,~R,~E,(W.events_replace(~S,~C,~R,~E,world,all),all),ns,batches,positions,next,1n+tick,start,boundary,capacity,dropped),removals)'''
 file.write_text(old.replace(seam,replacement))
 m.setdefault('intentionalAdaptations',{})['src/ecs/reader-domains.bend']={'before':__import__('hashlib').sha256(old.encode()).hexdigest(),'after':preflight.digest(file),'purpose':'Reached wrong-order mutant' if a.mutant else 'Compute append once as duplicable Data list, preserving exact affine World'}
 m['candidateSourcePins'].update({str(x):preflight.digest(x) for x in HERE.glob('*') if x.is_file()});m['stageInventory']=inventory(a.output/'stage');m['status']='CANDIDATE_STAGED_REVIEW_REQUIRED_NO_EXECUTION';m['collectedMutant']=a.mutant
 (a.output/'stage.json').write_text(json.dumps(m,indent=2)+'\n');print(a.output/'stage.json')
if __name__=='__main__':main()
