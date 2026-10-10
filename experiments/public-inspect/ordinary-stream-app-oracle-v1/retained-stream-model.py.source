"""Independent complete source-derived stream model; no runtime inputs."""
from pathlib import Path
import types,json,os
HERE=Path(__file__).resolve().parent
base=types.ModuleType('base');base.__file__=str(HERE/'prior-model.py.source');exec(compile((HERE/'prior-model.py.source').read_bytes(),base.__file__,'exec'),base.__dict__)
ROOT=Path('/workspace/formal-proofs/bendvy-worktrees/resource-field-public-transactions-v1/experiments/public-inspect/ordinary-declaration-v1/stream-public-relocation-v1')
def named(module,constructor):return os.path.relpath(base.CORE/(module+'.bend'),ROOT)[:-5]+'.'+constructor
c=base.ctr;l=base.ls;t=base.text

def descriptor(key):
 return c(named('relation-types','Descriptor'),str(key),t('Link' if key==1 else 'Parent'),t('LinkedBy' if key==1 else 'Children'),c(named('relation-types','Ordinary' if key==1 else 'Hierarchy')))
def failure(key,source,target,error):return c(named('relation-types','Failure'),descriptor(key),c(named('relation-types','Relate')),str(source),str(target),error)
def events():
 cycle=failure(2,2,3,c(named('relation-types','HierarchyCycle'),'2','3',t('Parent')))
 cleanup=l([c(named('relation-types','CleanupEnter'),'3'),c(named('relation-types','CleanupDescriptors'),'3',l([descriptor(1),descriptor(2)])),c(named('relation-types','CleanupChildren'),'3',descriptor(2),l([descriptor(1)]),l(['1','3'])),c(named('relation-types','CleanupFinish'),'3')])
 initial=[c(named('relation-commands','Original'),'17'),c(named('relation-commands','RelationFailed'),cycle),c(named('relation-commands','ComponentRemoved'),'23'),c(named('relation-commands','CleanupPaused'),cleanup)]
 selected=[cycle,failure(2,2,2,c(named('relation-types','SelfRelationNotAllowed'),'2',t('Parent'))),failure(2,4,2,c(named('relation-types','MissingEntity'),'4'))]
 added=[c(named('relation-commands','RelationFailed'),selected[1]),c(named('relation-commands','RelationFailed'),selected[2]),c(named('relation-commands','RelationFailed'),failure(1,4,2,c(named('relation-types','MissingEntity'),'4')))]
 return initial,added,selected

def world(ns,value):
 w=base.world(ns,value)
 w=w.replace('regs=[1:Existing:[Flow, Link]],nextSystem=2','regs=[2:NoticeReader:[relationFailures, transitionEvents], 1:Existing:[Flow, Link]],nextSystem=3')
 old='cleanupPaused:[enter:3, descriptors:3:[1:Link:LinkedBy:ordinary, 2:Parent:Children:hierarchy], children:3:2:Parent:Children:hierarchy:[1:Link:LinkedBy:ordinary]:[1, 3], finish:3]]'
 new=old[:-1]+', relationFailed:2:Parent:Children:hierarchy:relate:2:2:selfRelation:2:Parent, relationFailed:2:Parent:Children:hierarchy:relate:4:2:missingEntity:4, relationFailed:1:Link:LinkedBy:ordinary:relate:4:2:missingEntity:4]'
 assert old in w
 return w.replace(old,new)

def runtime(ns,value):
 initial,added,_=events()
 batches=l([c(named('event-runtime','Batch'),'1n',l(initial)),c(named('event-runtime','Batch'),'2n',l(added))])
 return c('consumer.RuntimeView',t(world(ns,value)),str(ns),batches,l([c(named('event-runtime','Position'),'1','1n','0n')]),'2','2n','0n','0n','8n','0n')
def observation():
 initial,added,selected=events();all=initial+added
 stream=c(named('machine-stream','Stream'),l([c(named('event-runtime','Batch'),'2n',l([c(named('machine','Transition'),'4','7')])),c(named('event-runtime','Batch'),'3n',l([c(named('machine','Transition'),'7','8'),c(named('machine','Transition'),'8','7')]))]),l([c(named('event-runtime','Position'),'5','1n','1n')]),'0n','2n')
 snap=c(named('event-runtime','Snapshot'),l(all),l(all),l([c(named('event-runtime','ReaderStatus'),'1','1n','0n','3n',c('False'))]),'2n','0n')
 return c('consumer.Observation','19',c(named('inspector-transition-projection','TransitionLog'),stream),c(named('inspector-failure-projection','FailureView'),descriptor(2),l(selected),l(selected),'2n','0n'))
def report(ns,value):
 r=runtime(ns,value);o=observation()
 return (c('Some',c('consumer.Report',c('consumer.ReaderView',str(ns),'1','2'),c('consumer.RegistryView',str(ns),'2',t('NoticeReader'),l([t('relationFailures'),t('transitionEvents')]),'0'),r,o,r,o,r))+'\n').encode()
if __name__=='__main__':
 import hashlib
 for name,ns,v in [('workshop',31,100),('garden',47,200)]:
  b=report(ns,v);print(name,len(b),hashlib.sha256(b).hexdigest())
