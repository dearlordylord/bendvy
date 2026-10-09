"""No-child exact source delta, affine provider and independent complete oracle controls."""
from pathlib import Path
import ast,gzip,hashlib,json,re,tarfile
P=Path(__file__).resolve().parent
s=(P/'foreign-provider.bend').read_text()
reverse=s.replace('import ../../../../src/ecs/relation-providers.bend as P\n','').replace('import ../../../../src/ecs/capabilities.bend as Cap\n','').replace('../../../../src/','../../../src/').replace('import ../owned-world.bend','import owned-world.bend').replace('import ../cleanup-owned.bend','import cleanup-owned.bend')
a=reverse.index('# Gameplay sees only');b=reverse.index('def foreign_ops(',a);reverse=reverse[:a]+reverse[b:]
for source,target in [('foreign','local'),('local','foreign')]:
 reverse=re.sub(r'(?<![A-Za-z_])'+re.escape(f'relate(~S,tx,{source},{target})'),lambda _:f'A.queue_relate(~S,~O.Components<S>,~U32,~U32,tx,G.Descriptor{{1,"Link","LinkedBy",G.Ordinary{{}}}},{source},{target})',reverse)
reverse=reverse.replace('unrelate(~S,tx,foreign,local)','A.queue_unrelate(~S,~O.Components<S>,~U32,~U32,tx,G.Descriptor{1,"Link","LinkedBy",G.Ordinary{}},foreign)')
reverse=reverse.replace('relate(~S,X.begin(~W.World<S,A.Store<S,O.Components<S>>,U32,A.Notice<S,U32>>,~A.Notice<S,U32>,first),W.Handle{1,3},W.Handle{1,1})','A.queue_relate(~S,~O.Components<S>,~U32,~U32,X.begin(~W.World<S,A.Store<S,O.Components<S>>,U32,A.Notice<S,U32>>,~A.Notice<S,U32>,first),G.Descriptor{1,"Link","LinkedBy",G.Ordinary{}},W.Handle{1,3},W.Handle{1,1})')
assert reverse==(P.parent/'foreign-owned.bend').read_text()
assert 'A.queue_relate('not in s and 'A.queue_unrelate('not in s
assert s.count('P.invoke_write(')==2
assert 'case P.Writable{_,_,Cap.Request{remove}} P.Targets{source,_}:remove(owner,source)'in s
assert 'P.relate_live(H,S,caps,owner,args)'in s
inv=json.loads((P/'source-inventory.json').read_text())
with tarfile.open(P/'source-stage.tar.gz')as tar:
 assert {m.name:hashlib.sha256(tar.extractfile(m).read()).hexdigest()for m in tar.getmembers()}==inv
source=(P.parent/'foreign-controls.py').read_text();node=next(n for n in ast.parse(source).body if isinstance(n,ast.FunctionDef)and n.name=='expected');ns={};exec(compile(ast.Module(body=[node],type_ignores=[]),'independent-existing-model','exec'),ns)
expected=('\n'.join(ns['expected']())+'\n').encode();assert gzip.decompress((P/'complete-expected.txt.gz').read_bytes())==expected
print(json.dumps({'status':'EXACT_SOURCE_AND_WHOLE_ORACLE_CONTROLS_PASS','sourceFiles':len(inv),'oracleBytes':len(expected),'oracleLines':len(ns['expected']()),'oracleSHA256':hashlib.sha256(expected).hexdigest(),'scope':'No-child source and complete independent oracle controls; no execution acceptance'}))
