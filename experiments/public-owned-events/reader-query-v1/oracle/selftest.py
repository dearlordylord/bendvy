from derive import derive,Model
raw,traces=derive()
for states in traces:
    assert [s['label'] for s in states]==['registered','empty','publish1','committed','publish2','latefailed','retry','nochange','foreign']
    assert [s['tick'] for s in states]==[0,1,2,3,4,5,6,7,7]
    assert [s['clock'] for s in states]==[2,2,2,6,6,10,14,14,14]
    assert [s['registry'] for s in states]==[0,2,2,6,6,6,14,14,14]
    assert [s['scratch'][0] for s in states]==[1,1,1,5,5,9,13,13,13]
    assert [len(s['observations']) for s in states]==[0,0,0,2,2,4,6,6,6]
    assert states[0]['position'] is None
    assert [s['position'] for s in states[1:]]==[[1,c,0] for c in [1,1,3,3,3,6,7,7]]
    for i in [3,4,5]:
        assert states[i]['values']==[12,22] and states[i]['stamps']==[[1,5],[2,6]] and states[i]['user']==[104,105]
    for i in [6,7,8]:
        assert states[i]['values']==[14,24] and states[i]['stamps']==[[1,13],[2,14]] and states[i]['user']==[108,109]
    assert states[-1]['observations']==[[900,2],[901,2],[900,2],[901,2],[900,2],[901,2]]
    assert states[-1]['logCounts']==[4,2,2]
assert raw.count(b'query-failed-at=23:lag=False:values=[]\n')==2
assert raw.count(b'success:lag=False:values=[10, 20, 11, 21]\n')==2
assert raw.count(b'success:lag=False:values=[12, 22, 13, 23]\n')==2
assert raw.count(b'rejected:14\n')==2
assert raw.count(b'|observations=')==18
assert raw.startswith(b'Workshop\nregistered|runtime(') and raw.endswith(b'\n\n')
# The complete wire snapshots deliberately have no trailing LF.
assert b'|observations=[]success:lag=False:values=[]\nempty|' in raw
assert raw.count(b'returned-observations:')==2
# Whole-run abort must restore earlier event rows, rather than just final row.
m=Model(1,2);m.read();m.publish();m.read();m.publish();before=(m.values[:],m.user[:],m.registry,m.position[:]);m.read(23)
assert (m.values,m.user,m.registry,m.position)==before
assert m.clock==10 and m.scratch==[9,2]
print('18 complete snapshots: rollback, monotonic clock, both cursor kinds, Type captures and wire assertions passed')
