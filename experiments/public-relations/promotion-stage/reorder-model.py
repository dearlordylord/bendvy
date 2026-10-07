"""Independent finite dictionary specification, not maintained-inverse code."""
OWNERS=[[100,10],[200,20,21],[300,30,31,32,33],[400,40,41,42,43,44,45,46,47]]
SUBJECTS=[('reverse',1,[2,3]),('repeat',1,[2,3]),('missing-parent',9,[99,99]),('early-duplicate',1,[2,2,99]),('early-missing-child',1,[99,2,2]),('not-related',1,[4,2,3]),('empty-mismatch',1,[]),('subset-mismatch',1,[2]),('duplicate',1,[2,2]),('other-parent',2,[4]),('empty-parent',3,[]),('restore-order',1,[3,2])]
def records(root):
    targets={3:1,2:1,4:2};orders={1:[3,2],2:[4]};failures=[];result=[]
    def snapshot(phase):
        result.append({'root':root,'phase':phase,'owners':[[i+1,list(v)]for i,v in enumerate(OWNERS)],'targets':[targets.get(i)for i in range(1,5)],'inverses':[list(orders.get(i,[]))for i in range(1,5)],'failures':[dict(f)for f in failures]})
    def error(tag,parent,child=None):
        e={'_tag':tag,'entityId':parent}
        if child is not None:e['childId']=child
        if tag!='MissingEntity':e['relation']='Parent'
        return e
    def reorder(parent,children):
        refusal=None
        if parent not in range(1,5):refusal=error('MissingEntity',parent)
        else:
            seen=set()
            for child in children:
                if child not in range(1,5):refusal=error('MissingChildEntity',parent,child);break
                if child in seen:refusal=error('DuplicateChild',parent,child);break
                seen.add(child)
                if targets.get(child)!=parent:refusal=error('ChildNotRelatedToParent',parent,child);break
            if refusal is None and set(children)!=set(orders.get(parent,[])):refusal=error('ChildSetMismatch',parent)
        if refusal is None:
            if children:orders[parent]=list(children)
        else:failures.append({'operation':'reorderChildren','relation':'Parent','source':parent,'target':refusal.get('childId',parent),'error':refusal})
    for name,parent,children in SUBJECTS:
        snapshot(name+'-queued');reorder(parent,children);snapshot(name+'-after')
    snapshot('fifo-queued');reorder(1,[2,3]);targets.pop(3);orders[1].remove(3);reorder(1,[2]);targets[3]=1;orders[1].append(3);reorder(1,[3,2]);snapshot('fifo-after')
    # Independent fixed priority anchors, rather than deriving every expected error.
    assert [f['error']['_tag']for f in failures]==['MissingEntity','DuplicateChild','MissingChildEntity','ChildNotRelatedToParent','ChildSetMismatch','ChildSetMismatch','DuplicateChild']
    assert [f['target']for f in failures]==[9,2,99,4,1,1,2]
    return result
if __name__=='__main__':
    import json
    for root in ['Workshop','Other']:
        for r in records(root):print(json.dumps(r,separators=(',',':')))
