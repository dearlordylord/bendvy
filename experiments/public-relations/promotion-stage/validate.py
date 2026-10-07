"""Literal semantic witnesses; not a universal relation model or law proof."""
def validate(records):
 assert len(records)==2 and [x['root'] for x in records]==['Workshop','Other']
 normalized=[]
 for record in records:
  obs=record['observations'];assert len(obs)==38
  by={o['phase']:o for o in obs};assert len(by)==38
  assert record['descriptors']==[{'name':'Link','relatedName':'LinkedBy','kind':'relation','linkedDespawn':False,'allowSelf':False,'ordered':False,'key':'bevy-ts/relation/Link','inverseKey':'bevy-ts/related/Link'},{'name':'Parent','relatedName':'Children','kind':'hierarchy','linkedDespawn':True,'allowSelf':False,'ordered':True,'key':'bevy-ts/relation/Parent','inverseKey':'bevy-ts/related/Parent'}]
  assert record['pair']=={'forward':True,'sameNameKey':True}
  for o in obs:
   if 'rows' not in o:continue
   rows=o['rows'];assert [r['id'] for r in rows]==sorted(r['id'] for r in rows)
   for row in rows:assert row['payload']==[row['id']+offset for offset in [0,100,200,300]]
   for row in rows:
    if row['target'] is not None:assert row['id'] in next(x for x in rows if x['id']==row['target'])['sources']
    for source in row['sources'] or []:assert next(x for x in rows if x['id']==source)['target']==row['id']
    assert len(row['sources'] or [])==len(set(row['sources'] or []))
   assert o['requiredOutgoing']==[{'id':r['id'],'target':r['target']} for r in rows if r['target'] is not None]
   assert o['requiredIncoming']==[{'id':r['id'],'sources':r['sources']} for r in rows if r['sources']]
   assert o['withOutgoing']==[r['id'] for r in rows if r['target'] is not None]
   assert o['withoutOutgoing']==[r['id'] for r in rows if r['target'] is None]
   assert o['withIncoming']==[r['id'] for r in rows if r['sources']]
   assert o['withoutIncoming']==[r['id'] for r in rows if not r['sources']]
  def rows(label):return {r['id']:r for r in by[label]['rows']}
  assert rows('ordered-inverse-barrier')[1]['sources']==[3,2]
  assert by['repeat-same-edge-barrier']['rows']==by['ordered-inverse-barrier']['rows']
  assert by['replace-source-barrier']['retainedInverse']==[3,2] and all(o['inverseSetter']=='undefined' for o in obs if 'inverseSetter' in o)
  assert rows('replace-source-barrier')[1]['sources']==[2] and rows('replace-source-barrier')[2]['sources']==[3]
  assert rows('unrelate-total-barrier')[3]['target'] is None
  assert rows('fifo-relate-replace-barrier')[1]['sources']==[2,3]
  assert rows('general-cycle-barrier')[1]['target']==2 and rows('general-cycle-barrier')[2]['target']==1
  assert by['ordered-errors-barrier']['rows']==by['general-cycle-barrier']['rows']
  assert by['ordered-errors-barrier']['linkFailures']==[
   {'operation':'relate','relation':'Link','source':999,'target':998,'error':{'_tag':'MissingEntity','entityId':999}},
   {'operation':'relate','relation':'Link','source':1,'target':999,'error':{'_tag':'MissingTargetEntity','entityId':1,'targetId':999,'relation':'Link'}},
   {'operation':'relate','relation':'Link','source':1,'target':1,'error':{'_tag':'SelfRelationNotAllowed','entityId':1,'relation':'Link'}}]
  h=by['hierarchy-reorder-barrier'];assert h['children']=={'ok':True,'value':[5,4]} and h['breadth']=={'ok':True,'value':[5,4,6]} and h['depth']=={'ok':True,'value':[5,4,6]} and h['ancestors']=={'ok':True,'value':[4,1]} and h['parent']=={'ok':True,'value':4} and h['root']=={'ok':True,'value':1};assert h['childMatches']==[4] and h['descendantMatches']==[4]
  assert [f['error']['_tag'] for f in by['hierarchy-errors-and-later-success-barrier']['parentFailures']]==['HierarchyCycle','SelfRelationNotAllowed','MissingChildEntity','DuplicateChild','ChildNotRelatedToParent','ChildSetMismatch']
  assert by['hierarchy-errors-and-later-success-barrier']['children']=={'ok':True,'value':[4,5]}
  assert by['system-failure']['result']=={'ok':False,'error':{'kind':'SystemFailure','system':'failed-system','error':'boom'}}
  assert by['after-system-failure']['rows']==by['failed-system-barrier']['rows']==by['hierarchy-errors-and-later-success-barrier']['rows']
  assert not by['failed-system-barrier']['linkFailures']
  assert rows('draft-relations-barrier')[5]['sources']==[7,8] and rows('draft-relations-barrier')[8]['target']==5
  assert rows('future-target-fifo-barrier')[7]['target']==9 and rows('future-target-fifo-barrier')[9]['sources']==[7]
  assert by['future-target-fifo-barrier']['linkFailures']==[{'operation':'relate','relation':'Link','source':7,'target':9,'error':{'_tag':'MissingTargetEntity','entityId':7,'targetId':9,'relation':'Link'}}]
  assert 9 not in rows('delete-then-relate-barrier') and rows('delete-then-relate-barrier')[7]['target'] is None
  assert by['delete-then-relate-barrier']['linkFailures']==[{'operation':'relate','relation':'Link','source':7,'target':9,'error':{'_tag':'MissingTargetEntity','entityId':7,'targetId':9,'relation':'Link'}}]
  assert 3 not in rows('delete-source-barrier') and 3 not in (rows('delete-source-barrier')[1]['sources'] or [])
  assert 2 not in rows('delete-general-target-barrier') and rows('delete-general-target-barrier')[1]['target'] is None
  assert list(rows('delete-hierarchy-target-barrier'))==[7,8] and all(r['target'] is None for r in rows('delete-hierarchy-target-barrier').values())
  # Every queued snapshot retains preceding committed component/relation state.
  prior=[]
  for o in obs:
   if 'rows' not in o:continue
   if o['phase'] not in ['reader-registration','after-system-failure','failed-system-barrier'] and not o['phase'].endswith('-barrier'):assert o['rows']==prior,o['phase']
   prior=o['rows']
  normalized.append([{k:v for k,v in o.items() if k!='root'} for o in obs])
 assert normalized[0]==normalized[1]
