import Base
import domains.bend as D
import wider/runtime-v14.bend as K
import /workspace/formal-proofs/bendvy-worktrees/parity-43-readers-current/src/ecs/world.bend as W
import /workspace/formal-proofs/bendvy-worktrees/parity-43-readers-current/src/ecs/system.bend as Sy
import /workspace/formal-proofs/bendvy-worktrees/parity-43-readers-current/src/ecs/relation-types.bend as G

# Trusted ordinary relation declaration: the same descriptor supplies mutation,
# domain identity and reader access metadata. No second numeric/name registry.
type Declaration<S:Data> is Data: Declaration{descriptor:G.Descriptor<S>}
def relation(~S:Data,descriptor:G.Descriptor<S>) -> Declaration<S>: Declaration{descriptor}
def key(~S:Data,declaration:Declaration<S>) -> D.DescriptorKey<S>:
  match declaration:
    case Declaration{G.Descriptor{id,_,_,_}}: D.DeclaredKey{id}
def access(~S:Data,declaration:Declaration<S>) -> String:
  match declaration:
    case Declaration{G.Descriptor{_,name,_,_}}: String.concat([name,":read"])
def keys(~S:Data,declarations:List<&2,Declaration<S>>) -> List<&2,D.DescriptorKey<S>>:
  match declarations:
    case []: []
    case declaration <> rest: key(~S,declaration) <> keys(~S,rest)
def accesses(~S:Data,declarations:List<&2,Declaration<S>>) -> List<&2,String>:
  match declarations:
    case []: []
    case declaration <> rest: access(~S,declaration) <> accesses(~S,rest)

def register(~S: Data,~C: Type,~R: Type,~E: Data,~A: Type,~Error: Data,~O: Type,~runner: W.World<S,C,R,E> -> K.Input<S,E,A> -> Sy.Outcome<W.World<S,C,R,E>,Error,O>,runtime: K.Runtime<S,C,R,E>,+declarations: List<&2,Declaration<S>>,+name: String) -> K.Registered<S,C,R,E,A,Error,O,runner>:
  K.register(~S,~C,~R,~E,~A,~Error,~O,~runner,runtime,keys(~S,declarations),name,accesses(~S,declarations))
