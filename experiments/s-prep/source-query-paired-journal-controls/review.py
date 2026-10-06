#!/usr/bin/env python3
"""Read-only exact composition/header/kind observations, not pair algorithm acceptance."""
from pathlib import Path
import hashlib,json
from pins import verify
H=Path(__file__).resolve().parent;joined=Path('/tmp/bendvy-query-paired-journal-v1');identity=Path('/tmp/bendvy-identity-handle-query-v3/experiments/s-integrate');paired=Path('/tmp/bendvy-paired-journal-v2/experiments/s-integrate');base=Path('/tmp/bendvy-joined-flatjournal-ledger-v1/experiments/s-integrate');files,pins,closure=verify(joined);sha=lambda b:hashlib.sha256(b).hexdigest()
diff_identity=sorted(n for n,b in files.items() if b!=(identity/n).read_bytes());diff_paired=sorted(n for n,b in files.items() if b!=(paired/n).read_bytes());assert diff_identity==['held-adapter.bend','transaction.bend'];assert diff_paired==['measurement-bend.bend','query.bend']
q=files['query.bend'].decode();old=(base/'query.bend').read_bytes();assert files['query.bend'].startswith(old)
assert 'def prototype_identity_restore_state(-Schema:Data,-M:Type,-A:Type,-F:Data' in q
assert 'case Tuple{main,Some{owner}}: StructColsState{Array.set(Maybe<M>,main,U32.sub(id,1),Some{owner}),aux,live,flags,added,changed,S.Handle{namespace,id} <> values}' in q
assert 'case Tuple{main,None{}}: StructColsState{main,aux,live,flags,added,changed,values}' in q
for n in ['full-shape.bend','full-shape-expected.txt','generic-nonidentity.bend','generic-nonidentity-expected.txt','actual-client-undeclared.bend','actual-client-write-read.bend','negative-anchors.json']:
 assert (H/n).read_bytes()==(H.parent/'source-identity-query-controls'/n).read_bytes()
r={'status':'READ_ONLY_DISJOINT_SOURCE_AND_ORACLE_BINDING_PASS','closure':closure,'sources29':pins,'changedVersusIdentityV3':diff_identity,'changedVersusPairedV2':diff_paired,'queryAndMeasurementByteIdenticalToIdentityV3':True,'heldAndTransactionByteIdenticalToPairedV2':True,'originalGenericQueryEntirePrefixSHA256':sha(old),'originalGenericQueryPrefixByteIdentical':True,'opaqueAffineMRestoreExact':'Maybe Some owner is restored once to the same index; M is Type, not destructured or duplicated','unchangedNormativeAuthoredFixturesAndOracles':True,'scope':'Composition/query structural review only; no paired journal algorithm/refinement, full22 or performance acceptance'};(H/'review.json').write_text(json.dumps(r,indent=2)+'\n')
