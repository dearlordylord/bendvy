"""Checks derivation against separately stated finite scenario facts."""
from derive import derive
raw, states = derive()
assert [s['tick'] for s in states] == [0,1,2,3,4,4,5,6,7,7,7,8,8]
assert [s['owners'] for s in states] == [[],[1],[1],[1],[1],[1],[1,2],[1,2],[1,2],[2],[],[3],[]]
assert [s['frameStart'] for s in states] == [0,0,0,0,0,4,4,4,4,7,7,7,7]
assert [s['boundary'] for s in states] == [0,0,0,0,0,0,0,0,0,4,7,7,7]
assert [s['droppedThrough'] for s in states] == [0,0,0,0,0,0,0,0,0,1,5,5,5]
assert states[3]['positions'] == [[1,0,2]]
assert states[4]['positions'] == [[1,4,2]]
assert states[8]['positions'] == [[2,7,6],[1,6,2]]
assert states[-1]['positions'] == states[8]['positions']
for s in states:
    assert s['familyFrameStart']==s['frameStart']
    assert s['familyOwners']=='unit' and s['streamDomain']=='cargo:manifest'
    assert [k for _,ids in s['journal'] for k in ids]==s['owners']
assert raw.startswith(b'cargo-manifests-family-v2\n') and raw.endswith(b'\n\n')
assert raw.count(b';family(stream(')==13
assert raw.count(b'owners=unit,journal=')==13
assert raw.count(b'publish=failure(73);recovered=manifest(22,[[202,205],[210,217]]),[]\n')==1
assert raw.count(b'fast:read=body-failure(73);lagged=false\n')==1
print('13 snapshot state, owner, journal, cursor and complete-format assertions passed')
