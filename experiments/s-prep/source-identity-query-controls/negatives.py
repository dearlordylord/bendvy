import pathlib
H=pathlib.Path(__file__).resolve().parent
header='import Base\nimport ./query.bend as Q\nimport ./storage.bend as S\n\ntype Schema is Data:\n  Schema{}\ntype Other is Data:\n  Other{}\ntype Owned is Type:\n  Owned{items:Array<U32>,scalar:U32}\n'
cases={
'clone-owner':('def bad(owner:Owned) -> Owned & Owned: (owner,owner)\n',['owner']),
'cross-schema':('def bad(world:S.World<Schema,Owned,Owned,Unit,Owned,U32>) -> S.World<Other,Owned,Owned,Unit,Owned,U32> & List<&2,S.Handle<Other>>:\n  Q.prototype_identity_each(Other,Owned,Owned,Unit,Owned,U32,Q.Required{},world)\n',['S.World<Other','S.World<Schema']),
'cross-component':('def bad(world:S.World<Schema,Owned,Owned,Unit,Owned,U32>) -> S.World<Schema,U32,Owned,Unit,Owned,U32> & List<&2,S.Handle<Schema>>:\n  Q.prototype_identity_each(Schema,U32,Owned,Unit,Owned,U32,Q.Required{},world)\n',['S.World<Schema, U32','S.World<Schema, Owned']),
'undeclared-access':('def observe(owner:Owned) -> Owned & String: (owner,"x")\ndef bad(~P:Type,p:P) -> Owned & String: observe(p)\n',['expected : Owned','observed : bad~P']),
'write-read':('def bad(~P:Type,p:P) -> P:\n  Owned{ALeaf{1},1}\n',['expected : bad~P','observed : Owned']),
'escape-data':('def bad(~P:Type,p:P) -> List<&2,P>: p <> []\n',['expected : Data','observed : Type']),
}
for name,(body,anchors) in cases.items():(H/(name+'.bend')).write_text(header+body)
(H/'negative-anchors.json').write_text(__import__('json').dumps({n:a for n,(b,a) in cases.items()},indent=2)+'\n')
# Live registration negatives use the exact authored generic client fixture.
s=(H/'generic-nonidentity.bend').read_text();start=s.index('def client(~P:Type');end=s.index('def returned',start);old=s[start:end];head=old[:old.index('\n  ')].replace('def client(','def bad(');before=s[:start];after=s[end:].replace('getter,getter,client,','getter,getter,bad,');anchors={n:a for n,(b,a) in cases.items()}
for n,body,needles in [('actual-client-undeclared','owned(p)',['expected : Owned','observed : bad~P']),('actual-client-write-read','(Owned{ALeaf{999},999},(u,"bad"))',['expected : bad~P','observed : Owned'])]:
 (H/(n+'.bend')).write_text(before+head+'\n  '+body+'\n'+after);anchors[n]=needles
(H/'negative-anchors.json').write_text(__import__('json').dumps(anchors,indent=2)+'\n')
