"""Exact prospective reached-operation mutations; no policy/law approval."""
MUTATIONS=[
 ('early-current','machine.bend','Present{current,Queued{value,skipSame},previous,changed}','Present{value,Queued{value,skipSame},previous,changed}','queued'),
 ('pending-undo-dropped','machine.bend','Tx.Tx{put(world,queue(~S,~M,~V,old,value,skipSame)),(world => put(world,old)) <> undo,commands,events}','Tx.Tx{put(world,queue(~S,~M,~V,old,value,skipSame)),undo,commands,events}','publisher-failed'),
 ('resource-prefix-restoration','context.bend','owned_restored(~S,owned_replace(~S,world,old))','owned_restored(~S,owned_replace(~S,world,ALeaf{30}))','publisher-failed'),
 ('failed-reader-cursor-advanced','readers.bend','case Sys.Failed{world,error}: Sys.Failed{world,Failure{error,Some{delivery}}}','case Sys.Failed{world,error}: Sys.Failed{stream_completed(~S,world,flowId,levelId),Failure{error,Some{delivery}}}','reader-failed'),
 ('registered-skip-runs-body','application.bend','case (world,P.ConditionValue{False{}}): skip_reader(~S,owners,world,key)','case (world,P.ConditionValue{False{}}): run_reader(~S,owners,world,key,name,False{})','skip-reader'),
 ('normal-identity-suppressed','machine.bend','Bool.and(skipSame,same(current,value))','same(current,value)','same-set-and-conditions'),
 ('definition-order-reversed','hooks.bend','M.OwnedMarker{[h => w => flow_step(~S,~runner,h,w,flow,enabled),h => w => level_step(~S,~runner,h,w,level,enabled)]}','M.OwnedMarker{[h => w => level_step(~S,~runner,h,w,level,enabled),h => w => flow_step(~S,~runner,h,w,flow,enabled)]}','marker-generated-and-definition-order'),
]

# This is explicitly a pinned-reference deviation, not an approved defect.
LATER_HELPER='''def retained_checked(~S: Data,~M: Data,~V: Data,keep: Bool,pending: Pending<V>,applied: Applied<S,M,V>) -> Applied<S,M,V>:
  match keep applied:
    case True{} Applied{Present{current,_,previous,changed},event}: Applied{Present{current,pending,previous,changed},event}
    case _ applied: applied
def retained_difference(~S: Data,~M: Data,~V: Data,~same: V -> V -> Bool,pending: Pending<V>,value: V,applied: Applied<S,M,V>) -> Applied<S,M,V>:
  match pending:
    case NoPending{}: applied
    case Queued{+next,+skip}: retained_checked(~S,~M,~V,Bool.not(same(next,value)),Queued{next,skip},applied)

'''
LATER_OLD='''    case Present{current,_,previous,changed} Scheduled{value,skipSame}:
      apply_present(~S,~M,~V,~same,current,value,previous,changed,skipSame)'''
LATER_NEW='''    case Present{current,pending,previous,changed} Scheduled{+value,skipSame}:
      retained_difference(~S,~M,~V,~same,pending,value,apply_present(~S,~M,~V,~same,current,value,previous,changed,skipSame))'''
MUTATIONS.append(('pinned-later-write-preserved','machine.bend',LATER_OLD,LATER_NEW,'marker-generated-and-definition-order'))

def apply(label,text):
 entry=next(m for m in MUTATIONS if m[0]==label)
 old,new=entry[2:4]
 assert text.count(old)==1,(label,'exact unique operation anchor')
 text=text.replace(old,new)
 if label=='early-current':
  anchor='slot: Slot<S,M,V>,value: V,skipSame: Bool'
  assert text.count(anchor)==1
  text=text.replace(anchor,'slot: Slot<S,M,V>,+value: V,skipSame: Bool')
 if label=='pinned-later-write-preserved':
  anchor='def apply_snapshot('
  assert text.count(anchor)==1
  text=text.replace(anchor,LATER_HELPER+anchor)
 return text
