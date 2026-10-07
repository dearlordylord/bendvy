import Base
import feature.bend as F
import provider.bend as P
import gameplay.bend as G
import core-feature.bend as Core
import combat-feature.bend as Combat
import recipe-app.bend as A
import ../../src/ecs/schema-fragments.bend as SF
import ../../src/ecs/component.bend as C
def get_done(observed:Array<U32> & U32) -> Array<U32> & C.Access<U32>:
  match observed:
    case (owner,+value): (Array.set(U32,owner,0,U32.add(value,1)),C.Found{value})
def getter(owner:Array<U32>) -> Array<U32> & C.Access<U32>:
  get_done(Array.get(U32,owner,0))
def build(owner:Array<U32>) -> Array<U32> & C.Access<U32>:
  P.provide(~Array<U32>,~U32,~getter,~G.observe,owner)
def access_text(access:C.Access<U32>) -> String:
  match access:
    case C.Found{value}: U32.show(value)
    case C.ComponentAbsent{}: "absent"
    case C.MissingEntity{}: "missing"
def observed(result:SF.Bound<A.Schema,Array<U32>,Array<U32> & C.Access<U32>>) -> String:
  match result:
    case SF.Built{(owner,access)}: "built=" ++ access_text(access) ++ "|owner=" ++ A.array_text(owner)
    case SF.BindRejected{SF.UndeclaredDescriptor{_,key,name},SF.Fragment{entries,owner}}: "refused=" ++ key ++ ":" ++ name ++ "|owner=" ++ A.array_text(owner)
    case SF.BindRejected{SF.DuplicateKey{_,key},SF.Fragment{entries,owner}}: "conflict=" ++ key ++ "|owner=" ++ A.array_text(owner)
    case SF.BindRejected{error,fragment}: "UNEXPECTED_ERROR"
def run(definition:F.Definition<A.Schema>,required:List<&2,SF.Entry<A.Schema>>) -> String:
  observed(P.bind_feature(~A.Schema,~Array<U32>,~(Array<U32> & C.Access<U32>),~build,definition,required,ANode{ALeaf{11},ALeaf{12}}))
def retry(result:SF.Bound<A.Schema,Array<U32>,Array<U32> & C.Access<U32>>) -> String:
  match result:
    case SF.BindRejected{error,SF.Fragment{entries,owner}}: observed(P.bind_feature(~A.Schema,~Array<U32>,~(Array<U32> & C.Access<U32>),~build,Combat.declaration(~A.Schema),[SF.Entry{SF.Component{},"core","core"}],owner))
    case SF.Built{output}: "UNEXPECTED_BUILT"
def main() -> IO(Unit):
  IO.print("dependency=" ++ run(Combat.declaration(~A.Schema),[SF.Entry{SF.Component{},"core","core"}]) ++ "\nundeclared=" ++ run(Core.declaration(~A.Schema),[SF.Entry{SF.Component{},"combat","combat"}]) ++ "\ntransitive=" ++ run(F.Definition{"Addon",[SF.Entry{SF.Component{},"addon","addon"}],Combat.definition(~A.Schema)},[SF.Entry{SF.Component{},"core","core"}]) ++ "\nretry=" ++ retry(P.bind_feature(~A.Schema,~Array<U32>,~(Array<U32> & C.Access<U32>),~build,Core.declaration(~A.Schema),[SF.Entry{SF.Component{},"combat","combat"}],ANode{ALeaf{11},ALeaf{12}})))
